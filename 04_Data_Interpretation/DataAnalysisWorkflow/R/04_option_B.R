# 04_option_B.R — Option B: what do our measurements imply for this meadow or study area?
#
# Step 1 — a 1 cm "carbon curve" for every complete core, 0–100 cm:
#   * within the measured core, each 1 cm takes the carbon of the slice(s) that cover it
#     (step-fill, in-situ depths). The curve's measured part adds up to exactly the measured
#     core stock — nothing is smoothed away or added (checked every run);
#   * below the base of the core, carbon density is ESTIMATED with a decay curve that levels
#     off at a floor (stats::SSasymp), fitted to that core's measured carbon density.
#     Fallbacks, in order: a curve fitted to all cores in the same stratum; then the mean
#     carbon density of the deepest 5 cm measured, held constant. A fit is only accepted if it
#     converges, actually decays (starts above its floor), and its floor is between zero and
#     the highest measured density.
#   Every increment reports how much of it is measured and how much is estimated.
# Step 2 — one value per sampling unit (plot), then an area estimate that matches the design.

CELL_CM <- 1

#' Asymptotic decay of carbon density with depth: density = Asym + (R0 - Asym) * exp(-exp(lrc) * depth).
#' Returns the nls fit, or a short reason (character) why no acceptable decay curve was found.
fit_decay <- function(depth, density, max_allowed, min_points = 4) {
  if (length(unique(depth)) < max(4, min_points)) return("too few slices")   # 3 parameters + 1 to spare
  fit <- tryCatch(stats::nls(density ~ SSasymp(depth, Asym, R0, lrc),
                             data = data.frame(depth = depth, density = density)),
                  error = function(e) NULL, warning = function(w) NULL)
  if (is.null(fit)) return("curve did not converge")
  cf <- stats::coef(fit)
  if (!all(is.finite(cf))) return("curve did not converge")
  if (cf[["R0"]] <= cf[["Asym"]]) return("carbon does not decline with depth")
  if (cf[["Asym"]] < 0) return("curve falls below zero")
  if (cf[["Asym"]] > max_allowed) return("floor above the highest measured value")
  fit
}
is_fit <- function(x) inherits(x, "nls")

slice_density <- function(x) x$stock_g_cm2 / (x$insitu_bottom_cm - x$insitu_top_cm)

#' 1 cm carbon curve for every complete core. Returns one row per core per cm, with
#' attr "methods": how each core's estimated part was made.
carbon_curves <- function(chk, max_depth = 100, min_slices = 4) {
  s <- chk$slices
  cores <- chk$cores[chk$cores$status == "Complete", ]
  s <- s[s$core_id %in% cores$core_id, ]
  s$mid <- (s$insitu_top_cm + s$insitu_bottom_cm) / 2
  s$dens <- slice_density(s)
  grp <- ifelse(is.na(s$stratum) | s$stratum == "", "all cores (unstratified)", s$stratum)
  pooled <- lapply(split(s, grp), function(x) fit_decay(x$mid, x$dens, max(x$dens), min_slices))

  out <- list(); methods <- list()
  for (id in cores$core_id) {
    x <- s[s$core_id == id, ]
    g <- grp[s$core_id == id][1]
    base <- max(x$insitu_bottom_cm)
    top <- seq(0, max_depth - CELL_CM, by = CELL_CM)
    meas <- vapply(top, function(a) sum(x$stock_g_cm2 * overlap_cm(x$insitu_top_cm, x$insitu_bottom_cm,
                                                                     a, a + CELL_CM) /
                                          (x$insitu_bottom_cm - x$insitu_top_cm)), 0)
    if (base <= max_depth + 1e-9 && abs(sum(meas) - sum(x$stock_g_cm2)) > 1e-9 * max(1, sum(x$stock_g_cm2)))
      stop("Step-fill did not conserve carbon for core ", id, " — please report this.")
    fit <- if (nrow(x) >= min_slices) fit_decay(x$mid, x$dens, max(x$dens), min_slices) else "too few slices"
    why <- c(core = if (is_fit(fit)) "" else fit, pooled = if (is_fit(pooled[[g]])) "" else pooled[[g]])
    method <- "this core's decay curve"
    if (!is_fit(fit)) {
      fit <- pooled[[g]]
      method <- if (g == "all cores (unstratified)") "decay curve fitted to all cores" else
        sprintf("decay curve fitted to stratum %s", g)
    }
    deep_mean <- sum(x$stock_g_cm2 * overlap_cm(x$insitu_top_cm, x$insitu_bottom_cm, base - 5, base) /
                       (x$insitu_bottom_cm - x$insitu_top_cm)) / min(5, base)
    if (!is_fit(fit)) {
      method <- "constant (mean of deepest 5 cm)"
      f <- function(d) rep(deep_mean, length(d))
    } else {
      f <- function(d) stats::predict(fit, newdata = data.frame(depth = d))
    }
    if (base >= max_depth) method <- "none needed"
    lo <- pmax(top, base); hi <- top + CELL_CM
    gap_len <- pmax(0, hi - lo)
    est <- ifelse(gap_len > 0, gap_len * f((lo + hi) / 2), 0)
    out[[id]] <- data.frame(core_id = id, plot_id = x$plot_id[1], stratum = x$stratum[1],
                            cell_top_cm = top, cell_bottom_cm = top + CELL_CM,
                            measured_g_cm2 = meas, estimated_g_cm2 = est,
                            core_base_cm = base, extrapolation = method)
    methods[[id]] <- data.frame(core_id = id, core_base_cm = base, extrapolation = method,
                                why_not_core_curve = if (method == "this core's decay curve" || method == "none needed") "" else why[["core"]],
                                why_not_pooled_curve = if (grepl("^constant", method)) why[["pooled"]] else "",
                                floor_mg_cm3 = if (!is_fit(fit) || method == "none needed") NA_real_ else
                                  1000 * stats::coef(fit)[["Asym"]])
  }
  r <- do.call(rbind, out); rownames(r) <- NULL
  attr(r, "methods") <- do.call(rbind, methods)
  r
}

