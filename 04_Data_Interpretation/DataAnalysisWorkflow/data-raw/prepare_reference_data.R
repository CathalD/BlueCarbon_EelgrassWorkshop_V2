# prepare_reference_data.R
# -----------------------------------------------------------------------------
# Builds data/reference/ from the Janousek et al. (2025) synthesis.
# You do NOT need to run this to use the workshop — its outputs are in the repo.
# It is here so anyone can check exactly how the reference files were made.
#
# Source: Janousek, C.N. et al. (2025). Carbon stocks and environmental driver data
#   for blue carbon ecosystems along the Pacific coast of North America.
#   Smithsonian Environmental Research Center. doi:10.25573/serc.28127486
#   The CSVs were taken from the Coastal Carbon Network data library mirror:
#   github.com/Smithsonian/CCN-Data-Library,
#   data/primary_studies/Janousek_et_al_2025/original/ (commit 5972abd, 2026-02-24).
#
# What this script does — nothing else:
#   1. keeps cores whose vegetation class is Zostera marina (VegGrp == "ZosMar");
#   2. keeps the columns the workshop uses;
#   3. splits the depth-interval text ("10-12") into numbers and flags intervals
#      the synthesis marks as approximate ("abt 5-10") or as not measured
#      (BD_type / C_type / OM_type of E = extrapolated, I = interpolated, O = modelled).
# No values are changed, converted or filled in.
# -----------------------------------------------------------------------------

src_dir <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(src_dir)) stop("Usage: Rscript prepare_reference_data.R <folder with Janousek_et_al_2025_*.csv>")
out_dir <- file.path("data", "reference")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

rd <- function(f) as.data.frame(readr::read_csv(file.path(src_dir, f), na = c("NA", ""),
                                               col_types = readr::cols(.default = "c"),
                                               show_col_types = FALSE), check.names = FALSE)
cores   <- rd("Janousek_et_al_2025_cores.csv")
depth   <- rd("Janousek_et_al_2025_depthseries.csv")
sources <- rd("Janousek_et_al_2025_sources.csv")

num_cols <- function(x, cols) { for (k in cols) x[[k]] <- as.numeric(x[[k]]); x }
cores <- num_cols(cores, c("Lat", "Long", "Stk30"))
depth <- num_cols(depth, c("BD", "PercOM", "PercC"))

z <- cores[cores$VegGrp %in% "ZosMar",
           c("StudyID", "SampID", "State", "Estuary", "EstType", "Lat", "Long",
             "LatLongType", "Lvl1EcoReg", "KGzone", "Cdepth", "Stk30")]

d <- depth[depth$SampID %in% z$SampID,
           c("StudyID", "SampID", "StudySampID", "SubSampID", "SampInterval",
             "BD_type", "BD", "C method", "OM_type", "C_type", "PercOM", "PercC")]
names(d)[names(d) == "C method"] <- "C_method"

iv <- trimws(d$SampInterval)
d$depth_approximate <- grepl("^abt", iv)
num <- regmatches(iv, regexec("([0-9.]+)\\s*-\\s*([0-9.]+)", iv))
d$depth_top_cm    <- vapply(num, function(m) if (length(m) == 3) as.numeric(m[2]) else NA_real_, 0)
d$depth_bottom_cm <- vapply(num, function(m) if (length(m) == 3) as.numeric(m[3]) else NA_real_, 0)

src <- sources[sources$StudyID %in% unique(z$StudyID),
               c("StudyID", "Citation (or dataset description)", "Sampling design",
                 "Coring method(s)", "Core compaction", "C method(s)",
                 "Inorganic carbon method", "LOI duration", "LOI temperature", "Link to study")]

utils::write.csv(z,   file.path(out_dir, "janousek2025_zostera_cores.csv"), row.names = FALSE)
utils::write.csv(d,   file.path(out_dir, "janousek2025_zostera_depthseries.csv"), row.names = FALSE)
utils::write.csv(src, file.path(out_dir, "janousek2025_zostera_sources.csv"), row.names = FALSE)
cat(sprintf("Wrote %d Zostera cores, %d depth rows, %d source studies.\n",
            nrow(z), nrow(d), nrow(src)))
