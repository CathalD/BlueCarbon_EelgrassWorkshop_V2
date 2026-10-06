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

#' Cumulative stock from the surface to each standard depth (0–15, 0–30, ...), complete
#' only when every increment above it is complete.
cumulative_stocks <- function(inc) {
  if (!nrow(inc)) return(data.frame())
  do.call(rbind, lapply(split(inc, inc$core_id), function(x) {
    x <- x[order(x$depth_top_cm), ]
    ok <- cumprod(x$status == "complete") == 1
    data.frame(core_id = x$core_id, plot_id = x$plot_id, stratum = x$stratum,
               depth_cm = x$depth_bottom_cm,
               stock_Mg_ha = ifelse(ok, cumsum(ifelse(is.na(x$stock_Mg_ha), 0, x$stock_Mg_ha)), NA_real_),
               status = ifelse(ok, "complete", "not reached"))
  }))
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
