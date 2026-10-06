# 04_option_B.R — Option B: what do our measurements imply for this meadow or study area?
#
# Step 1 — a 1 cm "carbon curve" for every complete core, 0–100 cm:
#   * within the measured core, each 1 cm takes the carbon of the slice(s) that cover it
#     (step-fill, in-situ depths). The curve's measured part adds up to exactly the measured
#     core stock — nothing is smoothed away or added;
#   * below the base of the core, carbon density is ESTIMATED with a decay curve that levels
#     off at a non-zero floor (stats::SSasymp), fitted to that core's measured carbon density.
#     Fallbacks, in order: a curve fitted to all cores in the same stratum; then the mean
#     carbon density of the deepest 5 cm measured, held constant. A fit is only accepted if it
#     converges and never predicts a density above the highest measured value.
#   Every increment reports how much of it is measured and how much is estimated.
# Step 2 — one value per sampling unit (plot), then an area estimate that matches the design.

CELL_CM <- 1

fit_decay <- function(depth, density, max_allowed) {
  if (length(depth) < 4 || length(unique(depth)) < 4) return(NULL)
  fit <- tryCatch(stats::nls(density ~ SSasymp(depth, Asym, R0, lrc),
                             data = data.frame(depth = depth, density = density)),
                  error = function(e) NULL, warning = function(w) NULL)
  if (is.null(fit)) return(NULL)
  cf <- stats::coef(fit)
  if (!is.finite(cf[["Asym"]]) || cf[["Asym"]] < 0 || cf[["Asym"]] > max_allowed) return(NULL)
  fit
}

slice_density <- function(x) x$stock_g_cm2 / (x$insitu_bottom_cm - x$insitu_top_cm)

#' 1 cm carbon curve for every complete core. Returns one row per core per cm.
carbon_curves <- function(chk, max_depth = 100, min_slices = 4) {
  s <- chk$slices
  cores <- chk$cores[chk$cores$status == "Complete", ]
  s <- s[s$core_id %in% cores$core_id, ]
  s$mid <- (s$insitu_top_cm + s$insitu_bottom_cm) / 2
  s$dens <- slice_density(s)
  grp <- ifelse(is.na(s$stratum) | s$stratum == "", "all cores", s$stratum)
  pooled <- lapply(split(s, grp), function(x) fit_decay(x$mid, x$dens, max(x$dens)))

  out <- list()
  for (id in cores$core_id) {
    x <- s[s$core_id == id, ]
    base <- max(x$insitu_bottom_cm)
    top <- seq(0, max_depth - CELL_CM, by = CELL_CM)
    meas <- vapply(top, function(a) sum(x$stock_g_cm2 * overlap_cm(x$insitu_top_cm, x$insitu_bottom_cm,
                                                                     a, a + CELL_CM) /
                                          (x$insitu_bottom_cm - x$insitu_top_cm)), 0)
    fit <- if (nrow(x) >= min_slices) fit_decay(x$mid, x$dens, max(x$dens)) else NULL
    method <- "core decay curve"
    if (is.null(fit)) { fit <- pooled[[grp[s$core_id == id][1]]]; method <- "stratum decay curve" }
    deep_mean <- sum(x$stock_g_cm2 * overlap_cm(x$insitu_top_cm, x$insitu_bottom_cm, base - 5, base) /
                       (x$insitu_bottom_cm - x$insitu_top_cm)) / min(5, base)
    f <- if (is.null(fit)) { method <- "constant (deepest 5 cm)"; function(d) rep(deep_mean, length(d)) }
         else function(d) pmax(0, stats::predict(fit, newdata = data.frame(depth = d)))
    if (base >= max_depth) method <- "none needed"
    lo <- pmax(top, base); hi <- top + CELL_CM
    gap_len <- pmax(0, hi - lo)
    est <- ifelse(gap_len > 0, gap_len * f((lo + hi) / 2), 0)
    out[[id]] <- data.frame(core_id = id, plot_id = x$plot_id[1], stratum = x$stratum[1],
                            cell_top_cm = top, cell_bottom_cm = top + CELL_CM,
                            measured_g_cm2 = meas, estimated_g_cm2 = est,
                            core_base_cm = base, extrapolation = method)
  }
  do.call(rbind, out)
}