#' Measured and estimated stock in each standard increment, per core.
curve_increments <- function(curves, breaks = STANDARD_INCREMENTS) {
  r <- do.call(rbind, lapply(split(curves, curves$core_id), function(x) {
    do.call(rbind, lapply(seq_len(length(breaks) - 1), function(k) {
      y <- x[x$cell_top_cm >= breaks[k] - 1e-9 & x$cell_bottom_cm <= breaks[k + 1] + 1e-9, ]
      m <- sum(y$measured_g_cm2) * 100; e <- sum(y$estimated_g_cm2) * 100
      data.frame(core_id = x$core_id[1], plot_id = x$plot_id[1], stratum = x$stratum[1],
                 increment = paste0(breaks[k], "–", breaks[k + 1], " cm"),
                 depth_top_cm = breaks[k], depth_bottom_cm = breaks[k + 1],
                 measured_Mg_ha = m, estimated_Mg_ha = e, stock_Mg_ha = m + e,
                 pct_estimated = if (m + e > 0) 100 * e / (m + e) else NA_real_)
    }))
  }))
  rownames(r) <- NULL
  r
}

#' Stock from the surface to each reporting depth, split into measured and estimated parts.
curve_stocks <- function(curves, depths = c(15, 30, 50, 100)) {
  r <- do.call(rbind, lapply(split(curves, curves$core_id), function(x) {
    do.call(rbind, lapply(depths, function(D) {
      y <- x[x$cell_bottom_cm <= D + 1e-9, ]
      m <- sum(y$measured_g_cm2) * 100; e <- sum(y$estimated_g_cm2) * 100
      data.frame(core_id = x$core_id[1], plot_id = x$plot_id[1], stratum = x$stratum[1],
                 depth_cm = D, measured_Mg_ha = m, estimated_Mg_ha = e, stock_Mg_ha = m + e,
                 pct_estimated = if (m + e > 0) 100 * e / (m + e) else NA_real_,
                 extrapolation = x$extrapolation[1])
    }))
  }))
  rownames(r) <- NULL
  r
}

