# 01_read_and_check.R — shared foundation, part 1
# Reads the digital data sheet and checks it, slice by slice, using the same rules the
# workbook's "Slice check" column uses. Nothing is filled in or defaulted: a problem is
# reported, and the affected core is left out of totals until it is fixed.

# Column positions on each tab (the headers contain line breaks, so we read by position).
CORE_LOG_COLS <- c(plot_id = 1, core_id = 2, date = 3, time = 4, site = 5, latitude = 6,
                   longitude = 7, photo_id = 8, conditions = 9, diameter_cm = 10,
                   outside_cm = 11, inside_cm = 12, stratum = 16, compaction_note = 17,
                   core_notes = 18,
                   # calculated by the workbook — read only to cross-check our own numbers
                   wb_core_check = 15, wb_diameter_used = 19)
SAMPLE_COLS <- c(core_id = 1, sample_id = 2, top_cm = 3, bottom_cm = 4, notes = 5,
                 wet_g = 12, dry_g = 13, carbon_value_pct = 14, carbon_type = 15,
                 wb_bd = 17, wb_oc_pct = 18, wb_stock_kg_m2 = 22, wb_check = 27)
# Rows the template provides for data (first, last). Current workbooks store their last data
# row in the named cells LAST_CORE_ROW and LAST_SLICE_ROW (300 cores, 4,000 slices); these are
# the rows of earlier workbooks, which did not. Anything typed below the table is an error,
# not something to ignore quietly.
CORE_LOG_ROWS <- c(6, 35)
SAMPLE_ROWS   <- c(6, 205)

data_rows <- function(path, name, fallback) {
  last <- tryCatch(read_named_cell(path, name), error = function(e) NA_real_)
  if (is.na(last)) fallback else c(fallback[1], last)
}

read_tab <- function(path, sheet, cols, rows, extra_cols) {
  raw <- suppressMessages(readxl::read_excel(path, sheet = sheet, col_names = FALSE,
                                             col_types = "text", .name_repair = "minimal"))
  below <- seq_len(nrow(raw)) > rows[2]
  filled <- Reduce(`|`, lapply(extra_cols, function(i)
    if (i <= ncol(raw)) !is.na(raw[[i]]) & trimws(raw[[i]]) != "" else rep(FALSE, nrow(raw))))
  if (any(below & filled))
    stop(sprintf("'%s' has data below row %d (row %s), which is not read. This workbook's table runs from row %d to %d: ",
                 sheet, rows[2], paste(head(which(below & filled), 10), collapse = ", "), rows[1], rows[2]),
         "move those rows up into the table. If the table is full, copy everything into the current blank ",
         "workbook (workbooks/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx), which holds 300 cores and 4,000 slices.",
         call. = FALSE)
  raw <- raw[rows[1]:min(rows[2], nrow(raw)), , drop = FALSE]
  out <- as.data.frame(lapply(cols, function(i) if (i <= ncol(raw)) raw[[i]] else NA_character_),
                       stringsAsFactors = FALSE)
  names(out) <- names(cols)
  out
}

as_num <- function(x) suppressWarnings(as.numeric(x))
blank  <- function(x) is.na(x) | trimws(x) == ""

#' Value of a named cell (e.g. LOI_SLOPE), found through the workbook's defined names, so it
#' does not matter where the cell sits on the sheet. NA when the cell is empty.
read_named_cell <- function(path, name) {
  xml <- tryCatch(paste(readLines(unz(path, "xl/workbook.xml"), warn = FALSE), collapse = ""),
                  error = function(e) "")
  m <- regmatches(xml, regexpr(sprintf('<definedName[^>]*name="%s"[^>]*>[^<]+</definedName>', name), xml))
  if (!length(m)) stop("The workbook has no named cell '", name, "'. Use the current blank sheet from Part 4.")
  ref <- sub("^.*>([^<]+)<.*$", "\\1", m)
  for (e in list(c("&apos;", "'"), c("&quot;", '"'), c("&lt;", "<"), c("&gt;", ">"), c("&amp;", "&")))
    ref <- gsub(e[1], e[2], ref, fixed = TRUE)
  sheet <- gsub("^'|'$", "", sub("!.*$", "", ref))
  cell  <- gsub("\\$", "", sub("^.*!", "", ref))
  v <- suppressMessages(readxl::read_excel(path, sheet = sheet, range = cell, col_names = FALSE,
                                           col_types = "text"))
  if (!nrow(v) || !ncol(v)) NA_real_ else as_num(v[[1]][1])
}

