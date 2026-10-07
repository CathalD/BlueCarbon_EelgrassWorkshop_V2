# Data analysis workflow — quick start

*Turns the completed digital data sheet into checked core stocks, a comparison with published
eelgrass cores (Option A), and an estimate for a defined area (Option B).*

[← Part 4 — Data Interpretation](../README.md) · [Back to main guide](../../README.md)

---

You do not need to write R. You download one folder, click **Source** on one file to test it, then
fill in your own workbook and click **Source** again. Checks, core stocks, tables, figures and short
reports are produced for you, from the same digital data sheet described in [Part 4](../README.md).

| | You do | You see |
|---|---|---|
| **1. Download** | Run two lines in RStudio (below) | RStudio opens a new project, `BlueCarbon_Part4_Workshop`, with `Start_Here.R` |
| **2. Test** | Click **Source** on `Start_Here.R` | The worked example runs; the console ends with *Setup works*; its report opens; your blank workbook appears in `my_data/` |
| **3. Your data** | Fill in `my_data/my_eelgrass_carbon.xlsx`, edit `settings.R`, click **Source** again | Your checks and core stocks in the console; your reports in `outputs/my_project/` |

## What you get

<table>
<tr>
<td width="50%">

<img width="100%" alt="Preview of the Option A report for the Cowichan worked example: the question, what was sampled, carbon pool and depth" src="../images/report_preview_option_A.png">

**Option A report** — your cores, and how they compare.
[Open the example](example_reports/cowichan_report_option_A.html)

</td>
<td width="50%">

<img width="100%" alt="Preview of the Option B report for the Cowichan worked example: the hypothetical boundary warning, the question, the area and sampling table" src="../images/report_preview_option_B.png">

**Option B report** — an estimate for a defined area.
[Open the example](example_reports/cowichan_report_option_B.html)

</td>
</tr>
</table>

Every report states the question, area, carbon pool and depth, dates, design, number of independent
sampling units, method, the estimate and what its uncertainty includes, exclusions, and what the
result supports. The example reports are HTML files: download one and open it in any browser.

## The few lines you change

<img width="100%" alt="The settings.R lines a participant changes: 1 project text, 2 the workbook path, 3 your estuary code to leave out of the reference set, 4 the sampling design, 5 the boundary file, 6 stratum areas, 7 the reporting depth" src="../images/settings_preview.png">

Everything else in `settings.R` has a sensible default. Each line is explained in the file itself.

## 1. Download

