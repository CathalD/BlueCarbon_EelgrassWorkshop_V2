# Eelgrass Carbon Stock Analysis

You bring sediment cores from an eelgrass meadow. This workflow harmonizes
them to standard depths, estimates the carbon stock with an area-weighted
design-based estimator, combines that with a prior built from cores at sites
like yours, and tells you whether the answer is precise enough to manage by.

Neither a handful of cores nor a regional synthesis is the truth on its own. Combining
them, weighted by how much each can be trusted, is the best available estimate
— and it shows you exactly how much more sampling would buy.

**Site:** Tsawwassen Beach, BC — *worked teaching example* (constructed core
data; the prior is real). 6 cores, 32 sediment samples.

---

## 1. What you need

R ≥ 4.1, and these packages:

```r
install.packages(c(
  "dplyr", "readr", "tidyr", "ggplot2", "knitr",   # data wrangling + plots
  "mpspline2",                                      # depth harmonization
  "survey",                                         # stratified estimation
  "leaflet", "htmlwidgets"                          # the prior map viewer
))
```

For the prior, download the Janousek et al. (2025) synthesis from
<https://doi.org/10.25573/serc.28127486> and point `JANOUSEK_DIR` at the
folder. Quarto is only needed to render the report.

## 2. Your data

Three CSVs in `data/`, one row per thing:

| File | One row per | Key columns |
|---|---|---|
| `core_locations.csv` | core | `core_id`, `longitude`, `latitude`, `stratum` |
| `core_samples.csv` | sediment slice | `core_id`, `depth_top_cm`, `depth_bottom_cm`, `soc_g_kg`, `bulk_density_g_cm3` |
| `core_compaction.csv` | core | `core_id`, `outside_depth_cm`, `inside_depth_cm` |

The digital data sheet in [`../files/`](../files/) produces these columns
directly — export each sheet as CSV.

## 3. Set the dials

Everything site-specific lives in **`00_config.R`**, and that is the only file
you should need to edit. The ones that actually move the answer:

| Dial | What it does |
|---|---|
| `STRATUM_AREAS_M2` | Areas that weight the stratified estimate — these drive the headline number |
| `PLOT_AREA_M2` | What area one core stands for; sets the finite-population correction |
| `PRIMARY_DEPTH_CM` | The depth every core reached. Stocks to here are measured; deeper is modelled and reported separately |
| `SITE_LAT` / `SITE_LON` | Where you are — used to find the prior cores most like your site |
| `PRIOR_EXCLUDE_ESTUARY` | ⚠️ Any estuary in the synthesis that **is** your site. A prior containing your own cores is not independent evidence |
| `TARGET_MARGIN` / `TARGET_CONFIDENCE` | The precision you promised at the planning stage. Step 06 reports PASS/FAIL against it |
| `UTM_EPSG` | A metre-based projection for your coast |

## 4. Run it

```r
source("run_pipeline.R")
```

That derives the prior (once), runs every step in order, and finishes with the
combined estimate and the PASS/FAIL. To look at the prior on a map next to
your own cores:

```r
source("view_prior.R")
```

---

## The steps

| Step | What it answers | Package |
|---|---|---|
| `01_prepare_cores.R` | Load, QC, and correct for corer compaction | *from scratch* |
| `02_derive_prior.R` | What do cores at sites like mine already say? | *from scratch* |
| `03_harmonize_depths.R` | Put cores of different lengths on common depths | **mpspline2** |
| `04_estimate_stock.R` | The area-weighted stock, with a confidence interval | **survey** |
| `05_combine_prior.R` | Combine prior + cores; is it precise enough? | *from scratch* |
| `06_advanced_spatial.R` | *Placeholder* — mapping where the carbon is. Not built yet | — |
| `view_prior.R` | Where are those sites, and how like mine are they? | **leaflet** |

`run_pipeline.R` runs steps 01–05 in order. `view_prior.R` is optional, and
`06_advanced_spatial.R` deliberately refuses to run — see below.

The pipeline **defers to established packages** wherever a peer-reviewed
implementation exists, so the methods can be cited rather than audited
line-by-line. Every script opens with a provenance note saying which parts are
a package and which are ours.

## Two ideas worth understanding before you trust the output

**The prior is a set of real cores, not a number.** `00b` filters the Janousek
synthesis to *Zostera marina* — the coast-wide average across all coastal
ecosystems is several times too high for eelgrass — then ranks every core by
how much its setting resembles yours (distance, estuary type, ecoregion,
climate) and builds the prior from the most specific group that still rests on
enough distinct estuaries. Narrowing further looks more precise but lands on a
handful of cores from one bay, which is specific to *that* bay, not yours.

**There are two standard deviations and they are not interchangeable.**

- `PRIOR_SD_PLOT` — core-to-core spread *within* a meadow. This is the CV in
  the sample-size calculator: it decides how many cores you need.
- `PRIOR_SD_MEAN` — meadow-to-meadow spread. This is what weights the prior
  against your own cores in step 06.

Using the first in the update makes the prior inert; using the standard error
of the synthesis mean lets a continental dataset outvote your fieldwork.

---

## Outputs

```
eelgrass_carbon_report.html     # the written report — start here
outputs/
├── maps/prior_cores.html       # the prior cores and yours, clickable
├── prior_eelgrass_janousek.png # the prior by estuary
└── prior_to_posterior.png      # prior, your cores, and the combination
data/
├── prior_eelgrass_janousek.csv # the derived prior (read by 00_config.R)
└── prior_cores.csv             # every candidate core + similarity flags
```

Render the report with `quarto::quarto_render("eelgrass_carbon_report.qmd")`.
It sources the pipeline rather than repeating it, so the report and the console
can never disagree.

## What is deliberately not here

**A map of where the carbon is.** Six cores cannot support one. An empirical
variogram is not identifiable below roughly 30 point-pairs, and in the worked
example every environmental covariate separates the two strata perfectly — a
model built on them restates the stratum rather than predicting anything.
`06_advanced_spatial.R` holds the notes and the three preconditions that have
to be met first; the working kriging code is preserved at
`draft/kriging_reference.R`. Step 04 is the deliverable this many cores *can*
support: an area-weighted estimate with an honest interval.

## Adapting this to your own site

1. Replace the three CSVs in `data/`.
2. Set `STRATUM_AREAS_M2` from your Step 1/Step 2 boundary.
3. Set `SITE_LAT`/`SITE_LON`, and check `PRIOR_EXCLUDE_ESTUARY` — run
   `view_prior.R` and look for synthesis cores sitting on top of yours.
4. Set `UTM_EPSG` for your coast (32610 = UTM 10N, BC; 32621 = UTM 21N, NL).
5. `source("run_pipeline.R")`.