#' One value per sampling unit. With unit = "plot", cores sharing a Plot ID are averaged
#' first: they are not independent samples of the area.
unit_values <- function(stocks, depth_cm, unit = c("plot", "core")) {
  unit <- match.arg(unit)
  d <- stocks[stocks$depth_cm == depth_cm, ]
  if (unit == "core") {
    d$unit_id <- d$core_id
  } else {
    if (any(is.na(d$plot_id) | d$plot_id == ""))
      stop("Every core needs a Plot ID when the sampling unit is the plot (Sheet 2, column A).")
    d$unit_id <- d$plot_id
  }
  ids <- sort(unique(d$unit_id))
  strata <- lapply(ids, function(i) unique(d$stratum[d$unit_id == i]))
  bad <- ids[vapply(strata, function(z) length(z) > 1, logical(1))]
  if (length(bad))
    stop("Cores in the same plot have different (or partly missing) strata: ", paste(bad, collapse = ", "),
         ". Fix the Stratum column on Sheet 2.")
  data.frame(unit_id = ids,
             stratum = vapply(strata, function(z) as.character(z[1]), ""),
             n_cores = vapply(ids, function(i) sum(d$unit_id == i), 0L),
             measured_Mg_ha = vapply(ids, function(i) mean(d$measured_Mg_ha[d$unit_id == i]), 0),
             estimated_Mg_ha = vapply(ids, function(i) mean(d$estimated_Mg_ha[d$unit_id == i]), 0),
             stock_Mg_ha = vapply(ids, function(i) mean(d$stock_Mg_ha[d$unit_id == i]), 0),
             row.names = NULL)
}

#' Area of a lon/lat polygon in m² (local flat-earth projection; good to well under 1% for
#' areas of a few km). Use a GIS for large or irregular boundaries.
polygon_area_m2 <- function(lon, lat) {
  lat0 <- mean(lat) * pi / 180; r <- 6371008.8
  x <- lon * pi / 180 * r * cos(lat0); y <- lat * pi / 180 * r
  abs(sum(x * c(y[-1], y[1]) - c(x[-1], x[1]) * y)) / 2
}

#' TRUE for each point inside the polygon (ray casting; points exactly on an edge may go either way).
point_in_polygon <- function(px, py, vx, vy) {
  n <- length(vx)
  vapply(seq_along(px), function(k) {
    inside <- FALSE; j <- n
    for (i in seq_len(n)) {
      if (((vy[i] > py[k]) != (vy[j] > py[k])) &&
          (px[k] < (vx[j] - vx[i]) * (py[k] - vy[i]) / (vy[j] - vy[i]) + vx[i])) inside <- !inside
      j <- i
    }
    inside
  }, logical(1))
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
    res$pct_estimated <- 100 * mean(units$estimated_Mg_ha) / mean(v)
    res$by_stratum <- NULL
    if (design == "exploratory") {
      res$range <- range(v)
      res$notes <- c(res$notes, paste("Exploratory: the sampling units were not selected with known",
        "probabilities, so no confidence interval is reported. The spread among units is descriptive",
        "only; it does not tell you how close the mean is to the area's true value."))
      return(res)
    }
    if (n < 2) { res$notes <- c(res$notes, "Only one sampling unit: no interval can be estimated."); return(res) }
    N <- area_m2 / plot_area_m2
    if (n > N) stop(sprintf("%d sampling units of %g m² cannot fit in %.0f m². Check PLOT_AREA_M2 and the boundary.",
                            n, plot_area_m2, area_m2))
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
  by$estimated_Mg_ha <- vapply(by$stratum, function(h) if (any(units$stratum == h))
    mean(units$estimated_Mg_ha[units$stratum == h]) else NA_real_, 0)
  Nh_all <- by$area_ha * 10000 / plot_area_m2
  if (any(by$n_units > Nh_all))
    stop("A stratum has more sampling units than plots of PLOT_AREA_M2 fit in its area: ",
         paste(by$stratum[by$n_units > Nh_all], collapse = ", "))
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
  res$pct_estimated <- 100 * sum(W * b$estimated_Mg_ha) / res$mean_Mg_ha
  if (any(b$n_units < 2)) {
    res$notes <- c(res$notes, sprintf(
      "Stratum %s has only one sampling unit, so its variance — and the overall interval — cannot be estimated. Point estimate only.",
      paste(b$stratum[b$n_units < 2], collapse = ", ")))
    return(res)
  }
  if (!requireNamespace("survey", quietly = TRUE))
    stop("A stratified estimate needs the 'survey' package: install.packages(\"survey\")")
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
  if (abs(as.numeric(stats::coef(sv)) - res$mean_Mg_ha) > 1e-8 * max(1, res$mean_Mg_ha))
    stop("Stratified mean disagrees with the hand formula — please report this.")
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
  base <- sprintf("0–%g cm: mean %.1f Mg C/ha over %.2f ha → %.0f Mg C (%d sampling units, %s design; %.0f%% of it estimated below the cores).",
                  depth_cm, res$mean_Mg_ha, res$area_ha, res$total_Mg_C, res$n_units, res$design,
                  res$pct_estimated)
  if (!is.null(res$ci_Mg_ha))
    base <- paste(base, sprintf("%g%% interval %.1f–%.1f Mg C/ha (±%.0f%% of the mean; target ±%.0f%%: %s).",
                                100 * res$conf, res$ci_Mg_ha[1], res$ci_Mg_ha[2], 100 * res$relative_margin,
                                100 * res$target, if (res$relative_margin <= res$target) "met" else "not met"))
  base
}

