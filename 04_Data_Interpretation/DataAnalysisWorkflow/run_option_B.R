# run_option_B.R — "What do our measurements imply for this meadow or study area?"
#   source("run_option_B.R")
# Uses the same checked core stocks as Option A, extends each core to 100 cm (measured part
# kept exactly, estimated part shown separately), makes one value per sampling unit, and
# estimates the mean and total for the reporting area in the way the sampling design allows.
# Writes tables and figures to <OUTPUT_DIR>/option_B/ and renders the report.

# ── Shared foundation: read, check, core stocks (run_checks.R, as for Option A) ─
source("run_checks.R")
if (!ready) stop("No complete cores yet — fix what the checks above list, save the workbook, and run again.", call. = FALSE)
out <- file.path(OUTPUT_DIR, "option_B")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# ── The reporting area ─────────────────────────────────────────────────────────
if (is.null(BOUNDARY_FILE))
  stop("Option B needs a reporting boundary: save it as a CSV of longitude, latitude vertices (e.g. ",
       "my_data/boundary.csv) and set BOUNDARY_FILE in ", SETTINGS_FILE, ".", call. = FALSE)
if (!file.exists(BOUNDARY_FILE))
  stop("Boundary file not found: ", BOUNDARY_FILE, ". Check the name in BOUNDARY_FILE (", SETTINGS_FILE,
       ") against the file in your folder.", call. = FALSE)
boundary <- utils::read.csv(BOUNDARY_FILE)
if (!all(c("longitude", "latitude") %in% names(boundary)))
  stop("The boundary file needs columns 'longitude' and 'latitude'.")
area_m2 <- polygon_area_m2(boundary$longitude, boundary$latitude)
complete <- chk$cores[chk$cores$status == "Complete", ]
if (any(is.na(complete$latitude) | is.na(complete$longitude)))
  stop("Every core used for an area estimate needs a latitude and longitude (Sheet 2).")
inside <- point_in_polygon(complete$longitude, complete$latitude, boundary$longitude, boundary$latitude)
if (!all(inside))
  stop("These cores lie outside the reporting boundary: ", paste(complete$core_id[!inside], collapse = ", "),
       ". Fix the coordinates or the boundary — cores outside the area cannot represent it.")
strata_polygons <- if (!is.null(STRATA_FILE)) utils::read.csv(STRATA_FILE) else NULL
if (DESIGN == "stratified" && !is.null(STRATUM_AREAS_M2) &&
    abs(sum(STRATUM_AREAS_M2) - area_m2) > 0.02 * area_m2)
  message(sprintf("Note: the stratum areas add up to %.2f ha but the boundary encloses %.2f ha. ",
                  sum(STRATUM_AREAS_M2) / 1e4, area_m2 / 1e4),
          "The estimate uses the stratum areas; check they describe the same area.")

# ── Step 1: carbon curves to 100 cm ────────────────────────────────────────────
curves <- carbon_curves(chk, max_depth = 100, min_slices = EXTRAP_MIN_SLICES)
methods_used <- attr(curves, "methods")
cinc <- curve_increments(curves)
stocks <- curve_stocks(curves, depths = STANDARD_INCREMENTS[-1])

# ── Which depths can be reported ───────────────────────────────────────────────
support <- depth_support(curves)
D_measured <- measured_common_depth(curves)
if (is.na(D_measured)) stop("Some cores are shorter than 15 cm, the shallowest standard depth: ",
                            paste(support$too_short[support$depth_cm == 15], collapse = ", "))
# The headline is a depth every core measured; a deeper depth is a labelled scenario.
D <- if (is.null(REPORT_DEPTH_CM)) D_measured else REPORT_DEPTH_CM
if (support$status[support$depth_cm == D] == "not supported")
  stop(sprintf("0–%g cm cannot be reported: cores %s are shorter than %g cm (see DEPTH_SUPPORT).", D,
               support$too_short[support$depth_cm == D], support$min_core_cm[support$depth_cm == D]))
if (D > D_measured) message(sprintf("Note: 0–%g cm is partly estimated below the cores; the measured common depth is 0–%g cm.",
                                    D, D_measured))
D_scen <- if (exists("SCENARIO_DEPTH_CM") && !is.null(SCENARIO_DEPTH_CM) && SCENARIO_DEPTH_CM > D) SCENARIO_DEPTH_CM else NA_real_