Install **R** from [cran.r-project.org](https://cran.r-project.org) and **RStudio** from
[posit.co](https://posit.co/download/rstudio-desktop/) (RStudio includes pandoc, which the reports
need). Then, in the RStudio console:

```r
install.packages("usethis")   # only if you do not have it
usethis::use_course("https://github.com/CathalD/BlueCarbon_EelgrassWorkshop_V2/releases/latest/download/BlueCarbon_Part4_Workshop.zip")
```

`use_course()` asks where to put the folder (your Desktop by default), unpacks it, and opens it as a
new RStudio project with `Start_Here.R` in front of you. The download is about 2 MB: the workflow,
the blank and example workbooks, the published reference cores, and the example reports.

<details>
<summary><b>Other ways to get the folder</b></summary>

<br>

- **From the release page:** download `BlueCarbon_Part4_Workshop.zip` from the repository's
  *Releases*, unzip it, and double-click `BlueCarbon_Part4_Workshop.Rproj`.
- **From the whole repository:** *Code → Download ZIP* on GitHub (the whole workshop, about
  120 MB), then open `04_Data_Interpretation/DataAnalysisWorkflow/BlueCarbon_Part4_Workshop.Rproj`.

Either way, always open the `.Rproj` file first: it sets R to the right folder, so every path in
the workflow works without setting a working directory.

</details>

## 2. Test

Click **Source** at the top right of `Start_Here.R`. The first time, it:

1. installs any missing packages (`readxl`, `ggplot2`, `survey`, `rmarkdown`, `knitr`);
2. runs the Cowichan worked example through the checks, Option A and Option B, and opens its report.
   The console ends with **`Setup works.`**;
3. copies the blank digital data sheet to `my_data/my_eelgrass_carbon.xlsx`, ready for your data.

<details>
<summary><b>What the console shows on a successful test</b></summary>

<br>

```text
Eelgrass_Carbon_DigitalData_Example.xlsx — 3 core(s) and 45 slice(s) entered; 3 core(s) complete and totalled.
 core_id   status measured_to_insitu_cm 0-15 cm (Mg C/ha) 0-30 cm (Mg C/ha) ...
  COW-S5 Complete                    20              17.1                 — ...
  COW-S6 Complete                    20              12.1                 — ...
  COW-S7 Complete                    20              14.5                 — ...
...
0–15 cm: mean 14.6 Mg C/ha over 6.56 ha → 96 Mg C (3 sampling units, exploratory design; 0% of it estimated below the cores).
Deeper scenario — 0–30 cm: mean 33.7 Mg C/ha over 6.56 ha → 221 Mg C (3 sampling units, exploratory design; 38% of it estimated below the cores).
...
Setup works. The worked example's results are in outputs/example/.
Your workbook is ready to fill in: my_data/my_eelgrass_carbon.xlsx

my_eelgrass_carbon.xlsx — 0 core(s) and 0 slice(s) entered; 0 core(s) complete and totalled.
The workbook has no cores yet: fill in Sheet 2 (one row per core) and Sheet 3 (one row per slice).
```

</details>

## 3. Your data

1. **Fill in `my_data/my_eelgrass_carbon.xlsx`** — open it from RStudio's *Files* pane. One row per
   core on *2. Plot & Core Log* (from the field data sheet), one row per slice on *3. Sample Data*
   (field depths, then the lab's dry weight, carbon value and carbon type). Set your corer diameter
   and, if you have LOI values, your LOI equation on *1. Instructions*. The workbook calculates
   bulk density, organic carbon and carbon stock itself, and its *Slice check* column says what is
   missing. It holds 300 cores and 4,000 slices — compile a larger survey into this one workbook.
   Google Sheets works too: upload it, then *File → Download → .xlsx* back into `my_data/`.
2. **Edit `settings.R`** — the lines in the picture above. For Option B, save your boundary as
   `my_data/boundary.csv` (columns `longitude`, `latitude`, decimal degrees — e.g. exported from the
   sampling tool in Part 2; see [`data/example_area/`](data/example_area/) for the format) and set
   `BOUNDARY_FILE`.
3. **Click Source on `Start_Here.R` again.** Each time it checks the workbook and prints every
   problem that keeps a core out of the totals — a missing lab value, a gap, a duplicate ID,
   unmeasured compaction — with the same messages as the workbook. Fix them in the workbook, save,
   and Source again. Once a core is complete, Option A runs; once `BOUNDARY_FILE` is set, Option B
   runs too.

Your files in `my_data/` and your results in `outputs/my_project/` are yours: the workflow never
uploads anything, and the example's results in `outputs/example/` are kept separate.

<details>
<summary><b>Running one step at a time</b></summary>

<br>

`Start_Here.R` is in numbered sections: click inside one and press *Ctrl+Alt+T* (*Cmd+Option+T* on a
Mac). Or run the scripts directly from the console:

```r
source("run_checks.R")     # read, check, core stocks — use while entering and fixing data
source("run_option_A.R")   # Option A: our cores, and how they compare
source("run_option_B.R")   # Option B: an estimate for a defined area
```

Each script starts with `run_checks.R`, so the checks are the same everywhere. To run the worked
example instead of your own data, set `SETTINGS_FILE <- "settings_example.R"` first.

</details>

## 4. Where the results go

| Folder | Contents |
|---|---|
| `outputs/my_project/checks/` | Every slice with its calculations and check message; one row per core; stocks in each standard increment and from the surface down |
| `outputs/my_project/option_A/` | `report_option_A.html`; the comparison table and both reference sets; profile, increment, comparison, bulk-density and location figures |
| `outputs/my_project/option_B/` | `report_option_B.html`; each core's measured and estimated stock by increment; sampling-unit values; the area estimate at every standard depth; carbon curves and the reporting-area map |
| `outputs/example/` | The same, for the worked example (made by the test) |

Open the `.html` reports in any browser.

<details>
<summary><b>What the workflow does, and does not do</b></summary>

<br>

- **Shared foundation** (`R/01_read_and_check.R`, `R/02_core_stocks.R`): reads the workbook
  directly, repeats every workbook check, and cross-checks its numbers against the workbook's. It
  calculates slice stocks on the measured interval, places them on in-situ depths, and splits them
  into 0–15, 15–30, 30–50 and 50–100 cm by overlap. Carbon is conserved, and that is checked on
  every run.
- **Option A** (`R/03_option_A.R`): measured values only. Reference cores come from
  [`data/reference/`](data/reference/). Your estuary is excluded, and so is anything within 100 m
  of your cores.
- **Option B** (`R/04_option_B.R`): leads with the deepest standard depth every core **measured**.
  A deeper figure is added as a clearly labelled scenario only where the cores are long enough —
  following Janousek et al. (2025), 20 cm for 0–30 cm, 35 cm for 0–50 cm and 75 cm for 0–100 cm. Its
  estimated share is shown increment by increment. It averages cores within a plot, then estimates the
  area mean and total as the design allows: no interval for exploratory sampling, a t-interval for
  simple random sampling, and `survey` for stratified designs. The finite-population correction is
  used only when you set `PLOTS_ARE_SAMPLING_FRAME <- TRUE`, i.e. when the cores were drawn from a fixed
  list of plots.
- It does **not** make a prediction surface, combine your cores with a prior, or estimate change
  over time. The optional modules in [`going_further/`](going_further/) cover the first two, and
  are not used by Options A or B.

</details>

## Worked examples in this folder

| Run | Data | What it shows |
|---|---|---|
| `SETTINGS_FILE <- "settings_example.R"; source("run_option_A.R")` | Three published Cowichan eelgrass cores (Douglas et al. 2022, via Janousek et al. 2025) | Option A on real measurements |
| `SETTINGS_FILE <- "settings_example.R"; source("run_option_B.R")` | The same cores, inside a **hypothetical** 6.6 ha boundary, exploratory design | How Option B handles cores that stop at 20 cm, and why no interval is given |
| `SETTINGS_FILE <- "settings_synthetic.R"; source("run_option_B.R")` | A **synthetic** stratified survey, computer-generated, at 0° N 0° E (repository only, not in the download) | The stratified calculation, its interval, and an unsampled stratum |

<details>
<summary><b>Folder contents</b></summary>

<br>

| Path | What it is |
|---|---|
| `BlueCarbon_Part4_Workshop.Rproj` | The RStudio project — open this first |
| `Start_Here.R` | Test, then run your own data: click Source |
| `settings.R` | The one file you edit — your project |
| `settings_example.R` | The worked example's settings (used by the test) |
| `run_checks.R` | The shared foundation: read, check, core stocks |
| `run_option_A.R`, `run_option_B.R` | The two options, each starting from `run_checks.R` |
| `workbooks/` | The blank digital data sheet, the Cowichan example, and the mock lab results sheet |
| `my_data/` | Your own workbook and boundary (not shared, not tracked by git) |
| `report_option_A.Rmd`, `report_option_B.Rmd` | Report templates (filled in automatically) |
| `R/` | The functions, in workflow order |
| `data/reference/` | Published *Zostera marina* cores for Option A comparisons — see its README |
| `data/example_area/` | The worked example's hypothetical boundary |
| `data/synthetic/`, `settings_synthetic.R` | The synthetic stratified demonstration |
| `tests/testthat/` | Automated checks of the calculations, on synthetic fixtures: `testthat::test_dir("tests/testthat")` |
| `data-raw/` | Maintainer scripts that rebuild the workbooks, figures and the download (`build_course_zip.sh`). Participants never need these |
| `going_further/` | Optional modules that build on Options A and B |
| `advanced/` | The earlier research pipeline, kept for reference. Nothing here depends on it |
| `example_reports/` | The rendered example reports, kept so you can look before you run anything |

</details>