#' Stock from the surface to each reporting depth, split into measured and estimated parts.
curve_stocks <- function(curves, depths = c(15, 30, 50, 100)) {
  do.call(rbind, lapply(split(curves, curves$core_id), function(x) {
    do.call(rbind, lapply(depths, function(D) {
      y <- x[x$cell_bottom_cm <= D + 1e-9, ]
      m <- sum(y$measured_g_cm2) * 100; e <- sum(y$estimated_g_cm2) * 100
      data.frame(core_id = x$core_id[1], plot_id = x$plot_id[1], stratum = x$stratum[1],
                 depth_cm = D, measured_Mg_ha = m, estimated_Mg_ha = e, stock_Mg_ha = m + e,
                 pct_estimated = if (m + e > 0) 100 * e / (m + e) else NA_real_,
                 extrapolation = x$extrapolation[1])
    }))
  }))
}

#' One value per sampling unit. With unit = "plot", cores sharing a Plot ID are averaged
#' first: they are not independent samples of the area.
unit_values <- function(stocks, depth_cm, unit = c("plot", "core")) {
  unit <- match.arg(unit)
  d <- stocks[stocks$depth_cm == depth_cm, ]
  if (unit == "core") {
    d$unit_id <- d$core_id
  } else {
    if (any(is.na(d$plot_id) | d$plot_id == "")) stop("Every core needs a Plot ID when the sampling unit is the plot.")
    d$unit_id <- d$plot_id
  }
  st <- tapply(d$stratum, d$unit_id, function(z) unique(z[!is.na(z)]))
  bad <- names(st)[vapply(st, length, 1L) > 1]
  if (length(bad)) stop("Cores in the same plot have different strata: ", paste(bad, collapse = ", "))
  agg <- function(v) as.numeric(tapply(v, d$unit_id, mean))
  ids <- sort(unique(d$unit_id))
  data.frame(unit_id = ids,
             stratum = vapply(ids, function(i) { z <- st[[i]]; if (length(z)) z else NA_character_ }, ""),
             n_cores = as.integer(table(d$unit_id)[ids]),
             stock_Mg_ha = agg(d$stock_Mg_ha)[match(ids, sort(unique(d$unit_id)))],
             pct_estimated = agg(d$pct_estimated)[match(ids, sort(unique(d$unit_id)))],
             row.names = NULL)
}

#' Area of a lon/lat polygon in m² (local flat-earth projection; good to well under 1% for
#' areas of a few km). Use a GIS for large or irregular boundaries.
polygon_area_m2 <- function(lon, lat) {
  lat0 <- mean(lat) * pi / 180; r <- 6371008.8
  x <- lon * pi / 180 * r * cos(lat0); y <- lat * pi / 180 * r
  abs(sum(x * c(y[-1], y[1]) - c(x[-1], x[1]) * y)) / 2
}

INTERVAL_NOTE <- paste(
  "The interval describes sampling variation among sampling units only. It does not include",
  "laboratory error, uncertainty in the LOI-to-carbon conversion, uncertainty in the estimated",
  "(extrapolated) part of each core, error in the boundary or stratum areas, or bias from cores",
  "that did not recover the full profile.")

