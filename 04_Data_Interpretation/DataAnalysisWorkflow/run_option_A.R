# run_option_A.R — "What do our samples tell us, and how do they compare?"
#   source("run_option_A.R")
# Reads the workbook, checks it, calculates core stocks, compares them with published
# eelgrass cores, writes tables and figures to <OUTPUT_DIR>/option_A/, and renders the report.

# ── Shared foundation: read, check, core stocks (run_checks.R) ──────────────────
source("run_checks.R")
if (!ready) stop("No complete cores yet — fix what the checks above list, save the workbook, and run again.", call. = FALSE)
out <- file.path(OUTPUT_DIR, "option_A")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# ── Comparison ─────────────────────────────────────────────────────────────────
D <- if (is.null(COMPARE_DEPTH_CM)) common_depth(cum) else COMPARE_DEPTH_CM
if (is.na(D)) stop("None of your cores reached 15 cm, the shallowest standard depth.")
refs <- reference_sets(D, chk$cores, wb$loi, states = REFERENCE_STATES,
                       exclude_estuaries = REFERENCE_EXCLUDE_ESTUARIES,
                       exclude_within_m = REFERENCE_EXCLUDE_WITHIN_M)
refs <- headline_first(refs, REFERENCE_HEADLINE)
cmp <- compare_to_reference(cum, refs[[1]], D)
names(cmp)[names(cmp) == "percentile"] <- paste0("percentile_", names(refs)[1])
for (k in names(refs)[-1]) cmp[[paste0("percentile_", k)]] <- compare_to_reference(cum, refs[[k]], D)$percentile
region <- if (is.null(REFERENCE_STATES)) "the Pacific coast" else paste(REFERENCE_STATES, collapse = " + ")
ref_table <- do.call(rbind, lapply(names(refs), function(k)
  cbind(reference_set = REFERENCE_LABELS[[k]], reference_summary(refs[[k]]))))
boundary <- if (!is.null(BOUNDARY_FILE) && file.exists(BOUNDARY_FILE)) utils::read.csv(BOUNDARY_FILE) else NULL

# ── Write outputs ──────────────────────────────────────────────────────────────
# (the checked slices, core summary and increment stocks are in <OUTPUT_DIR>/checks/)
utils::write.csv(cmp,   file.path(out, "comparison.csv"), row.names = FALSE)
for (k in names(refs))
  utils::write.csv(refs[[k]], file.path(out, sprintf("reference_cores_%s.csv", k)), row.names = FALSE)
ggsave(file.path(out, "profiles.png"), plot_profiles(chk, attr(refs[[1]], "slices")), width = 9, height = 5, dpi = 150)
ggsave(file.path(out, "increments.png"), plot_increments(inc), width = 6, height = 4, dpi = 150)
ggsave(file.path(out, "comparison.png"), plot_reference(refs, cmp, D, region), width = 8, height = 4, dpi = 150)
ggsave(file.path(out, "bd_vs_oc.png"), plot_bd_vs_oc(chk, attr(refs[[1]], "slices")), width = 6, height = 4.5, dpi = 150)
ggsave(file.path(out, "locations.png"), plot_locations(chk, boundary), width = 5, height = 4.5, dpi = 150)
ggsave(file.path(out, "reference_map.png"), plot_reference_map(chk, refs[[1]]), width = 6, height = 6, dpi = 150)

settings_used <- list(WORKBOOK = WORKBOOK, COMPARE_DEPTH_CM = COMPARE_DEPTH_CM,
                      REFERENCE_STATES = REFERENCE_STATES, REFERENCE_HEADLINE = REFERENCE_HEADLINE,
                      REFERENCE_EXCLUDE_ESTUARIES = REFERENCE_EXCLUDE_ESTUARIES,
                      REFERENCE_EXCLUDE_WITHIN_M = REFERENCE_EXCLUDE_WITHIN_M)
saveRDS(list(project = PROJECT, settings = settings_used, chk = chk, checks = checks, cores = cores,
             inc = inc, cum = cum, D = D, refs = refs, ref_table = ref_table, ref_labels = REFERENCE_LABELS,
             cmp = cmp, region = region,
             cross_check = cross_check_workbook(chk), figures = normalizePath(out)),
        file.path(out, "results.rds"))

cat(sprintf("\n%d complete core(s). Common comparison depth: 0–%g cm.\n",
            sum(chk$cores$status == "Complete"), D))
print(cmp, row.names = FALSE)
print(ref_table, row.names = FALSE)

# ── Report ─────────────────────────────────────────────────────────────────────
if (!requireNamespace("rmarkdown", quietly = TRUE) || !rmarkdown::pandoc_available()) {
  message("Report not rendered: it needs the rmarkdown package and pandoc (both come with RStudio). ",
          "The tables and figures above are in ", out, ".")
} else {
  results_file <- normalizePath(file.path(out, "results.rds"))   # before render() changes folder
  rmarkdown::render("report_option_A.Rmd", output_dir = out, quiet = TRUE, envir = new.env(),
                    params = list(results = results_file))
  cat("Report:", file.path(out, "report_option_A.html"), "\n")
}
