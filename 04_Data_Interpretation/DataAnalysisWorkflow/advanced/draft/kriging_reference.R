# draft/kriging_reference.R
#
# PRESERVED, NOT RUN. This is the working ordinary + regression kriging
# implementation that used to be step 05, kept intact for the advanced
# spatial work described in ../06_advanced_spatial.R.
#
# It runs as-is (needs sf, gstat, sp) but produces maps the script itself
# disclaims at n = 6 — see the three preconditions in 06_advanced_spatial.R
# before using any output from it.

# Spatial interpolation of core carbon stocks across the study area.
#
#   A) Ordinary kriging (OK)      — spatial autocorrelation only
#   B) Regression kriging (RK)    — environmental covariates + spatial residuals
#
# Selected via ESTIMATION_METHODS in 00_config.R.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM PACKAGES — gstat (variogram(), fit.variogram(), krige()), sf, sp
#     gstat is the reference implementation of geostatistical interpolation in
#     R. Nothing here re-implements kriging.
#       Pebesma (2004) Computers & Geosciences 30:683-691.
#       Pebesma & Bivand (2023) Spatial Data Science. CRC Press.
#     Regression kriging follows Hengl, Heuvelink & Rossiter (2007)
#       Computers & Geosciences 33:1301-1315.
#
# ── ⚠ TEACHING SECTION — READ THIS BEFORE USING THE MAPS ─────────────────────
#   With only a handful of cores, an empirical variogram is NOT identifiable:
#   there are too few point-pairs to estimate range, sill and nugget. The maps
#   below are therefore ILLUSTRATIVE — they show how the method works and how
#   the answer responds to the information you feed it. They are not defensible
#   carbon maps. Treat every pattern as a hypothesis to test with more cores.
#
#   The teaching point of this script:
#       THE MODEL ONLY KNOWS WHAT YOU PROVIDE IT.
#   Ordinary kriging knows only "where". Regression kriging also knows "what
#   the place is like". Adding an informative covariate (water depth, distance
#   to shore, eelgrass density) sharpens the map; adding an uninformative one
#   does nothing. The covariate comparison below makes that visible.
#
# Requires: cores_harmonized from 03_depth_harmonization.R

library(dplyr)
library(ggplot2)

source("00_config.R")

if (!exists("cores_harmonized")) source("03_depth_harmonization.R")

for (pkg in c("sf", "gstat", "sp")) {
  if (!requireNamespace(pkg, quietly = TRUE))
    stop("Package '", pkg, "' is required. install.packages('", pkg, "')")
}
suppressPackageStartupMessages({library(sf); library(gstat); library(sp)})

run_ok <- "ok" %in% ESTIMATION_METHODS
run_rk <- "rk" %in% ESTIMATION_METHODS

