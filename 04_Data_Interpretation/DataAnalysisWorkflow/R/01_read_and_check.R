# 01_read_and_check.R — shared foundation, part 1
# Reads the digital data sheet and checks it, slice by slice, using the same rules the
# workbook's "Slice check" column uses. Nothing is filled in or defaulted: a problem is
# reported, and the affected core is left out of totals until it is fixed.

# Column positions on each tab (the headers contain line breaks, so we read by position).
CORE_LOG_COLS <- c(plot_id = 1, core_id = 2, date = 3, time = 4, site = 5, latitude = 6,
                   longitude = 7, photo_id = 8, conditions = 9, diameter_cm = 10,
                   outside_cm = 11, inside_cm = 12, stratum = 16, compaction_note = 17,
                   core_notes = 18)
SAMPLE_COLS <- c(core_id = 1, sample_id = 2, top_cm = 3, bottom_cm = 4, notes = 5,
                 wet_g = 12, dry_g = 13, carbon_value_pct = 14, carbon_type = 15,
                 # calculated by the workbook — read only to cross-check our own numbers
                 wb_bd = 17, wb_oc_pct = 18, wb_stock_kg_m2 = 22, wb_check = 27)

read_tab <- function(path, sheet, cols, first_row, last_row) {
  raw <- suppressMessages(readxl::read_excel(path, sheet = sheet, col_names = FALSE,
                                             col_types = "text", .name_repair = "minimal"))
  raw <- raw[first_row:min(last_row, nrow(raw)), , drop = FALSE]
  out <- as.data.frame(lapply(cols, function(i) if (i <= ncol(raw)) raw[[i]] else NA_character_),
                       stringsAsFactors = FALSE)
  names(out) <- names(cols)
  out
}

as_num <- function(x) suppressWarnings(as.numeric(x))

#' Read the workbook. Returns list(cores, samples, loi).
read_workbook <- function(path) {
  if (!file.exists(path)) stop("Workbook not found: ", path)
  cores <- read_tab(path, "2. Plot & Core Log", CORE_LOG_COLS, first_row = 6, last_row = 35)
  cores <- cores[!is.na(cores$core_id) & trimws(cores$core_id) != "", ]
  for (k in c("latitude", "longitude", "diameter_cm", "outside_cm", "inside_cm"))
    cores[[k]] <- as_num(cores[[k]])
  cores$core_id <- trimws(cores$core_id)
  cores$plot_id <- trimws(cores$plot_id)
  cores$stratum <- ifelse(is.na(cores$stratum), NA, trimws(cores$stratum))

  s <- read_tab(path, "3. Sample Data", SAMPLE_COLS, first_row = 6, last_row = 205)
  s <- s[!is.na(s$core_id) & trimws(s$core_id) != "", ]
  for (k in c("top_cm", "bottom_cm", "wet_g", "dry_g", "carbon_value_pct",
              "wb_bd", "wb_oc_pct", "wb_stock_kg_m2"))
    s[[k]] <- as_num(s[[k]])
  s$core_id <- trimws(s$core_id)
  s$carbon_type <- toupper(trimws(s$carbon_type))

  ins <- suppressMessages(readxl::read_excel(path, sheet = "1. Instructions", col_names = FALSE,
                                             col_types = "text", .name_repair = "minimal"))
  pick <- function(label) {
    i <- which(trimws(ins[[1]]) == label)
    if (length(i) == 0) NA_real_ else as_num(ins[[2]][i[1]])
  }
  list(cores = cores, samples = s,
       loi = c(intercept = pick("LOI intercept"), slope = pick("LOI slope")))
}