#' Read the workbook. Returns list(cores, samples, loi, corer_diameter_cm).
read_workbook <- function(path) {
  if (!file.exists(path))
    stop("Workbook not found: ", path, " (looked in ", normalizePath(getwd()), "). Check WORKBOOK in your ",
         "settings file, and that the workbook is saved there as .xlsx.", call. = FALSE)
  cores <- read_tab(path, "2. Plot & Core Log", CORE_LOG_COLS,
                    data_rows(path, "LAST_CORE_ROW", CORE_LOG_ROWS), extra_cols = 2)
  cores <- cores[!blank(cores$core_id), ]
  for (k in c("latitude", "longitude", "diameter_cm", "outside_cm", "inside_cm", "wb_diameter_used"))
    cores[[k]] <- as_num(cores[[k]])
  cores$core_id <- trimws(cores$core_id)
  cores$plot_id <- ifelse(blank(cores$plot_id), NA_character_, trimws(cores$plot_id))
  cores$stratum <- ifelse(blank(cores$stratum), NA_character_, trimws(cores$stratum))

  s <- read_tab(path, "3. Sample Data", SAMPLE_COLS,
                data_rows(path, "LAST_SLICE_ROW", SAMPLE_ROWS), extra_cols = c(2, 3, 4))
  s <- s[!blank(s$core_id), ]
  for (k in c("top_cm", "bottom_cm", "wet_g", "dry_g", "carbon_value_pct",
              "wb_bd", "wb_oc_pct", "wb_stock_kg_m2"))
    s[[k]] <- as_num(s[[k]])
  s$core_id <- trimws(s$core_id)
  s$carbon_type <- toupper(trimws(s$carbon_type))

  list(cores = cores, samples = s,
       loi = c(intercept = read_named_cell(path, "LOI_INTERCEPT"),
               slope = read_named_cell(path, "LOI_SLOPE")),
       corer_diameter_cm = read_named_cell(path, "CORER_DIAMETER_CM"))
}

#' Corer diameter used for each core: the core's own value (Sheet 2, column J) if given,
#' otherwise the project value on the Instructions tab. Never assumed beyond that.
corer_diameter <- function(cores, project_cm) {
  own <- !is.na(cores$diameter_cm)
  cores$diameter_used_cm <- ifelse(own, cores$diameter_cm, project_cm)
  cores$diameter_source  <- ifelse(own, "this core", ifelse(is.na(project_cm), "missing", "Instructions"))
  cores
}

#' Compaction factor for each core: outside / inside when both were measured; 1 only
#' when the user explicitly wrote "assume none"; otherwise NA (never silently 1).
#' The QC check follows the workbook's order (Sheet 2, column O): first problem wins.
compaction_factor <- function(cores) {
  measured <- !is.na(cores$outside_cm) & !is.na(cores$inside_cm)
  neither  <- is.na(cores$outside_cm) & is.na(cores$inside_cm)
  assumed  <- !measured & tolower(trimws(cores$compaction_note)) %in% "assume none"
  cf <- ifelse(measured, cores$outside_cm / cores$inside_cm, ifelse(assumed, 1, NA_real_))
  cores$compaction_factor <- cf
  cores$compaction_basis  <- ifelse(measured, "measured", ifelse(assumed, "assumed none", "missing"))
  dup <- duplicated(cores$core_id) | duplicated(cores$core_id, fromLast = TRUE)
  cores$core_check <- ifelse(dup, "CHECK: duplicate Core ID",
    ifelse(is.na(cores$diameter_used_cm), "CHECK: corer diameter missing",
    ifelse(neither, ifelse(assumed, "ASSUMED: no compaction (not measured)", "CHECK: compaction not recorded"),
    ifelse(!measured, "CHECK: one depth missing",
    ifelse(cores$inside_cm > cores$outside_cm, "CHECK: extracted > inserted",
    ifelse(cf > 1.5, "CHECK: >50% compaction", "OK"))))))
  cores
}

#' Organic carbon (% of dry mass) from the lab value and its type.
#' OC is used as is; LOI is converted with the stated equation; TC, unknown types, a missing
#' equation, and an LOI value that would convert to below zero give NA — reported, never guessed.
loi_to_oc <- function(loi_pct, loi) loi[["intercept"]] + loi[["slope"]] * loi_pct

organic_carbon_pct <- function(value, type, loi) {
  out <- rep(NA_real_, length(value))
  oc <- type %in% "OC"
  out[oc] <- value[oc]
  li <- type %in% "LOI"
  if (!any(is.na(loi))) {
    conv <- loi_to_oc(value[li], loi)
    out[li] <- ifelse(conv < 0, NA_real_, conv)
  }
  out
}

