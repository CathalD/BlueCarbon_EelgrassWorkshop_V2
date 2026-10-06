# run_option_A.R — "What do our samples tell us, and how do they compare?"
#   source("run_option_A.R")
# Reads the workbook, checks it, calculates core stocks, compares them with published
# eelgrass cores, writes tables and figures to outputs/option_A/, and renders the report.

source("settings.R")
for (f in list.files("R", full.names = TRUE)) source(f)
out <- file.path("outputs", "option_A")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# ── Shared foundation: read, check, core stocks ─────────────────────────────────
wb  <- read_workbook(WORKBOOK)
chk <- check_slices(wb)
problems <- chk$slices[chk$slices$check != "OK", c("core_id", "sample_id", "top_cm", "bottom_cm", "check")]
if (nrow(problems)) {
  message("Some slices did not pass the checks — those cores are left out until fixed:")
  print(problems, row.names = FALSE)
}
if (!any(chk$cores$status == "Complete")) stop("No complete cores yet — see the checks above.")

cores <- core_summary(chk)
inc   <- increment_stocks(chk)
cum   <- cumulative_stocks(inc)

# ── Comparison ─────────────────────────────────────────────────────────────────
D <- if (is.null(COMPARE_DEPTH_CM)) common_depth(cum) else COMPARE_DEPTH_CM
if (is.na(D)) stop("None of your cores reached 15 cm, the shallowest standard depth.")
ref <- reference_stocks(D, chk$cores[chk$cores$status == "Complete", ], wb$loi,
                        states = REFERENCE_STATES, exclude_estuaries = REFERENCE_EXCLUDE_ESTUARIES,
                        exclude_within_m = REFERENCE_EXCLUDE_WITHIN_M, carbon = REFERENCE_CARBON)
cmp <- compare_to_reference(cum, ref, D)
region <- if (is.null(REFERENCE_STATES)) "Pacific coast" else paste(REFERENCE_STATES, collapse = " + ")

# ── Write outputs ──────────────────────────────────────────────────────────────
utils::write.csv(chk$slices, file.path(out, "slices_checked.csv"), row.names = FALSE)
utils::write.csv(cores, file.path(out, "core_summary.csv"), row.names = FALSE)
utils::write.csv(inc,   file.path(out, "increment_stocks.csv"), row.names = FALSE)
utils::write.csv(ref,   file.path(out, "reference_cores_used.csv"), row.names = FALSE)
utils::write.csv(cmp,   file.path(out, "comparison.csv"), row.names = FALSE)
ggsave(file.path(out, "profiles.png"), plot_profiles(chk), width = 9, height = 5, dpi = 150)
ggsave(file.path(out, "increments.png"), plot_increments(inc), width = 6, height = 4, dpi = 150)
ggsave(file.path(out, "comparison.png"), plot_reference(ref, cmp, D, region), width = 8, height = 3.6, dpi = 150)
ggsave(file.path(out, "locations.png"), plot_locations(chk), width = 5, height = 4.5, dpi = 150)
saveRDS(list(settings = mget(ls(pattern = "^[A-Z_]+$")), chk = chk, cores = cores, inc = inc,
             cum = cum, D = D, ref = ref, cmp = cmp, region = region,
             cross_check = cross_check_workbook(chk)), file.path(out, "results.rds"))

cat(sprintf("\n%d complete core(s). Common comparison depth: 0–%g cm.\n",
            sum(chk$cores$status == "Complete"), D))
print(cmp, row.names = FALSE)
print(reference_summary(ref), row.names = FALSE)

if (requireNamespace("rmarkdown", quietly = TRUE) && rmarkdown::pandoc_available()) {
  rmarkdown::render("report_option_A.Rmd", output_dir = out, quiet = TRUE,
                    envir = new.env())
  cat("Report:", file.path(out, "report_option_A.html"), "\n")
}
