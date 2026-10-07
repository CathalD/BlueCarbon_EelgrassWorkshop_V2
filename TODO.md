# Workshop TODO — gaps to fill

A running checklist of everything the workshop still needs from you. Grouped by page.
Items are things only you can supply (photos, real data, lab quotes, video IDs) or
decisions to make. Tick them off as you go.

Legend: 📸 image/screenshot needed · 🔗 link needed · ✍️ writing needed · 📊 data needed · ❓ decision needed

---

## Shot list — images only you can take

- [ ] 📸 **GEE boundary**, exported as a file (Part 2, Step 1). The screenshot is in place; the saved boundary itself is not yet in the repo.
- [ ] 📸 **The exported coordinate list** (Part 2, Step 5) — the first rows of the CSV the tool downloads, beside the map.
- [ ] 📸 **A real labelled bag beside its sheet row** (Part 3, Extrude and section; Part 4, Figure 1), with the label readable. Figure 1 shows a drawn label, marked as an illustration, until then.
- [ ] 📸 **NFLD corer photos** for the underwater / stop-cap section, and a check of the stop-cap wording ("suction from the sealed cap holds the sediment in the tube") against the device and video.
- [ ] 📸 A workshop photo of the team coring or extruding, for the "Extrude and section" step.
- [ ] 📸 The example lab **submission** sheet, filled in (Part 4, Step 1.3).
- [ ] 📸 **The first RStudio screen** after `use_course()`: the new project open, with `Start_Here.R` in front and the Files pane showing `my_data/` (Part 4, Run it yourself; workflow quick start). Needs RStudio's window, so only you can take it.

## Landing page (`README.md`)

- [ ] ✍️ Add the **"Eelgrass Workshop Skills Checklist"** (placeholder comment near the Objectives list).
- [ ] ❓ Confirm the flipped ordering reads right: the two jobs are now listed **Making the data useful → Collecting the data** (plan-then-collect), to match the Section 2 → 3 order.

## Part 1 — Background (`01_Background/README.md`)

- [ ] 🗑️ `images/carbon_disturbance_resilience.gif` (1.9 MB) is unused. It shows a single disturbance and recovery, like `carbon_disturbance_and_recovery.gif`, from a different view of the visualizer. Delete it or wire it in.
- [ ] ❓ The "Carbon Pools in Seagrass Ecosystems" slide (`images/eelgrass_sediment_carbon_slide.png`) labels its axis "mg of CO2 per hectare" (should be Mg) and compares global averages with forests. The text beside it now explains both; consider correcting the slide itself. Check the other slides for the same uptake / sequestration / stock wording.

## Part 2 — Project Planning (`02_Project_Planning/README.md`)

- [ ] 🔗 Step 3 video callout (*"Site Selection and Required Materials"*): swap the playlist link for the **direct** video URL.
- [ ] 📸 **Margin-of-error comparison** (Step 4): calculator at ±20% vs ±10% side by side, *n* readout circled. Sheet 5 of the calculator now shows this as a grid.
- [ ] 🔗 `Sampling Design Tools/SamplingPlanTool_README.md` names `BlueCarbon_SampleAllocation_2026.xlsx`; the file is `BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx`.
- [ ] ❓ **Detecting change over time.** Monitoring analysis is out of scope for this release (Part 2 explains what to keep so it stays possible). If repeat surveys become a goal, Part 2 would need a minimum-detectable-difference calculation at the design stage.

## Part 3 — Field Methods (`03_Field_Methods/README.md`)

- [ ] 🔗 **Core Depths** video (step 1): needs its own direct URL if the current one is shared with "Site Selection."

## Part 4 — Data Interpretation (`04_Data_Interpretation/README.md`)