#' Slice-level calculations and checks. Units: depths cm, mass g, volume cm3,
#' bulk density g/cm3, carbon density g C/cm3, stock g C/cm2 and kg C/m2.
check_slices <- function(wb) {
  cores <- compaction_factor(corer_diameter(wb$cores, wb$corer_diameter_cm))
  s <- wb$samples
  m <- match(s$core_id, cores$core_id)
  s$plot_id <- cores$plot_id[m]
  s$stratum <- cores$stratum[m]
  s$compaction_factor <- cores$compaction_factor[m]
  s$diameter_cm <- cores$diameter_used_cm[m]
  s$core_length_cm <- cores$inside_cm[m]
  s$thickness_cm <- s$bottom_cm - s$top_cm
  s$insitu_top_cm <- s$top_cm * s$compaction_factor
  s$insitu_bottom_cm <- s$bottom_cm * s$compaction_factor
  s$volume_cm3 <- pi * (s$diameter_cm / 2)^2 * s$thickness_cm
  s$bd_g_cm3 <- s$dry_g / s$volume_cm3
  s$oc_pct <- organic_carbon_pct(s$carbon_value_pct, s$carbon_type, wb$loi)
  s$carbon_density_g_cm3 <- s$bd_g_cm3 * s$oc_pct / 100
  s$stock_g_cm2 <- s$carbon_density_g_cm3 * s$thickness_cm   # measured (tube) interval
  s$stock_kg_m2 <- s$stock_g_cm2 * 10

  # Checks, in the same order as the workbook (first problem wins).
  chk <- rep("OK", nrow(s))
  set <- function(cond, msg) { cond[is.na(cond)] <- FALSE; chk[chk == "OK" & cond] <<- msg }
  set(is.na(s$top_cm) | is.na(s$bottom_cm) | s$bottom_cm <= s$top_cm,
      "CHECK: depths missing, or bottom not below top")
  key <- paste(s$core_id, s$top_cm)
  set(duplicated(key) | duplicated(key, fromLast = TRUE), "DUPLICATE slice")
  ov <- vapply(seq_len(nrow(s)), function(i) {
    j <- s$core_id == s$core_id[i] & s$top_cm < s$bottom_cm[i] & s$bottom_cm > s$top_cm[i]
    sum(j, na.rm = TRUE) > 1
  }, logical(1))
  set(ov, "OVERLAP with another slice")
  gap <- vapply(seq_len(nrow(s)), function(i) {
    !is.na(s$top_cm[i]) && s$top_cm[i] > 0 &&
      !any(s$core_id == s$core_id[i] & abs(s$bottom_cm - s$top_cm[i]) < 1e-9, na.rm = TRUE)
  }, logical(1))
  set(gap, "GAP above this slice")
  set(is.na(s$compaction_factor) | is.na(s$diameter_cm),
      "CHECK: Core ID not in Core Log, or its compaction / diameter missing")
  set(!is.na(s$core_length_cm) & s$core_length_cm > 0 & s$bottom_cm > s$core_length_cm,
      "CHECK: slice deeper than the core length on Sheet 2")
  set(is.na(s$dry_g) | is.na(s$carbon_value_pct) | is.na(s$carbon_type) | s$carbon_type == "",
      "AWAITING LAB (dry weight, carbon value or type)")
  set(s$carbon_type == "TC", "TC is not organic carbon — ask the lab for OC or IC")
  set(!s$carbon_type %in% c("OC", "LOI", "TC"), "CHECK: type must be OC, TC or LOI")
  have_eq <- !any(is.na(wb$loi))
  set(is.na(s$oc_pct) & have_eq, "CHECK: LOI below the range of the conversion equation (OC would be < 0)")
  set(is.na(s$oc_pct), "CHECK: LOI conversion not set (Instructions tab)")
  set(s$bd_g_cm3 <= 0 | s$bd_g_cm3 > 2.65 | s$oc_pct > 50,
      "CHECK: bulk density outside 0–2.65 g/cm3 or OC > 50%")
  s$check <- chk

  # A warning does not stop a core being totalled, but should be looked at: a slice whose
  # thickness and lab values exactly repeat the slice above is often a copied row (published
  # compilations pad short cores this way).
  s$warning <- rep(NA_character_, nrow(s))
  o <- order(s$core_id, s$top_cm)
  prev <- c(NA, head(o, -1))
  same_core <- if (length(o) > 1) c(FALSE, s$core_id[o][-1] == s$core_id[o][-length(o)]) else rep(FALSE, length(o))
  rep_vals <- same_core &
    vapply(seq_along(o), function(k) {
      if (!same_core[k]) return(FALSE)
      a <- o[k]; b <- prev[k]
      isTRUE(all.equal(c(s$thickness_cm[a], s$dry_g[a], s$carbon_value_pct[a]),
                       c(s$thickness_cm[b], s$dry_g[b], s$carbon_value_pct[b]))) &&
        identical(s$carbon_type[a], s$carbon_type[b])
    }, logical(1))
  s$warning[o[rep_vals]] <- "Same thickness, dry weight and carbon value as the slice above — copied row?"

  # Core status: complete only when the core is OK/assumed and every slice is OK.
  cores$n_slices <- as.integer(table(factor(s$core_id, levels = unique(cores$core_id)))[cores$core_id])
  cores$n_ok <- as.integer(table(factor(s$core_id[s$check == "OK"], levels = unique(cores$core_id)))[cores$core_id])
  core_ok <- cores$core_check %in% c("OK", "ASSUMED: no compaction (not measured)")
  cores$status <- ifelse(cores$n_slices == 0, "No slices entered",
                  ifelse(!core_ok, paste(cores$core_check, "(Sheet 2)"),
                  ifelse(cores$n_ok < cores$n_slices, "Not complete — see Slice check on Sheet 3", "Complete")))
  cores$measured_to_insitu_cm <- vapply(cores$core_id, function(id) {
    x <- s$insitu_bottom_cm[s$core_id == id]; if (length(x) && any(!is.na(x))) max(x, na.rm = TRUE) else NA_real_
  }, numeric(1), USE.NAMES = FALSE)
  orphan <- setdiff(unique(s$core_id), cores$core_id)
  list(cores = cores, slices = s, loi = wb$loi, corer_diameter_cm = wb$corer_diameter_cm,
       orphan_core_ids = orphan)
}

