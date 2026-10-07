# run_checks.R — the shared foundation: read the workbook, check every core and slice, and
# calculate the core stocks. Options A and B (and module 4) begin by running this. Run it on
# its own while you are still entering and fixing data:
#   source("run_checks.R")
# Writes to <OUTPUT_DIR>/checks/: every slice with its calculations and check message, one row
# per core, and the stocks in each standard depth increment and from the surface down.

if (!exists("SETTINGS_FILE")) SETTINGS_FILE <- Sys.getenv("SETTINGS_FILE", "settings.R")
source(SETTINGS_FILE)
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE)) source(f)
checks_dir <- file.path(OUTPUT_DIR, "checks")
dir.create(checks_dir, recursive = TRUE, showWarnings = FALSE)

wb  <- read_workbook(WORKBOOK)
chk <- check_slices(wb)
# The full report is printed once; when Option A or B re-runs the checks on an unchanged
# workbook in the same session, one line says so instead.
checks <- check_report(chk)
checked <- paste(normalizePath(WORKBOOK), file.mtime(WORKBOOK), SETTINGS_FILE, file.mtime(SETTINGS_FILE))
repeat_run <- exists(".last_checked") && identical(.last_checked, checked)
if (!repeat_run) print_check_report(checks)
.last_checked <- checked
cores <- core_summary(chk)
if (is.null(cores)) cores <- data.frame()
ready <- any(chk$cores$status == "Complete")
inc <- cum <- data.frame()
if (ready) {
  inc <- increment_stocks(chk)
  check_mass_conservation(chk, inc)
  cum <- cumulative_stocks(inc)
}
utils::write.csv(chk$slices, file.path(checks_dir, "slices_checked.csv"), row.names = FALSE)
utils::write.csv(cores, file.path(checks_dir, "core_summary.csv"), row.names = FALSE)
utils::write.csv(inc, file.path(checks_dir, "increment_stocks.csv"), row.names = FALSE)
utils::write.csv(cum, file.path(checks_dir, "cumulative_stocks.csv"), row.names = FALSE)

cat(sprintf("\n%s — %d core(s) and %d slice(s) entered; %d core(s) complete and totalled.\n",
            basename(WORKBOOK), nrow(chk$cores), nrow(chk$slices), sum(chk$cores$status == "Complete")))
if (repeat_run) {
  cat("Checks and core stocks: unchanged since the last run (see above).\n")
} else if (nrow(chk$cores)) print(stock_table(cores, cum), row.names = FALSE)
if (!ready) {
  message(if (!nrow(chk$cores)) "The workbook has no cores yet: fill in Sheet 2 (one row per core) and Sheet 3 (one row per slice)."
          else "No core is complete yet, so nothing is totalled. Fix what is listed above in the workbook, save it, and run again.")
} else {
  cat("Checked slices, core summary and stocks:", checks_dir, "\n")
}
