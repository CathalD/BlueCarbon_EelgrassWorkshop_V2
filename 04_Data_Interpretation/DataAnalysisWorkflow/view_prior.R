# view_prior.R
# Look at the cores the prior is built from, on a map, next to your own.
#
# WHEN: after 02_derive_prior.R.
# WHY:  the prior is not a number someone handed you — it is a set of real
#       cores at real places. Before you let it influence your estimate, look
#       at where they are and how much they resemble your site. Click any core
#       for its stock and its four similarity indicators.
#
# Saves outputs/maps/prior_cores.html and opens it in the viewer/browser.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM A PACKAGE — leaflet (Cheng et al.), the standard R interface to
#     Leaflet.js. Nothing here draws a map by hand.

library(dplyr)
library(readr)
library(leaflet)
library(htmlwidgets)

source("00_config.R")

pc_file <- file.path(DATA_DIR, "prior_cores.csv")
if (!file.exists(pc_file))
  stop("Run 02_derive_prior.R first — ", pc_file, " does not exist.")

pc    <- read_csv(pc_file, show_col_types = FALSE)
prior <- read_csv(file.path(DATA_DIR, "prior_eelgrass_janousek.csv"),
                  show_col_types = FALSE)
mine  <- read_csv(LOCATIONS_FILE, show_col_types = FALSE)

cat("Prior candidates:", nrow(pc), " in the prior set:", sum(pc$in_prior_set), "\n")

# Your own cores' measured stock, if the pipeline has been run this session.
if (exists("cores_harmonized")) {
  my_stock <- cores_harmonized |>
    group_by(core_id) |>
    summarise(stock_MgC_ha = sum(carbon_stock_kg_m2 * frac_primary, na.rm = TRUE) * 10,
              .groups = "drop")
  mine <- mine |> left_join(my_stock, by = "core_id")
} else {
  mine$stock_MgC_ha <- NA_real_
  cat("(run run_pipeline.R first to show your own measured stocks)\n")
}

# One colour scale across BOTH sets — comparing two maps on two scales is how
# readers get misled.
all_stock <- c(pc$stock_MgC_ha, mine$stock_MgC_ha)
pal <- colorNumeric("viridis", all_stock, na.color = "#bbbbbb")

tick <- function(x) ifelse(x, "yes", "no")
popup_prior <- sprintf(
  paste0("<b>%s</b> — estuary %s (%s)<br/>",
         "<b>%.1f Mg C/ha</b> to %d cm<br/><hr style='margin:4px 0'/>",
         "distance %.0f km<br/>estuary type %s (%s)<br/>",
         "ecoregion %s (%s)<br/>climate %s (%s)<br/>",
         "<i>%s</i>"),
  pc$SampID, pc$Estuary, pc$State, pc$stock_MgC_ha, prior$depth_basis_cm,
  pc$dist_km,
  pc$EstType,    tick(pc$match_esttype),
  pc$Lvl1EcoReg, tick(pc$match_ecoreg),
  pc$KGzone,     tick(pc$match_climate),
  ifelse(pc$in_prior_set, "in the prior set", "not used — too unlike your site"))

popup_mine <- sprintf(
  "<b>%s</b> (your core)<br/>stratum %s<br/>%s",
  mine$core_id, mine$stratum,
  ifelse(is.finite(mine$stock_MgC_ha),
         sprintf("<b>%.1f Mg C/ha</b> to %d cm", mine$stock_MgC_ha, prior$depth_basis_cm),
         "not yet analysed"))

used   <- pc |> filter(in_prior_set)
unused <- pc |> filter(!in_prior_set)

m <- leaflet() |>
  addProviderTiles("CartoDB.Positron", group = "Light basemap") |>
  addProviderTiles("Esri.WorldImagery", group = "Satellite") |>

  # Cores that did NOT make the cut — shown so the choice is visible, not hidden
  addCircleMarkers(
    data = unused, lng = ~Long, lat = ~Lat,
    radius = 4, weight = 1, color = "#999999", opacity = 0.6,
    fillColor = ~pal(stock_MgC_ha), fillOpacity = 0.35,
    popup = popup_prior[!pc$in_prior_set],
    group = "Other eelgrass cores") |>

  # The prior set — bigger and solid-edged
  addCircleMarkers(
    data = used, lng = ~Long, lat = ~Lat,
    radius = 7, weight = 2, color = "#222222", opacity = 1,
    fillColor = ~pal(stock_MgC_ha), fillOpacity = 0.95,
    popup = popup_prior[pc$in_prior_set],
    group = "Prior set (sites like yours)") |>

  # Your cores — square-ish, red-edged, so they never read as prior data
  addCircleMarkers(
    data = mine, lng = ~longitude, lat = ~latitude,
    radius = 9, weight = 3, color = "#d7263d", opacity = 1,
    fillColor = ~pal(stock_MgC_ha), fillOpacity = 0.95,
    popup = popup_mine,
    group = "Your cores") |>

  addLegend(pal = pal, values = all_stock, position = "bottomleft",
            title = sprintf("carbon 0-%d cm<br/>(Mg C/ha)", prior$depth_basis_cm)) |>
  addLayersControl(
    baseGroups    = c("Light basemap", "Satellite"),
    overlayGroups = c("Prior set (sites like yours)", "Other eelgrass cores",
                      "Your cores"),
    options = layersControlOptions(collapsed = FALSE)) |>
  addControl(
    html = sprintf(
      paste0("<div style='background:#fff;padding:8px 10px;font:12px/1.45 sans-serif;",
             "max-width:270px'><b>Prior: %s</b><br/>%d cores, %d estuaries<br/>",
             "<b>%.1f &plusmn; %.1f</b> Mg C/ha to %d cm<br/>",
             "<span style='color:#666'>&plusmn; is meadow-to-meadow SD — what<br/>",
             "weights the prior against your cores.</span></div>"),
      prior$prior_set, prior$n_cores, prior$n_estuaries,
      prior$prior_mean_MgC_ha, prior$prior_sd_mean, prior$depth_basis_cm),
    position = "topright")

# saveWidget needs pandoc to inline the JS/CSS into one shareable file.
# RStudio ships one; point at it if it is not already on PATH.
if (!nzchar(Sys.which("pandoc")) && !nzchar(Sys.getenv("RSTUDIO_PANDOC"))) {
  rs <- Sys.glob("/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/*/pandoc")
  if (length(rs)) Sys.setenv(RSTUDIO_PANDOC = dirname(rs[1]))
}
standalone <- nzchar(Sys.which("pandoc")) || nzchar(Sys.getenv("RSTUDIO_PANDOC"))

dir.create(file.path(OUTPUT_DIR, "maps"), recursive = TRUE, showWarnings = FALSE)
out <- file.path(OUTPUT_DIR, "maps", "prior_cores.html")
saveWidget(m, normalizePath(out, mustWork = FALSE), selfcontained = standalone)
# saveWidget leaves its scratch folder behind even when it inlines everything
if (standalone) unlink(file.path(OUTPUT_DIR, "maps", "prior_cores_files"),
                       recursive = TRUE)

cat("saved", out,
    if (standalone) " (single self-contained file)" else
      " (pandoc not found — kept the lib/ folder beside it)", "\n")
if (interactive()) print(m)