#' Plain-language list of everything that keeps a core out of the totals.
check_report <- function(chk) {
  cores <- chk$cores[chk$cores$status != "Complete", c("core_id", "status")]
  slices <- chk$slices[chk$slices$check != "OK", c("core_id", "sample_id", "top_cm", "bottom_cm", "check")]
  warn <- chk$slices[!is.na(chk$slices$warning), c("core_id", "sample_id", "top_cm", "bottom_cm", "warning")]
  list(cores = cores, slices = slices, warnings = warn, orphan_core_ids = chk$orphan_core_ids)
}

print_check_report <- function(rep) {
  if (nrow(rep$cores)) {
    message("These cores are left out of the totals until fixed:")
    print(rep$cores, row.names = FALSE)
  }
  if (nrow(rep$slices)) {
    message("Slice problems:")
    print(rep$slices, row.names = FALSE)
  }
  if (length(rep$orphan_core_ids))
    message("Core IDs on Sheet 3 that are not on Sheet 2: ", paste(rep$orphan_core_ids, collapse = ", "))
  if (nrow(rep$warnings)) {
    message("Worth a look (these do not stop a core being totalled):")
    print(rep$warnings, row.names = FALSE)
  }
  invisible(rep)
}

#' Compare our numbers with the workbook's own calculated columns (when the workbook was
#' saved with calculated values). Returns the largest absolute differences, and how many
#' slice checks and core diameters disagree.
cross_check_workbook <- function(chk) {
  s <- chk$slices; cores <- chk$cores
  d <- function(a, b) { x <- abs(a - b); if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE) }
  agree_na <- function(a, b) sum(xor(is.na(a), is.na(b)))
  data.frame(
    quantity = c("bulk density (g/cm3)", "organic carbon (%)", "stock (kg C/m2)",
                 "corer diameter used (cm)", "slice checks that differ (count)",
                 "core checks that differ (count)", "values present in one but not the other (count)"),
    max_abs_difference = c(d(s$bd_g_cm3, s$wb_bd), d(s$oc_pct, s$wb_oc_pct),
                           d(s$stock_kg_m2, s$wb_stock_kg_m2),
                           d(cores$diameter_used_cm, cores$wb_diameter_used),
                           sum(s$check != s$wb_check, na.rm = TRUE) + sum(is.na(s$wb_check)),
                           sum(cores$core_check != cores$wb_core_check, na.rm = TRUE),
                           agree_na(s$bd_g_cm3, s$wb_bd) + agree_na(s$oc_pct, s$wb_oc_pct) +
                             agree_na(s$stock_kg_m2, s$wb_stock_kg_m2)))
}
