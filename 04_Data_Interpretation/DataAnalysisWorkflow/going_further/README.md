# Going further — optional modules

*For anyone who wants to borrow from published data, or move towards spatial prediction, one
idea at a time.*

[← Data analysis workflow](../README.md) · [Part 4 — Data Interpretation](../../README.md)

---

Options A and B are deliberately simple, and they are complete on their own. The modules here are
**optional**. Each one builds on the modules before it and adds one new idea — and with it, one
new set of assumptions that needs checking. Nothing in Options A or B depends on them.

| Module | Adds | Builds on | Status |
|---|---|---|---|
| 1 · Core stocks | Checked slices, slice and increment stocks | The workbook | Part of the workflow (shared foundation) |
| 2 · Option A | Comparison with published eelgrass cores | 1 | Part of the workflow |
| 3 · Option B | A design-based estimate for a defined area | 1 | Part of the workflow |
| **4 · Borrow from published cores** | A regional prior, updated with your cores | 1–3 | **Available** — [`module4_regional_prior/`](module4_regional_prior/) |
| **5 · Hierarchical transfer** | Depth-by-depth prediction that learns how estuaries, studies and lab methods differ | 4 | Roadmap — tested in a research prototype |
| **6 · Spatial prediction** | Satellite covariates and a prediction surface | 5 | Roadmap — tested in a research prototype |

> **Climbing the ladder changes what the result can claim.** Options A and B describe and estimate
> from your own measurements. Modules 4–6 are **model-based**: their answers are only as good as
> the assumption that your meadow behaves like the published ones. Report them alongside Option B,
> never instead of it.

---

## Module 4 — Borrow from published cores

*With only a few cores, how much do published eelgrass cores sharpen the estimate?*

**Question.** What is our meadow's mean sediment organic-carbon stock to a stated depth, combining
our own cores with what published cores from other estuaries already say?

**How it works.**

1. Take the same reference cores Option A uses (your estuary and anything within 100 m left out,
   same carbon basis).
2. Split their variation into *between estuaries* and *between cores within an estuary*, on the log
   scale.
3. Before any coring, a new estuary's mean is expected to sit somewhere in the between-estuary
   spread. That is the prior.
4. Your sampling units (plots, measured to the depth only) then update that expectation exactly.
   The weighting is the whole idea: with few cores the prior leans in, and with many your cores
   dominate.
5. **The check.** Each reference estuary in turn plays "your meadow". The prior is rebuilt without
   it, and the method is scored against cores it did not see. This shows whether the prior's
   intervals are honest and how fast local cores take over, on real data.

**Run it** (from the `DataAnalysisWorkflow/` folder):

```r
source("going_further/module4_regional_prior/run_module4.R")
```

Results go to `outputs/module4/`: the prior, local-only and combined estimates, the check, and a
short report.

**What it found on the worked example.** For the three Cowichan cores at 0–15 cm, the published
cores received about 15 % of the weight, and the combined estimate barely moved from the cores'
own mean. On the reference estuaries themselves, combining helped a little with 3–5 cores and not
with 1. Its 90 % intervals covered the truth only about 70–80 % of the time. That is a modest,
honest result: with estuaries this different from each other, a prior from 8 estuaries cannot say
much about a ninth.

**Assumes:** your sampling units behave like a random draw from your meadow; your meadow behaves
like one more estuary from the published set; the two spreads are known. **Does not include:** LOI
conversion error, laboratory error, or uncertainty in the spreads themselves.

The decomposition reuses `decompose_variance()` from the earlier pipeline
(`../advanced/02_derive_prior.R`). The update is the normal–normal model in Gelman et al. (2013),
*Bayesian Data Analysis*, §2.5.

---

## Module 5 — Hierarchical transfer (roadmap)

*Predicting carbon depth by depth, learning separately how estuaries, studies and lab methods differ.*

**The idea.** Module 4 treats every published core as equally comparable. Module 5 models log
carbon density in each standard increment with separate levels for region, estuary, study
(field and lab methods) and core. A community's cores then update the levels that describe *its*
estuary and *its* lab. A community with paired LOI and elemental-carbon measurements also
calibrates its own lab offset, with the uncertainty carried forward.

**Status.** Built and tested in a research prototype (a multilevel model fitted in Stan to
Pacific-coast cores, with Cowichan held out as the "community"), not yet ported here. A full fit
takes hours. The workshop version would start from the lightest variant: ecosystem only, plus the
local update.

**Lessons from the prototype, to carry forward:**

- **The value is in the update.** A prior built only from published cores did about as well as the
  plain distribution of same-ecosystem cores, and was better calibrated. It became most useful once
  a handful of local cores updated it.
- **Methods differ as much as places do.** Differences between *studies* (field and lab methods)
  were about as large as differences between cores in one estuary. Calibrating your own lab's LOI
  against elemental carbon on a subset of samples is worth doing.
- **Don't convert LOI with a fixed factor.** In the eelgrass reference cores, organic carbon is a
  median 0.18 of LOI, not 0.5 ([`check_loi_ratio.R`](../data-raw/check_loi_ratio.R)).
- **Check compilations for padded rows.** Published compilations can extend short cores with
  copied rows below their real base. Use only slices marked as measured. The workshop's checks
  also warn about a slice that exactly repeats the one above.
- **Hold out whole estuaries, not single cores**, when testing a prior. Otherwise the test leaks.
- **Deep stocks (0–100 cm) are where any prior is least reliable.** Most published cores are short.

---

## Module 6 — Spatial prediction (roadmap)

*A prediction surface from satellite covariates — clearly labelled as a prediction, not a measured stock.*

**The idea.** Add covariates that vary across the landscape — tidal wetness from Sentinel-2,
vegetation, elevation, climate — so the model from module 5 can predict carbon pixel by pixel. The
output is a **prediction surface** with its own uncertainty. It is not a design-based estimate, and
not a validated stock map.

**Status.** Tested in the same research prototype (Earth Engine covariates on a 30 m export grid).
Not ported.

**Lessons from the prototype, to carry forward:**

- **Covariates added little beyond ecosystem class.** Most of what satellite covariates "explained"
  was re-detecting whether a pixel was marsh, flat or seagrass. Start with ecosystem class only.
- **Satellite wetness does not transfer between estuaries.** Each site is imaged at a different
  point in the tide, so the same wetness value means different things in different estuaries. It
  ranks pixels *within* an estuary, at best.
- **The map domain is the hardest part.** Rules based on elevation and wetness swept in diked fields
  that flood with the river. A boundary drawn by the community, as in Option B, is better than one
  inferred from imagery.
- **Seagrass is hard to see from space.** Imagery alone separated eelgrass poorly from bare flat, and
  subtidal extent cannot be seen at all.
- **30 m pixels are an export grid, not 30 m accuracy.**
- **Reproducibility needs care.** Fix and seed the order of posterior draws, so that identical runs
  give identical maps.
