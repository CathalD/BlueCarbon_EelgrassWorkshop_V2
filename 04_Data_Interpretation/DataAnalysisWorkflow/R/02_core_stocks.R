# 02_core_stocks.R — shared foundation, part 2
# Core stocks on a common footing: the standard depth increments.
#
# Units: 1 g C/cm2 = 10 kg C/m2 = 100 Mg C/ha.
#
# How a slice is shared between increments: its carbon (g C/cm2, from the measured
# interval and the recovered-slice volume) is placed on its in-situ depths and split in
# proportion to overlap. The carbon in a core is therefore identical before and after the
# compaction correction — compaction moves carbon to its true depth, it never adds any.

STANDARD_INCREMENTS <- c(0, 15, 30, 50, 100)

overlap_cm <- function(top, bottom, a, b) pmax(0, pmin(bottom, b) - pmax(top, a))

#' Stock in each standard increment, per complete core.
#' status: "complete" (the core reaches the bottom of the increment), "partial"
#' (it ends inside it — value is the measured part only, not comparable), or "not reached".
increment_stocks <- function(chk, breaks = STANDARD_INCREMENTS) {
  s <- chk$slices
  cores <- chk$cores[chk$cores$status == "Complete", ]
  out <- list()
  for (id in cores$core_id) {
    x <- s[s$core_id == id, ]
    reach <- max(x$insitu_bottom_cm)
    for (k in seq_len(length(breaks) - 1)) {
      a <- breaks[k]; b <- breaks[k + 1]
      w <- overlap_cm(x$insitu_top_cm, x$insitu_bottom_cm, a, b) /
        (x$insitu_bottom_cm - x$insitu_top_cm)
      g <- sum(x$stock_g_cm2 * w)
      status <- if (reach >= b - 1e-6) "complete" else if (reach > a) "partial" else "not reached"
      out[[length(out) + 1]] <- data.frame(
        core_id = id, plot_id = x$plot_id[1], stratum = x$stratum[1],
        depth_top_cm = a, depth_bottom_cm = b, status = status,
        stock_g_cm2 = if (status == "not reached") NA_real_ else g)
    }
  }
  r <- do.call(rbind, out)
  if (is.null(r)) return(data.frame())
  r$stock_kg_m2 <- r$stock_g_cm2 * 10
  r$stock_Mg_ha <- r$stock_g_cm2 * 100
  r$increment <- paste0(r$depth_top_cm, "–", r$depth_bottom_cm, " cm")
  r
}

#' Cumulative stock from the surface to each standard depth (0–15, 0–30, ...). A value is
#' given only when every increment above that depth is complete; otherwise the status says
#' whether the core ends inside the deepest increment ("partial") or above it ("not reached").
cumulative_stocks <- function(inc) {
  if (!nrow(inc)) return(data.frame())
  out <- do.call(rbind, lapply(split(inc, inc$core_id), function(x) {
    x <- x[order(x$depth_top_cm), ]
    rows <- lapply(seq_len(nrow(x)), function(k) {
      above <- x[seq_len(k), ]
      complete <- all(above$status == "complete")
      data.frame(core_id = x$core_id[1], plot_id = x$plot_id[1], stratum = x$stratum[1],
                 depth_cm = x$depth_bottom_cm[k],
                 stock_Mg_ha = if (complete) sum(above$stock_Mg_ha) else NA_real_,
                 status = if (complete) "complete" else if (x$status[k] == "partial") "partial" else "not reached")
    })
    do.call(rbind, rows)
  }))
  rownames(out) <- NULL
  out
}

#' Carbon is never gained or lost when slices are placed on in-situ depths and split between
#' increments: for every complete core that the increments fully span, the sum of its
#' increment stocks must equal the sum of its slice stocks. Stops if not (it would be a bug).
check_mass_conservation <- function(chk, inc, tol = 1e-9) {
  if (!nrow(inc)) return(invisible(TRUE))
  s <- chk$slices
  for (id in unique(inc$core_id)) {
    x <- s[s$core_id == id, ]
    if (max(x$insitu_bottom_cm) > max(inc$depth_bottom_cm) + 1e-9) next   # core runs past 100 cm
    a <- sum(x$stock_g_cm2); b <- sum(inc$stock_g_cm2[inc$core_id == id], na.rm = TRUE)
    if (abs(a - b) > tol * max(1, a))
      stop(sprintf("Carbon not conserved for core %s: slices %.6g vs increments %.6g g C/cm2", id, a, b))
  }
  invisible(TRUE)
}

#' One row per core: what was measured, and the measured total (to whatever depth the
#' core reached — not comparable between cores of different lengths).
core_summary <- function(chk) {
  s <- chk$slices; cores <- chk$cores
  rows <- lapply(seq_len(nrow(cores)), function(i) {
    id <- cores$core_id[i]; x <- s[s$core_id == id, ]
    done <- cores$status[i] == "Complete"
    data.frame(
      core_id = id, plot_id = cores$plot_id[i], stratum = cores$stratum[i],
      latitude = cores$latitude[i], longitude = cores$longitude[i],
      status = cores$status[i], compaction = cores$compaction_basis[i],
      compaction_factor = cores$compaction_factor[i],
      n_slices = nrow(x),
      measured_to_insitu_cm = if (nrow(x)) max(x$insitu_bottom_cm) else NA_real_,
      bd_g_cm3 = if (done) sum(x$dry_g) / sum(x$volume_cm3) else NA_real_,
      oc_pct = if (done) 100 * sum(x$stock_g_cm2) / sum(x$bd_g_cm3 * x$thickness_cm) else NA_real_,
      share_slices_from_LOI = if (nrow(x)) mean(x$carbon_type == "LOI") else NA_real_,
      measured_stock_kg_m2 = if (done) sum(x$stock_kg_m2) else NA_real_,
      measured_stock_Mg_ha = if (done) sum(x$stock_g_cm2) * 100 else NA_real_)
  })
  do.call(rbind, rows)
}

#' One row per core for the console: its status, how deep it was measured (in situ), and its
#' cumulative stock (Mg C/ha) to each standard depth it fully reached ("—" where it did not).
stock_table <- function(cores, cum) {
  if (is.null(cores) || !nrow(cores)) return(data.frame())
  out <- cores[, c("core_id", "status", "measured_to_insitu_cm")]
  out$measured_to_insitu_cm <- round(out$measured_to_insitu_cm, 1)
  for (d in STANDARD_INCREMENTS[-1]) {
    x <- if (nrow(cum)) cum[cum$depth_cm == d, ] else data.frame(core_id = character(), stock_Mg_ha = numeric())
    v <- x$stock_Mg_ha[match(out$core_id, x$core_id)]
    out[[sprintf("0-%g cm (Mg C/ha)", d)]] <- ifelse(is.na(v), "—", sprintf("%.1f", v))
  }
  out
}