# ---------------------------------------------------------------------------- figures
plot_curves <- function(curves) {
  # Density, not stock: in the 1 cm cell holding a core's base, part is measured and part
  # estimated, so each part is divided by its own length.
  m_len <- pmax(0, pmin(curves$core_base_cm, curves$cell_bottom_cm) - curves$cell_top_cm)
  e_len <- CELL_CM - m_len
  d <- rbind(
    data.frame(core_id = curves$core_id, depth = curves$cell_top_cm + m_len / 2,
               density = 1000 * curves$measured_g_cm2 / m_len, part = "measured")[m_len > 1e-9, ],
    data.frame(core_id = curves$core_id, depth = curves$cell_bottom_cm - e_len / 2,
               density = 1000 * curves$estimated_g_cm2 / e_len, part = "estimated")[e_len > 1e-9, ])
  ggplot(d, aes(x = density, y = depth, colour = core_id, linetype = part)) +
    geom_path() + scale_y_reverse(limits = c(100, 0)) +
    scale_linetype_manual(values = c(measured = "solid", estimated = "22")) +
    labs(x = "Carbon density (mg C/cm³)", y = "Depth, in situ (cm)", colour = "Core", linetype = NULL,
         title = "Carbon curves used for the area estimate",
         subtitle = "Solid: measured (each cm takes its slice's value).\nDashed: estimated below the base of the core.") +
    theme_bw(base_size = 11)
}

#' Reporting area, sampling locations and (if any) strata. One value per stratum or area is
#' given in the legend — there is deliberately no surface between points.
plot_area_map <- function(boundary, cores, res, depth_cm, strata_polygons = NULL, hypothetical = FALSE) {
  value_lab <- function(h) {
    m <- res$by_stratum$mean_Mg_ha[res$by_stratum$stratum == h]
    sprintf("%s: %s", h, if (!length(m) || is.na(m)) "not sampled — excluded" else sprintf("%.1f Mg C/ha", m))
  }
  # Label sampling units (plots), not cores: cores in one plot are one observation.
  pid <- ifelse(is.na(cores$plot_id), cores$core_id, cores$plot_id)
  plots <- do.call(rbind, lapply(split(cores, pid), function(z)
    data.frame(longitude = mean(z$longitude), latitude = max(z$latitude),
               label = if (nrow(z) > 1) sprintf("%s (%d cores)", z$plot_id[1], nrow(z)) else
                 if (is.na(z$plot_id[1])) z$core_id[1] else z$plot_id[1])))
  p <- ggplot()
  if (!is.null(strata_polygons) && !is.null(res$by_stratum)) {
    sp <- strata_polygons
    sp$label <- vapply(sp$stratum, value_lab, "")
    p <- p + geom_polygon(data = sp, aes(x = longitude, y = latitude, group = stratum, fill = label),
                          alpha = 0.35, colour = "grey40", linewidth = 0.3) +
      labs(fill = sprintf("Mean, 0–%g cm", depth_cm))
  } else {
    lab <- sprintf("Whole area: %.1f Mg C/ha", res$mean_Mg_ha)
    p <- p + geom_polygon(data = cbind(boundary, label = lab),
                          aes(x = longitude, y = latitude, group = 1, fill = label), alpha = 0.2) +
      scale_fill_manual(values = "#4D9221") + labs(fill = sprintf("Mean, 0–%g cm", depth_cm))
  }
  p + geom_polygon(data = boundary, aes(x = longitude, y = latitude, group = 1), fill = NA,
                   colour = "grey20", linetype = if (hypothetical) "dashed" else "solid") +
    geom_point(data = cores, aes(x = longitude, y = latitude), colour = "#B2182B", size = 2.5) +
    geom_text(data = plots, aes(x = longitude, y = latitude, label = label), vjust = -1, size = 3) +
    coord_quickmap() +
    labs(x = "Longitude", y = "Latitude",
         title = if (hypothetical) "Reporting area — HYPOTHETICAL boundary" else "Reporting area",
         caption = "One value per area or stratum. Points show where cores were taken;\nnothing is interpolated between them.") +
    theme_bw(base_size = 11) + theme(legend.position = "bottom", legend.direction = "vertical")
}