# ── Step 2: one value per sampling unit, then the area estimate ─────────────────
frame <- exists("PLOTS_ARE_SAMPLING_FRAME") && isTRUE(PLOTS_ARE_SAMPLING_FRAME)
estimate_at <- function(depth) {
  u <- unit_values(stocks, depth, unit = SAMPLING_UNIT)
  list(units = u, res = estimate_area(u, design = DESIGN, area_m2 = area_m2, strata_areas_m2 = STRATUM_AREAS_M2,
                                      plot_area_m2 = PLOT_AREA_M2, conf = CONF_LEVEL, target = TARGET_MARGIN,
                                      plots_are_frame = frame))
}
head_est <- estimate_at(D); units <- head_est$units; res <- head_est$res
scen <- if (!is.na(D_scen) && support$status[support$depth_cm == D_scen] != "not supported") estimate_at(D_scen) else NULL
all_depths <- do.call(rbind, lapply(support$depth_cm, function(d) {
  st <- support[support$depth_cm == d, ]
  e <- if (st$status == "not supported") NULL else estimate_at(d)$res
  data.frame(depth = sprintf("0–%g cm", d), depth_cm = d, status = st$status, too_short = st$too_short,
             min_core_cm = st$min_core_cm,
             mean_Mg_ha = if (is.null(e)) NA_real_ else e$mean_Mg_ha,
             total_Mg_C = if (is.null(e)) NA_real_ else e$total_Mg_C,
             pct_estimated = if (is.null(e)) NA_real_ else e$pct_estimated,
             ci_low_Mg_ha = if (is.null(e) || is.null(e$ci_Mg_ha)) NA_real_ else e$ci_Mg_ha[1],
             ci_high_Mg_ha = if (is.null(e) || is.null(e$ci_Mg_ha)) NA_real_ else e$ci_Mg_ha[2])
}))

# ── Write outputs ──────────────────────────────────────────────────────────────
utils::write.csv(cinc, file.path(out, "increments_measured_estimated.csv"), row.names = FALSE)
utils::write.csv(stocks, file.path(out, "core_stocks_to_depth.csv"), row.names = FALSE)
utils::write.csv(units, file.path(out, sprintf("sampling_units_0_%gcm.csv", D)), row.names = FALSE)
utils::write.csv(all_depths, file.path(out, "area_estimate_all_depths.csv"), row.names = FALSE)
ggsave(file.path(out, "carbon_curves.png"), plot_curves(curves), width = 6, height = 5, dpi = 150)
ggsave(file.path(out, "area_map.png"),
       plot_area_map(boundary, complete, res, D, strata_polygons, BOUNDARY_IS_HYPOTHETICAL),
       width = 6, height = 6.5, dpi = 150)
ggsave(file.path(out, "measured_estimated_share.png"), plot_share_bar(all_depths), width = 6, height = 3, dpi = 150)

settings_used <- list(WORKBOOK = WORKBOOK, DESIGN = DESIGN, BOUNDARY_FILE = BOUNDARY_FILE,
                      BOUNDARY_IS_HYPOTHETICAL = BOUNDARY_IS_HYPOTHETICAL, STRATUM_AREAS_M2 = STRATUM_AREAS_M2,
                      PLOT_AREA_M2 = PLOT_AREA_M2, SAMPLING_UNIT = SAMPLING_UNIT,
                      REPORT_DEPTH_CM = D, MEASURED_DEPTH_CM = D_measured, SCENARIO_DEPTH_CM = D_scen,
                      PLOTS_ARE_SAMPLING_FRAME = frame, CONF_LEVEL = CONF_LEVEL,
                      TARGET_MARGIN = TARGET_MARGIN, EXTRAP_MIN_SLICES = EXTRAP_MIN_SLICES,
                      DEPTH_SUPPORT = DEPTH_SUPPORT)
saveRDS(list(project = PROJECT, settings = settings_used, chk = chk, checks = checks, inc = inc,
             curves = curves, methods_used = methods_used, cinc = cinc, stocks = stocks, units = units,
             res = res, scenario = scen, support = support, all_depths = all_depths, area_m2 = area_m2,
             cross_check = cross_check_workbook(chk), figures = normalizePath(out)),
        file.path(out, "results.rds"))

cat("\n", describe_estimate(res, D), "\n", sep = "")
if (!is.null(scen)) cat("Deeper scenario — ", describe_estimate(scen$res, D_scen), "\n", sep = "")
for (n in res$notes) cat("• ", n, "\n", sep = "")
ns <- all_depths[all_depths$status == "not supported", ]
for (k in seq_len(nrow(ns))) cat(sprintf("• 0–%g cm not reported: %s shorter than %g cm.\n",
                                         ns$depth_cm[k], ns$too_short[k], ns$min_core_cm[k]))

# ── Report ─────────────────────────────────────────────────────────────────────
if (!requireNamespace("rmarkdown", quietly = TRUE) || !rmarkdown::pandoc_available()) {
  message("Report not rendered: it needs the rmarkdown package and pandoc (both come with RStudio). ",
          "The tables and figures above are in ", out, ".")
} else {
  results_file <- normalizePath(file.path(out, "results.rds"))   # before render() changes folder
  rmarkdown::render("report_option_B.Rmd", output_dir = out, quiet = TRUE, envir = new.env(),
                    params = list(results = results_file))
  cat("Report:", file.path(out, "report_option_B.html"), "\n")
}
