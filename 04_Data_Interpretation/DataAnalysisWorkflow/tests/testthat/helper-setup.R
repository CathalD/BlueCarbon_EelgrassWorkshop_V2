# Loads the workflow's functions and builds small SYNTHETIC fixtures. Nothing here is field data.
ROOT <- normalizePath(file.path(testthat::test_path(), "..", ".."))
for (f in list.files(file.path(ROOT, "R"), pattern = "[.]R$", full.names = TRUE)) source(f)
source(file.path(ROOT, "going_further", "module4_regional_prior", "R", "regional_prior.R"))

#' One core-log row. Defaults: a 7 cm corer from the project setting, compaction "assume none".
core_row <- function(core_id, plot_id = core_id, stratum = NA, diameter_cm = NA, outside_cm = NA,
                     inside_cm = NA, note = "assume none", latitude = 0.001, longitude = 0.001) {
  data.frame(plot_id = plot_id, core_id = core_id, latitude = latitude, longitude = longitude,
             diameter_cm = diameter_cm, outside_cm = outside_cm, inside_cm = inside_cm,
             stratum = stratum, compaction_note = note, core_notes = NA, stringsAsFactors = FALSE)
}

#' Slices for one core from depth edges and a carbon density profile. `bd` and `oc` are
#' per-slice dry bulk density (g/cm3) and OC (%); dry mass is back-calculated for a 7 cm tube.
slice_rows <- function(core_id, edges, bd = 1.5, oc = 1, type = "OC", dia = 7) {
  n <- length(edges) - 1
  bd <- rep_len(bd, n); oc <- rep_len(oc, n); type <- rep_len(type, n)
  th <- diff(edges)
  data.frame(core_id = core_id, sample_id = seq_len(n), top_cm = head(edges, -1), bottom_cm = edges[-1],
             notes = NA, wet_g = NA, dry_g = bd * pi * (dia / 2)^2 * th, carbon_value_pct = oc,
             carbon_type = type, stringsAsFactors = FALSE)
}

make_wb <- function(cores, samples, loi = c(intercept = NA_real_, slope = NA_real_), dia = 7) {
  list(cores = cores, samples = samples, loi = loi, corer_diameter_cm = dia)
}

#' A complete core whose stock per slice is known: stock (Mg C/ha) = bd * oc/100 * thickness * 100.
simple_chk <- function(...) check_slices(make_wb(...))
