# run_pipeline.R
# Runs the whole eelgrass carbon analysis, start to finish.
#
#     source("run_pipeline.R")
#
# Everything you need to change lives in 00_config.R. Nothing else should need
# editing to run this on your own site.
#
# ── A note on the prior ──────────────────────────────────────────────────────
#   02_derive_prior.R reads the Janousek synthesis and writes the prior to
#   data/prior_eelgrass_janousek.csv. 00_config.R reads that file, so the
#   config has to be re-read AFTER the prior is derived — that is the
#   double source("00_config.R") below, and it is the only oddity here.
#
#   The prior is derived once and cached. Re-run 02_derive_prior.R by hand
#   after changing PRIMARY_DEPTH_CM, SITE_LAT/SITE_LON or any PRIOR_* dial.

source("00_config.R")                # every setting lives here

if (is.na(PRIOR_MEAN)) {
  source("02_derive_prior.R")        # prior from cores at sites like yours
  source("00_config.R")              # re-read so PRIOR_* are populated
}

source("01_prepare_cores.R")         # load, QC, correct for compaction
source("03_harmonize_depths.R")      # common depths + below-core model
source("04_estimate_stock.R")        # area-weighted stratified estimate
source("05_combine_prior.R")         # combine prior + cores; check the target

# ── Optional ─────────────────────────────────────────────────────────────────
#   source("view_prior.R")           # the prior cores and yours, on a map
#   source("06_advanced_spatial.R")  # placeholder — not part of the workflow yet
#
#   quarto::quarto_render("eelgrass_carbon_report.qmd")   # the written report