- [ ] 🔗 **Online copy of the digital data sheet.** The old Google Sheets link predated the 2026 revision and was removed. Re-upload `DataAnalysisWorkflow/workbooks/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx` if you want an online copy, and link it in Part 4, Step 1.1.
- [ ] 📊 **Lab directory table** — hidden (as an HTML comment in Step 1.3) until it has verified entries: website, contact, analyses, cost per sample, "quoted on" date.
- [ ] ✍️ Tidy the **References** into your preferred citation style.
- [ ] ❓ **Field Guide and Lab Guide corrections.** Part 4 lists where the workshop departs from the guides: the TC/OC note and "total ecosystem carbon" heading (p. 18), Eq 7, the bulk-density glossary entry, and the Lab Guide's × 0.5 LOI factor. Raise them with the guides' authors for the next edition.
- [ ] ❓ **A low bulk-density check.** The slice check flags bulk density above 2.65 g/cm³ but not values near zero, which is what a dry weight typed in kilograms produces. Consider adding a lower bound (around 0.05 g/cm³) to the workbook and R checks.

## Analysis workflow (`04_Data_Interpretation/DataAnalysisWorkflow/`)

- [ ] ❓ **Publish the participant download.** Part 4 and the workflow quick start point participants at
  `usethis::use_course(".../releases/latest/download/BlueCarbon_Part4_Workshop.zip")`, which works once a
  release carries that file. Build it with `sh data-raw/build_course_zip.sh`, attach
  `dist/BlueCarbon_Part4_Workshop.zip` to a release (a draft first), and before announcing check that
  `curl -sIL <that URL>` ends in `content-type: application/zip` — `use_course()` refuses any other type.
  Until then, *Code → Download ZIP* and opening the `.Rproj` works.
- [ ] ❓ **Posit Cloud** (later): a base project with the packages installed, shared by link, as a
  no-install alternative to the local route.

- [ ] ❓ **Published LOI equation.** The blank workbook ships with no LOI equation (participants enter a local calibration). If a published seagrass equation is ever offered as a fallback, verify its coefficients against the primary source first. The Fourqurean et al. (2012) figure quoted in older materials could not be checked.
- [ ] ✍️ **Going further, modules 5–6.** Port the hierarchical transfer model and the spatial prediction from the research prototype, starting from its lightest variant (ecosystem class plus the local update).
- [ ] 📊 Option B worked example uses a **hypothetical** boundary. If a mapped Cowichan eelgrass boundary with open terms becomes available, swap it in (and keep the exploratory design, since the cores were not randomly placed).
- [ ] 🔄 After changing the workbooks, calculator or analysis, regenerate the figures: `sh data-raw/rebuild_workbooks.sh`, `sh data-raw/update_calculator.sh`, then `sh data-raw/render_screenshots.sh` (see each script's header).

## Advanced material (`04_Data_Interpretation/DataAnalysisWorkflow/advanced/`)

The earlier pipeline is kept for reference and is not part of the participant workflow. Its known
issues are listed in `advanced/README.md`; fix them only if that material is brought back into use.

---

## Enhancements — implemented

- [x] **Shared field → lab → checks → core-stock foundation** with two analysis options (Part 4).
- [x] **Option B leads with a measured depth**; deeper figures are labelled scenarios, limited by core length (Janousek et al. 2025).
- [x] **Finite-population correction made optional** (default off) in the workflow and the calculator; precision check uses t.
- [x] **Sampling claims corrected** in Part 2: confidence interpretation, when the finite-population correction applies, regional priors as planning scenarios, what to do after a missed target.
- [x] **Worked examples named consistently**: Tsawwassen (constructed planning and field practice) and Cowichan (published measurements); provenance key on the mock lab sheet and the Example workbook.
- [x] **Figures kept in the repository**: all images downloaded from GitHub attachments, GIFs renamed with static key frames, generated figures and example reports reproducible from `data-raw/`.
- [x] **Digital data sheet revised:** carbon type (OC / TC / LOI) with an explicit LOI equation; slice and core checks that never turn a blank into a zero; standard depth increments; corer diameter set once with a per-core override; workbook and R cross-checked.
- [x] **Automated tests** of the calculations (`tests/testthat/`).
- [x] **Field data sheet corrected** in the Google Doc (`Soil_Carbon_Datasheet_v2`; a backup copy was made first): stratum and corer internal diameter boxes added. A separate filled copy holds the constructed Tsawwassen example (`WWF-01-A`, Zone 3, coordinates inside the plan boundary, ISO date). Both PDFs re-exported; the Part 3 crops and Part 4 Figure 1 are cut from them by `data-raw/make_datasheet_figures.R`.
