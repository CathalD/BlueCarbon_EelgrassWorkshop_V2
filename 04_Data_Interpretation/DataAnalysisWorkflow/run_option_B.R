# run_option_B.R — "What do our measurements imply for this meadow or study area?"
#   source("run_option_B.R")
# Uses the same checked core stocks as Option A, extends each core to 100 cm (measured part
# kept exactly, estimated part shown separately), makes one value per sampling unit, and
# estimates the mean and total for the reporting area in the way the sampling design allows.
# Writes tables and figures to outputs/option_B/ and renders the report.

if (!exists("SETTINGS_FILE")) SETTINGS_FILE <- Sys.getenv("SETTINGS_FILE", "settings.R")
source(SETTINGS_FILE)
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE)) source(f)
out <- if (exists("OUTPUT_DIR_B")) OUTPUT_DIR_B else file.path("outputs", "option_B")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# ── Shared foundation: read, check, core stocks (identical to Option A) ─────────
wb  <- read_workbook(WORKBOOK)
chk <- check_slices(wb)
checks <- print_check_report(check_report(chk))
if (!any(chk$cores$status == "Complete")) stop("No complete cores yet — see the checks above.")
inc <- increment_stocks(chk)
check_mass_conservation(chk, inc)

# ── The reporting area ─────────────────────────────────────────────────────────
if (is.null(BOUNDARY_FILE) || !file.exists(BOUNDARY_FILE))
  stop("Option B needs a reporting boundary: set BOUNDARY_FILE in ", SETTINGS_FILE, ".")
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

# ── Step 2: one value per sampling unit, then the area estimate ─────────────────
units <- unit_values(stocks, REPORT_DEPTH_CM, unit = SAMPLING_UNIT)
res <- estimate_area(units, design = DESIGN, area_m2 = area_m2, strata_areas_m2 = STRATUM_AREAS_M2,
                     plot_area_m2 = PLOT_AREA_M2, conf = CONF_LEVEL, target = TARGET_MARGIN)
all_depths <- do.call(rbind, lapply(STANDARD_INCREMENTS[-1], function(D) {
  u <- unit_values(stocks, D, unit = SAMPLING_UNIT)
  e <- estimate_area(u, design = DESIGN, area_m2 = area_m2, strata_areas_m2 = STRATUM_AREAS_M2,
                     plot_area_m2 = PLOT_AREA_M2, conf = CONF_LEVEL, target = TARGET_MARGIN)
  data.frame(depth = sprintf("0–%g cm", D), mean_Mg_ha = e$mean_Mg_ha, total_Mg_C = e$total_Mg_C,
             pct_estimated = e$pct_estimated,
             ci_low_Mg_ha = if (is.null(e$ci_Mg_ha)) NA_real_ else e$ci_Mg_ha[1],
             ci_high_Mg_ha = if (is.null(e$ci_Mg_ha)) NA_real_ else e$ci_Mg_ha[2])
}))

# ── Write outputs ──────────────────────────────────────────────────────────────
utils::write.csv(cinc, file.path(out, "increments_measured_estimated.csv"), row.names = FALSE)
utils::write.csv(stocks, file.path(out, "core_stocks_to_depth.csv"), row.names = FALSE)
utils::write.csv(units, file.path(out, sprintf("sampling_units_0_%gcm.csv", REPORT_DEPTH_CM)), row.names = FALSE)
utils::write.csv(all_depths, file.path(out, "area_estimate_all_depths.csv"), row.names = FALSE)
ggsave(file.path(out, "carbon_curves.png"), plot_curves(curves), width = 6, height = 5, dpi = 150)
ggsave(file.path(out, "area_map.png"),
       plot_area_map(boundary, complete, res, REPORT_DEPTH_CM, strata_polygons, BOUNDARY_IS_HYPOTHETICAL),
       width = 6, height = 6.5, dpi = 150)

settings_used <- list(WORKBOOK = WORKBOOK, DESIGN = DESIGN, BOUNDARY_FILE = BOUNDARY_FILE,
                      BOUNDARY_IS_HYPOTHETICAL = BOUNDARY_IS_HYPOTHETICAL, STRATUM_AREAS_M2 = STRATUM_AREAS_M2,
                      PLOT_AREA_M2 = PLOT_AREA_M2, SAMPLING_UNIT = SAMPLING_UNIT,
                      REPORT_DEPTH_CM = REPORT_DEPTH_CM, CONF_LEVEL = CONF_LEVEL,
                      TARGET_MARGIN = TARGET_MARGIN, EXTRAP_MIN_SLICES = EXTRAP_MIN_SLICES)
saveRDS(list(project = PROJECT, settings = settings_used, chk = chk, checks = checks, inc = inc,
             curves = curves, methods_used = methods_used, cinc = cinc, stocks = stocks, units = units,
             res = res, all_depths = all_depths, area_m2 = area_m2,
             cross_check = cross_check_workbook(chk), figures = normalizePath(out)),
        file.path(out, "results.rds"))

cat("\n", describe_estimate(res, REPORT_DEPTH_CM), "\n", sep = "")
for (n in res$notes) cat("• ", n, "\n", sep = "")

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
