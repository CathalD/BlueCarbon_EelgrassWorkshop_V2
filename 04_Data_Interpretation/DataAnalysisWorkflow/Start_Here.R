# Start_Here.R — Blue Carbon Eelgrass Workshop, Part 4: from your digital data sheet to a report.
#
# HOW TO USE THIS FILE
#   1. First time: click "Source" (top right of this pane). It installs any missing packages, runs
#      the worked example to test your setup, and makes your own workbook in my_data/.
#   2. Fill in my_data/my_eelgrass_carbon.xlsx — the field data sheet and the lab results, one row
#      per core on Sheet 2 and one row per slice on Sheet 3 — and save it. Edit settings.R.
#   3. Click "Source" again. Each time, it checks your workbook and calculates your core stocks;
#      once at least one core is complete it runs Option A, and Option B when settings.R names
#      your boundary. Fix anything the checks list, save, and Source again.
# You can also run one section at a time: click inside it and press Ctrl+Alt+T (Cmd+Option+T on
# a Mac). The sections are listed in this pane's outline (the button at its top right).
# Part 4 explains every step:
# https://github.com/CathalD/BlueCarbon_EelgrassWorkshop_V2/tree/main/04_Data_Interpretation

# ---- 1. Packages ---------------------------------------------------------------------------
if (!file.exists("run_checks.R"))
  stop("R is not looking at the workshop folder. Open BlueCarbon_Part4_Workshop.Rproj (double-click it), ",
       "then open Start_Here.R from the Files pane and click Source again.", call. = FALSE)
needed <- c("readxl", "ggplot2", "survey", "rmarkdown", "knitr")
missing_pkgs <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_pkgs)) {
  message("Installing: ", paste(missing_pkgs, collapse = ", "))
  if (getOption("repos")[["CRAN"]] %in% c("@CRAN@", "")) options(repos = c(CRAN = "https://cloud.r-project.org"))
  install.packages(missing_pkgs)
  missing_pkgs <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
}
if (any(c("readxl", "ggplot2") %in% missing_pkgs))
  stop("These packages could not be installed: ", paste(missing_pkgs, collapse = ", "), ". The workflow needs ",
       "readxl and ggplot2. Try install.packages(c(\"", paste(missing_pkgs, collapse = "\", \""), "\")) in the console ",
       "and read its messages, then click Source again.", call. = FALSE)
if ("survey" %in% missing_pkgs)
  message("Not installed: survey. Everything runs except a stratified Option B, which needs it.")
if (any(c("rmarkdown", "knitr") %in% missing_pkgs))
  message("Not installed: ", paste(intersect(c("rmarkdown", "knitr"), missing_pkgs), collapse = ", "),
          ". The tables and figures are made, but not the HTML reports.")
if (requireNamespace("rmarkdown", quietly = TRUE) && !rmarkdown::pandoc_available())
  message("Pandoc not found, so the HTML reports will not be made (the tables and figures still are). ",
          "RStudio includes pandoc: run this file from RStudio.")
show <- function(path) if (interactive() && file.exists(path)) utils::browseURL(normalizePath(path))

# ---- 2. Test: run the worked example ---------------------------------------------------------
# Three published eelgrass cores from the Cowichan Estuary (settings_example.R). If this section
# reaches "Setup works", R, the packages and the reports all work on your computer. It runs the
# first time only; set TEST_SETUP <- TRUE to run it again.
TEST_SETUP <- !file.exists(file.path("outputs", "example", "option_B", "report_option_B.html"))
if (TEST_SETUP) {
  SETTINGS_FILE <- "settings_example.R"
  source("run_option_A.R")
  source("run_option_B.R")
  cat("\nSetup works", if (length(missing_pkgs)) paste0(" (except: ", paste(missing_pkgs, collapse = ", "), " — see above)") else "",
      ". The worked example's results are in outputs/example/.\n", sep = "")
  show(file.path("outputs", "example", "option_A", "report_option_A.html"))
}

# ---- 3. Your workbook ------------------------------------------------------------------------
# From here on everything uses settings.R and your own workbook. The first time, the blank sheet
# is copied to my_data/ for you. Open it from the Files pane (my_data → the workbook), fill it in
# and save it as .xlsx. Google Sheets works too: upload it, then File → Download → .xlsx.
SETTINGS_FILE <- "settings.R"
source(SETTINGS_FILE)
if (!file.exists(WORKBOOK)) {
  dir.create(dirname(WORKBOOK), recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path("workbooks", "Eelgrass_Carbon_DigitalData_BlankSheet.xlsx"), WORKBOOK)
  message("Your workbook is ready to fill in: ", WORKBOOK)
}

# ---- 4. Check your data and calculate core stocks --------------------------------------------
# Lists every problem that keeps a core out of the totals (the same messages as the workbook's
# Slice check column), then prints each complete core's stock to the standard depths.
source("run_checks.R")

# ---- 5. Option A: what do our cores tell us, and how do they compare? -------------------------
if (ready) {
  source("run_option_A.R")
  show(file.path(OUTPUT_DIR, "option_A", "report_option_A.html"))
} else message("Option A waits until at least one core is complete (section 4).")

# ---- 6. Option B: what do our cores imply for a defined area? ---------------------------------
# Needs your reporting boundary (BOUNDARY_FILE in settings.R) and your sampling design (DESIGN).
if (ready && !is.null(BOUNDARY_FILE)) {
  source("run_option_B.R")
  show(file.path(OUTPUT_DIR, "option_B", "report_option_B.html"))
} else if (ready) message("Option B skipped: no boundary yet. Save it as my_data/boundary.csv ",
                          "(columns longitude, latitude) and set BOUNDARY_FILE in settings.R.")

# ---- 7. Going further (optional): module 4 ---------------------------------------------------
# Borrows strength from published cores in other estuaries. Remove the # to run it.
# source("going_further/module4_regional_prior/run_module4.R")

cat("\nYour results:", normalizePath(OUTPUT_DIR, mustWork = FALSE), "\n")