#' Area estimate matching the design.
#'   design = "exploratory" — convenience or opportunistic sampling: mean × area, spread among
#'            units shown descriptively, NO probability interval.
#'   design = "srs"         — simple random (or systematic random) sampling of the whole area.
#'   design = "stratified"  — random sampling within strata; areas weight the strata.
#' Areas in m², stocks in Mg C/ha, totals in Mg C.
estimate_area <- function(units, design = c("exploratory", "srs", "stratified"), area_m2 = NULL,
                          strata_areas_m2 = NULL, plot_area_m2 = 100, conf = 0.90, target = 0.20) {
  design <- match.arg(design)
  res <- list(design = design, conf = conf, target = target, notes = character(0))
  v <- units$stock_Mg_ha
  if (design %in% c("exploratory", "srs")) {
    if (is.null(area_m2)) stop("area_m2 is required for this design.")
    n <- length(v); ha <- area_m2 / 10000
    res$area_ha <- ha; res$n_units <- n; res$mean_Mg_ha <- mean(v)
    res$sd_among_units <- if (n > 1) stats::sd(v) else NA_real_
    res$total_Mg_C <- mean(v) * ha
    res$by_stratum <- NULL
    if (design == "exploratory") {
      res$range <- range(v)
      res$notes <- c(res$notes, paste("Exploratory: the sampling units were not selected with known",
        "probabilities, so no confidence interval is reported. The spread among units is descriptive",
        "only; it does not tell you how close the mean is to the meadow's true value."))
      return(res)
    }
    if (n < 2) { res$notes <- c(res$notes, "Only one sampling unit: no interval can be estimated."); return(res) }
    N <- area_m2 / plot_area_m2
    se <- sqrt((1 - n / N) * stats::var(v) / n)
    tq <- stats::qt(1 - (1 - conf) / 2, df = n - 1)
    res$se_Mg_ha <- se; res$df <- n - 1
    res$ci_Mg_ha <- mean(v) + c(-1, 1) * tq * se
    res$ci_total_Mg_C <- res$ci_Mg_ha * ha
    res$relative_margin <- tq * se / mean(v)
    res$notes <- c(res$notes, INTERVAL_NOTE)
    return(res)
  }
  # ---- stratified
  if (is.null(strata_areas_m2)) stop("strata_areas_m2 is required for a stratified design.")
  if (any(is.na(units$stratum))) stop("Every sampling unit needs a stratum for a stratified design.")
  unknown <- setdiff(unique(units$stratum), names(strata_areas_m2))
  if (length(unknown)) stop("Stratum not listed in STRATUM_AREAS_M2: ", paste(unknown, collapse = ", "))
  nh <- table(factor(units$stratum, levels = names(strata_areas_m2)))
  by <- data.frame(stratum = names(strata_areas_m2), area_ha = as.numeric(strata_areas_m2) / 10000,
                   n_units = as.integer(nh), row.names = NULL)
  by$mean_Mg_ha <- vapply(by$stratum, function(h) if (any(units$stratum == h)) mean(v[units$stratum == h]) else NA_real_, 0)
  by$sd_Mg_ha <- vapply(by$stratum, function(h) { z <- v[units$stratum == h]; if (length(z) > 1) stats::sd(z) else NA_real_ }, 0)
  sampled <- by$n_units > 0
  if (any(!sampled)) res$notes <- c(res$notes, sprintf(
    "Unsampled strata excluded: %s (%.2f ha). The estimate and total cover the sampled strata only.",
    paste(by$stratum[!sampled], collapse = ", "), sum(by$area_ha[!sampled])))
  b <- by[sampled, ]
  W <- b$area_ha / sum(b$area_ha)
  res$by_stratum <- by
  res$area_ha <- sum(b$area_ha); res$excluded_area_ha <- sum(by$area_ha[!sampled])
  res$n_units <- sum(b$n_units)
  res$mean_Mg_ha <- sum(W * b$mean_Mg_ha)
  res$total_Mg_C <- res$mean_Mg_ha * res$area_ha
  if (any(b$n_units < 2)) {
    res$notes <- c(res$notes, sprintf(
      "Stratum %s has only one sampling unit, so its variance — and the overall interval — cannot be estimated. Point estimate only.",
      paste(b$stratum[b$n_units < 2], collapse = ", ")))
    return(res)
  }
  # Established implementation: survey::svydesign (Lumley). Hand formula kept as a check.
  u <- units[units$stratum %in% b$stratum, ]
  u$N_h <- (strata_areas_m2[u$stratum]) / plot_area_m2
  des <- survey::svydesign(ids = ~1, strata = ~stratum, fpc = ~N_h, data = u)
  sv <- survey::svymean(~stock_Mg_ha, des)
  df <- survey::degf(des)
  se <- as.numeric(survey::SE(sv))
  Nh <- b$area_ha * 10000 / plot_area_m2
  se_hand <- sqrt(sum(W^2 * (1 - b$n_units / Nh) * b$sd_Mg_ha^2 / b$n_units))
  if (abs(se - se_hand) > 1e-8 * max(1, se)) stop("Stratified SE disagrees with the hand formula — please report this.")
  tq <- stats::qt(1 - (1 - conf) / 2, df = df)
  res$se_Mg_ha <- se; res$df <- df
  res$ci_Mg_ha <- res$mean_Mg_ha + c(-1, 1) * tq * se
  res$ci_total_Mg_C <- res$ci_Mg_ha * res$area_ha
  res$relative_margin <- tq * se / res$mean_Mg_ha
  res$notes <- c(res$notes, INTERVAL_NOTE)
  res
}

