# Advanced and research material — not part of the first release

This folder holds the earlier, more ambitious version of the analysis. It is kept because parts
of it are useful starting points for later work, but **nothing in the workshop's basic workflow
depends on it**, and it should not be used to produce reported numbers in its current state.

It was moved here unchanged. File paths inside the scripts assume the old layout (scripts at the
`DataAnalysisWorkflow/` root), so they will not run from this folder without edits.

| File | What it was for |
|---|---|
| `00_config.R` … `05_combine_prior.R`, `run_pipeline.R` | The original pipeline: compaction → regional prior from Janousek et al. (2025) → mass-preserving spline (`mpspline2`) → stratified estimate (`survey`) → Bayesian prior–data combination |
| `06_advanced_spatial.R`, `draft/kriging_reference.R` | Notes and draft code for kriging / regression kriging |
| `view_prior.R` | Leaflet map of the prior cores |
| `eelgrass_carbon_report.qmd` / `.html` | The report built on that pipeline (stale — reflects an older dataset and settings) |
| `data/` | The constructed Tsawwassen teaching cores and the derived prior files |
| `README_original.md` | The original workflow README |

## Known issues (from the 2026 review — fix before reuse)

- `run_pipeline.R` always runs the prior steps, so nothing runs without the external
  Janousek download; the report cannot render without the prior.
- The spline is applied to SOC and bulk density **separately** and the results multiplied, so
  carbon mass is not exactly conserved.
- Missing bulk density is silently filled from stratum defaults (and then divided by the
  compaction factor); a missing compaction factor silently becomes 1; a missing SOC value makes
  the conservation check error out.
- "Every core reached the primary depth" is asserted in comments but never checked.
- The share of a stock that is modelled is overstated when the spline returns `NA` for a
  partly covered interval; the extrapolation cap is tested at the interval midpoint.
- A stratum with one core stops `survey` with an error; an unsampled stratum is dropped from
  the mean but its area is still used for the site total (biased total); per-stratum intervals
  use the overall degrees of freedom.
- The prior is eelgrass-only but was combined with a mean that included salt marsh.
- `exists()` guards silently reuse stale objects from the R session.
- `draft/kriging_reference.R` sources a file that no longer exists and sums depth intervals
  across cores of different lengths.

## What the first release reused from here

- The compaction correction and its carbon-conservation check (`01_prepare_cores.R`).
- The slice stock formula.
- The asymptotic decay model (`stats::SSasymp`) used below the core base (`03_harmonize_depths.R`),
  now fitted to carbon density rather than to SOC and bulk density separately.
- The `survey` stratified design set-up (`04_estimate_stock.R`).