#' Compaction factor for each core: outside / inside when both were measured; 1 only
#' when the user explicitly wrote "assume none"; otherwise NA (never silently 1).
compaction_factor <- function(cores) {
  measured <- !is.na(cores$outside_cm) & !is.na(cores$inside_cm)
  assumed  <- !measured & tolower(trimws(cores$compaction_note)) %in% "assume none"
  cf <- ifelse(measured, cores$outside_cm / cores$inside_cm, ifelse(assumed, 1, NA_real_))
  cores$compaction_factor <- cf
  cores$compaction_basis  <- ifelse(measured, "measured", ifelse(assumed, "assumed none", "missing"))
  cores$core_check <- with(cores, ifelse(
    is.na(diameter_cm), "CHECK: corer diameter missing",
    ifelse(compaction_basis == "missing", "CHECK: compaction not recorded",
    ifelse(measured & (inside_cm > outside_cm), "CHECK: extracted > inserted",
    ifelse(measured & (compaction_factor > 1.5), "CHECK: >50% compaction",
    ifelse(compaction_basis == "assumed none", "ASSUMED: no compaction (not measured)", "OK"))))))
  dup <- duplicated(cores$core_id) | duplicated(cores$core_id, fromLast = TRUE)
  cores$core_check[dup] <- "CHECK: duplicate Core ID in Core Log"
  cores
}

#' Organic carbon (% of dry mass) from the lab value and its type.
#' OC is used as is; LOI is converted with the stated equation (never below 0);
#' TC, unknown types and missing equations give NA — they are reported, never guessed.
organic_carbon_pct <- function(value, type, loi) {
  out <- rep(NA_real_, length(value))
  oc <- type %in% "OC"
  out[oc] <- value[oc]
  li <- type %in% "LOI"
  if (!any(is.na(loi))) out[li] <- pmax(0, loi[["intercept"]] + loi[["slope"]] * value[li])
  out
}

#' Slice-level calculations and checks. Units: depths cm, mass g, volume cm3,
#' bulk density g/cm3, carbon density g C/cm3, stock g C/cm2 and kg C/m2.
check_slices <- function(wb) {
  cores <- compaction_factor(wb$cores)
  s <- wb$samples
  m <- match(s$core_id, cores$core_id)
  s$plot_id <- cores$plot_id[m]
  s$stratum <- cores$stratum[m]
  s$compaction_factor <- cores$compaction_factor[m]
  s$diameter_cm <- cores$diameter_cm[m]
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
  set(is.na(s$dry_g) | is.na(s$carbon_value_pct) | is.na(s$carbon_type) | s$carbon_type == "",
      "AWAITING LAB (dry weight, carbon value or type)")
  set(s$carbon_type == "TC", "TC is not organic carbon — ask the lab for OC or IC")
  set(!s$carbon_type %in% c("OC", "LOI", "TC"), "CHECK: type must be OC, TC or LOI")
  set(is.na(s$oc_pct), "CHECK: LOI conversion not set (Instructions tab)")
  set(s$bd_g_cm3 <= 0 | s$bd_g_cm3 > 2.65 | s$oc_pct > 50,
      "CHECK: bulk density outside 0–2.65 g/cm3 or OC > 50%")
  s$check <- chk

  # Core status: complete only when the core is OK/assumed and every slice is OK.
  cores$n_slices <- as.integer(table(factor(s$core_id, levels = cores$core_id)))
  cores$n_ok <- as.integer(table(factor(s$core_id[s$check == "OK"], levels = cores$core_id)))
  core_ok <- cores$core_check %in% c("OK", "ASSUMED: no compaction (not measured)")
  cores$status <- ifelse(cores$n_slices == 0, "No slices entered",
                  ifelse(!core_ok, cores$core_check,
                  ifelse(cores$n_ok < cores$n_slices, "Not complete — see slice checks", "Complete")))
  cores$measured_to_insitu_cm <- vapply(cores$core_id, function(id) {
    x <- s$insitu_bottom_cm[s$core_id == id]; if (length(x) && any(!is.na(x))) max(x, na.rm = TRUE) else NA_real_
  }, numeric(1))
  orphan <- setdiff(unique(s$core_id), cores$core_id)
  list(cores = cores, slices = s, loi = wb$loi, orphan_core_ids = orphan)
}

#' Compare our numbers with the workbook's own calculated columns (when the workbook was
#' saved with calculated values). Returns the largest absolute differences.
cross_check_workbook <- function(chk) {
  s <- chk$slices
  d <- function(a, b) { x <- abs(a - b); if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE) }
  data.frame(quantity = c("bulk density (g/cm3)", "organic carbon (%)", "stock (kg C/m2)"),
             max_abs_difference = c(d(s$bd_g_cm3, s$wb_bd), d(s$oc_pct, s$wb_oc_pct),
                                    d(s$stock_kg_m2, s$wb_stock_kg_m2)))
}
