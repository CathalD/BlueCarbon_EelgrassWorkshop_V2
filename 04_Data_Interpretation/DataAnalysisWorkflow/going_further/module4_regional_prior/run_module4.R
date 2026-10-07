# run_module4.R — Going further, module 4: "What do published cores add to ours?"
# Run from the DataAnalysisWorkflow folder:
#   source("going_further/module4_regional_prior/run_module4.R")
# Builds a regional prior from published Zostera cores (your estuary and anything within
# 100 m left out), updates it with your sampling units, checks the method on the reference
# estuaries themselves, and renders a short report. Options A and B do not use any of this.

# ── Shared foundation (run_checks.R, as for Options A and B) ────────────────────
source("run_checks.R")
if (!ready) stop("No complete cores yet — fix what the checks above list, save the workbook, and run again.", call. = FALSE)
here <- file.path("going_further", "module4_regional_prior")
source(file.path(here, "R", "regional_prior.R"))
out <- file.path(OUTPUT_DIR, "module4")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# ── Your side: one MEASURED value per sampling unit ────────────────────────────
D <- if (is.null(MODULE4_DEPTH_CM)) common_depth(cum) else MODULE4_DEPTH_CM
if (is.na(D)) stop("None of your cores reached 15 cm, the shallowest standard depth.")
meas <- cum[cum$depth_cm == D & cum$status == "complete", ]
short <- setdiff(chk$cores$core_id[chk$cores$status == "Complete"], meas$core_id)
if (length(short)) message("Not measured to ", D, " cm, so not used here: ", paste(short, collapse = ", "))
meas$measured_Mg_ha <- meas$stock_Mg_ha; meas$estimated_Mg_ha <- 0
units <- unit_values(meas, D, unit = SAMPLING_UNIT)

# ── The published side, then the combination and the check ──────────────────────
basis <- REFERENCE_HEADLINE
if (basis == "oc_or_loi" && any(is.na(wb$loi))) {
  message("No LOI equation on the workbook, so the prior uses measured organic carbon only.")
  basis <- "oc_measured"
}
ref <- reference_stocks(D, chk$cores, wb$loi, states = REFERENCE_STATES,
                        exclude_estuaries = REFERENCE_EXCLUDE_ESTUARIES,
                        exclude_within_m = REFERENCE_EXCLUDE_WITHIN_M, carbon = basis)
prior <- regional_prior(ref, MODULE4_MIN_ESTUARIES)
tab <- borrow_strength(ref, units$stock_Mg_ha, conf = CONF_LEVEL, min_estuaries = MODULE4_MIN_ESTUARIES)
loeo <- loeo_check(ref, conf = CONF_LEVEL, min_estuaries = MODULE4_MIN_ESTUARIES)
loeo_tab <- summarise_loeo(loeo)

utils::write.csv(tab, file.path(out, "prior_local_combined.csv"), row.names = FALSE)
utils::write.csv(loeo_tab, file.path(out, "leave_one_estuary_out.csv"), row.names = FALSE)
utils::write.csv(units, file.path(out, sprintf("sampling_units_0_%gcm_measured.csv", D)), row.names = FALSE)
ggsave(file.path(out, "borrow_strength.png"), plot_borrow(tab, units, D, CONF_LEVEL), width = 7.5, height = 3.2, dpi = 150)
ggsave(file.path(out, "prior_estuaries.png"), plot_prior_estuaries(ref, prior, D), width = 7, height = 4.5, dpi = 150)
ggsave(file.path(out, "leave_one_estuary_out.png"), plot_loeo(loeo_tab), width = 6, height = 4, dpi = 150)

saveRDS(list(project = PROJECT, D = D, units = units, ref = ref, prior = prior, tab = tab, loeo_tab = loeo_tab,
             conf = CONF_LEVEL, reference_headline = basis, ref_label = REFERENCE_LABELS[[basis]],
             settings = list(REFERENCE_STATES = REFERENCE_STATES, REFERENCE_EXCLUDE_ESTUARIES = REFERENCE_EXCLUDE_ESTUARIES,
                             REFERENCE_EXCLUDE_WITHIN_M = REFERENCE_EXCLUDE_WITHIN_M, SAMPLING_UNIT = SAMPLING_UNIT),
             figures = normalizePath(out)), file.path(out, "results.rds"))

print(tab, row.names = FALSE)
print(loeo_tab, row.names = FALSE)

if (!requireNamespace("rmarkdown", quietly = TRUE) || !rmarkdown::pandoc_available()) {
  message("Report not rendered: it needs the rmarkdown package and pandoc (both come with RStudio). ",
          "The tables and figures above are in ", out, ".")
} else {
  results_file <- normalizePath(file.path(out, "results.rds"))   # before render() changes folder
  rmarkdown::render(file.path(here, "report_module4.Rmd"), output_dir = out, quiet = TRUE, envir = new.env(),
                    params = list(results = results_file))
  cat("Report:", file.path(out, "report_module4.html"), "\n")
}