#' Plain-language one-line result.
describe_estimate <- function(res, depth_cm) {
  base <- sprintf("0–%g cm: mean %.1f Mg C/ha over %.2f ha → %.0f Mg C (%d sampling units, %s design).",
                  depth_cm, res$mean_Mg_ha, res$area_ha, res$total_Mg_C, res$n_units, res$design)
  if (!is.null(res$ci_Mg_ha))
    base <- paste(base, sprintf("%g%% interval %.1f–%.1f Mg C/ha (±%.0f%% of the mean; target ±%.0f%%: %s).",
                                100 * res$conf, res$ci_Mg_ha[1], res$ci_Mg_ha[2], 100 * res$relative_margin,
                                100 * res$target, if (res$relative_margin <= res$target) "met" else "not met"))
  base
}

# ---------------------------------------------------------------------------- figures
plot_curves <- function(curves) {
  d <- rbind(
    data.frame(core_id = curves$core_id, depth = curves$cell_top_cm + 0.5,
               density = 1000 * curves$measured_g_cm2 / CELL_CM, part = "measured")[curves$measured_g_cm2 > 0, ],
    data.frame(core_id = curves$core_id, depth = curves$cell_top_cm + 0.5,
               density = 1000 * curves$estimated_g_cm2 / CELL_CM, part = "estimated")[curves$estimated_g_cm2 > 0, ])
  ggplot(d, aes(x = density, y = depth, colour = core_id, linetype = part)) +
    geom_path() + scale_y_reverse(limits = c(100, 0)) +
    scale_linetype_manual(values = c(measured = "solid", estimated = "22")) +
    labs(x = "Carbon density (mg C/cm³)", y = "Depth, in situ (cm)", colour = "Core", linetype = NULL,
         title = "Carbon curves used for the area estimate",
         subtitle = "Solid = measured (each cm takes its slice's value). Dashed = estimated below the core.") +
    theme_bw(base_size = 11)
}

#' Reporting area, sampling locations and (if any) strata. One value per stratum or meadow
#' is written in the legend — there is deliberately no surface between points.
plot_area_map <- function(boundary, cores, res, depth_cm, strata_polygons = NULL, hypothetical = FALSE) {
  lab <- if (is.null(res$by_stratum)) sprintf("Area mean 0–%g cm: %.1f Mg C/ha", depth_cm, res$mean_Mg_ha) else
    paste(sprintf("%s: %s Mg C/ha", res$by_stratum$stratum,
                  ifelse(is.na(res$by_stratum$mean_Mg_ha), "not sampled", sprintf("%.1f", res$by_stratum$mean_Mg_ha))),
          collapse = " · ")
  p <- ggplot()
  if (!is.null(strata_polygons))
    p <- p + geom_polygon(data = strata_polygons, aes(x = longitude, y = latitude, group = stratum, fill = stratum),
                          alpha = 0.25, colour = NA)
  p <- p + geom_polygon(data = boundary, aes(x = longitude, y = latitude, group = 1), fill = NA,
                        colour = "grey20", linetype = if (hypothetical) "dashed" else "solid") +
    geom_point(data = cores, aes(x = longitude, y = latitude), colour = "#B2182B", size = 2.5) +
    geom_text(data = cores, aes(x = longitude, y = latitude, label = core_id), vjust = -1, size = 3) +
    coord_quickmap() +
    labs(x = "Longitude", y = "Latitude", title = if (hypothetical) "Reporting area (HYPOTHETICAL boundary)" else "Reporting area",
         subtitle = lab, caption = "One value per area or stratum. Points show where cores were taken; nothing is interpolated between them.") +
    theme_bw(base_size = 11)
  p
}