if (!run_ok && !run_rk) {
  message("Neither 'ok' nor 'rk' in ESTIMATION_METHODS — skipping 05_kriging.R")
} else {

# ── 1. One value per core ────────────────────────────────────────────────────
core_stocks <- cores_harmonized |>
  group_by(core_id, stratum, latitude, longitude) |>
  summarise(total_stock = sum(carbon_stock_kg_m2, na.rm = TRUE), .groups = "drop")

# Attach covariates from the locations table
locations <- readr::read_csv(LOCATIONS_FILE, show_col_types = FALSE)
covars_available <- intersect(RK_COVARIATES, names(locations))
core_stocks <- core_stocks |>
  left_join(locations |> select(core_id, all_of(covars_available)), by = "core_id")

cat("Kriging", nrow(core_stocks), "cores\n")
cat("Covariates available:", paste(covars_available, collapse = ", "), "\n")

if (nrow(core_stocks) < 10) {
  cat("\n⚠ n =", nrow(core_stocks),
      "cores. Variogram estimation is unreliable below ~30 points.\n",
      "  Maps below are illustrative only.\n")
}

# ── 2. Project to a metre-based CRS ──────────────────────────────────────────
cores_sf  <- st_as_sf(core_stocks, coords = c("longitude", "latitude"), crs = 4326)
cores_utm <- st_transform(cores_sf, crs = UTM_EPSG)
xy <- st_coordinates(cores_utm)
cores_utm$x <- xy[, 1]; cores_utm$y <- xy[, 2]

sp_cores <- as(cores_utm, "Spatial")
utm_proj <- CRS(st_crs(UTM_EPSG)$proj4string)

# ── 3. Prediction grid ───────────────────────────────────────────────────────
bb  <- st_bbox(cores_utm)
buf <- 200; res_m <- 25

grid <- expand.grid(
  x = seq(bb["xmin"] - buf, bb["xmax"] + buf, by = res_m),
  y = seq(bb["ymin"] - buf, bb["ymax"] + buf, by = res_m)
)
cat("Prediction grid:", nrow(grid), "cells\n")

# Covariate surfaces for the grid.
# ⚠ In a real project these come from RASTERS — bathymetry, a shoreline
# distance surface, a mapped eelgrass density layer — read with terra::rast()
# and sampled with terra::extract(). Here they are interpolated from the core
# points purely so the worked example runs end to end.
sp_grid <- SpatialPoints(cbind(grid$x, grid$y), proj4string = utm_proj)
for (cv in covars_available) {
  f <- as.formula(paste(cv, "~ 1"))
  grid[[cv]] <- gstat::idw(f, locations = sp_cores, newdata = sp_grid,
                           idp = 2, debug.level = 0)$var1.pred
}

sp_grid_df <- SpatialPointsDataFrame(
  coords = cbind(grid$x, grid$y), data = grid, proj4string = utm_proj)

# Helper: fit a variogram, falling back to a pure-nugget model if fitting fails
safe_variogram <- function(formula, data, label) {
  vg <- tryCatch(variogram(formula, data = data), error = function(e) NULL)
  if (is.null(vg) || nrow(vg) < 3) {
    cat("  [", label, "] too few point-pairs — using pure nugget model\n", sep = "")
    return(list(vg = vg, fit = vgm(psill = var(data$total_stock), model = "Nug")))
  }
  init <- vgm(psill  = var(data$total_stock),
              model  = "Sph",
              range  = max(dist(coordinates(data))) / 2,
              nugget = var(data$total_stock) / 10)
  fit <- tryCatch(suppressWarnings(fit.variogram(vg, init)), error = function(e) NULL)
  if (is.null(fit) || any(fit$psill < 0)) {
    cat("  [", label, "] variogram fit failed — using pure nugget model\n", sep = "")
    fit <- vgm(psill = var(data$total_stock), model = "Nug")
  }
  list(vg = vg, fit = fit)
}

map_plot <- function(df, fill_col, title, subtitle, palette = "D") {
  ggplot(df, aes(x = x, y = y, fill = .data[[fill_col]])) +
    geom_raster() +
    scale_fill_viridis_c(option = palette, name = expression("kg C m"^{-2})) +
    geom_point(data = as.data.frame(st_coordinates(cores_utm)),
               aes(X, Y), inherit.aes = FALSE,
               shape = 21, fill = "white", colour = "red", size = 2.5) +
    coord_equal() + theme_bw(base_size = 12) +
    labs(title = title, subtitle = subtitle, x = "Easting (m)", y = "Northing (m)")
}

# ── 4. Ordinary kriging ──────────────────────────────────────────────────────
if (run_ok) {
  cat("\n── Ordinary kriging (knows only WHERE) ──\n")
  v_ok <- safe_variogram(total_stock ~ 1, sp_cores, "OK")
  ok   <- krige(total_stock ~ 1, locations = sp_cores,
                newdata = sp_grid_df, model = v_ok$fit, debug.level = 0)
  grid$ok_pred <- ok$var1.pred
  grid$ok_se   <- sqrt(ok$var1.var)

  print(map_plot(grid, "ok_pred", "Ordinary kriging — total carbon stock",
                 paste0(SITE_NAME, " — illustrative only (n = ", nrow(core_stocks), ")")))
  print(map_plot(grid, "ok_se", "Ordinary kriging — prediction standard error",
                 "Uncertainty grows with distance from cores", palette = "A"))
}

# ── 5. Regression kriging ────────────────────────────────────────────────────
# RK = (trend model on covariates) + (kriged residuals). Hengl et al. 2007.
if (run_rk && length(covars_available) > 0) {
  cat("\n── Regression kriging (knows WHERE *and* WHAT THE PLACE IS LIKE) ──\n")

  # 5a. How much does each covariate explain on its own?
  cat("\n  Covariate screening — variance in core stock explained (R²):\n")
  screening <- lapply(covars_available, function(cv) {
    m <- lm(as.formula(paste("total_stock ~", cv)), data = core_stocks)
    data.frame(covariate = cv,
               r_squared = summary(m)$r.squared,
               p_value   = tryCatch(summary(m)$coefficients[2, 4],
                                    error = function(e) NA_real_))
  }) |> bind_rows() |> arrange(desc(r_squared))
  print(as.data.frame(screening |> mutate(across(where(is.numeric), \(x) round(x, 3)))))
  cat("\n  ↑ This table IS the lesson: a covariate that carries no information\n",
      "    about carbon cannot improve the map, no matter how good the method.\n", sep = "")

  # 5b. Full trend model + kriged residuals
  rk_formula <- as.formula(paste("total_stock ~", paste(covars_available, collapse = " + ")))
  trend <- lm(rk_formula, data = core_stocks)
  cat("\n  Trend model R²:", round(summary(trend)$r.squared, 3),
      " (n =", nrow(core_stocks), ", predictors =", length(covars_available), ")\n")
  if (nrow(core_stocks) <= length(covars_available) + 2) {
    cat("  ⚠ Almost as many predictors as cores — this model is overfitted.\n",
        "    Shown to demonstrate the workflow, not to be trusted.\n", sep = "")
  }

  v_rk <- safe_variogram(rk_formula, sp_cores, "RK")
  rk   <- krige(rk_formula, locations = sp_cores,
                newdata = sp_grid_df, model = v_rk$fit, debug.level = 0)
  grid$rk_pred <- rk$var1.pred
  grid$rk_se   <- sqrt(rk$var1.var)

  print(map_plot(grid, "rk_pred", "Regression kriging — total carbon stock",
                 paste0("Covariates: ", paste(covars_available, collapse = ", "))))
  print(map_plot(grid, "rk_se", "Regression kriging — prediction standard error",
                 "Compare with the OK error map: covariates change what is uncertain",
                 palette = "A"))

  # 5c. Side-by-side comparison — the payoff of the teaching point
  if (run_ok) {
    comp <- data.frame(
      method = c("Ordinary kriging", "Regression kriging"),
      mean_prediction = c(mean(grid$ok_pred, na.rm = TRUE),
                          mean(grid$rk_pred, na.rm = TRUE)),
      mean_se         = c(mean(grid$ok_se,  na.rm = TRUE),
                          mean(grid$rk_se,  na.rm = TRUE))
    )
    cat("\n── OK vs RK across the grid ──\n")
    print(as.data.frame(comp |> mutate(across(where(is.numeric), \(x) round(x, 3)))))
    cat("\n  If RK's mean standard error is lower, the covariates carried real\n",
        "  information. If it is not, they did not — and that is a result too.\n", sep = "")
  }
} else if (run_rk) {
  message("No covariates found in ", LOCATIONS_FILE,
          " — skipping regression kriging. Expected any of: ",
          paste(RK_COVARIATES, collapse = ", "))
}

cat("\n⚠ Reminder: these maps are a teaching demonstration at n = ",
    nrow(core_stocks), ". Do not report them as carbon maps.\n", sep = "")

}  # end method guard
