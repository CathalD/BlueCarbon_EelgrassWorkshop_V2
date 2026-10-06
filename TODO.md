# Workshop TODO — gaps to fill

A running checklist of everything the workshop still needs from you. Grouped by page.
Items are things only you can supply (photos, real data, lab quotes, video IDs) or
decisions to make. Tick them off as you go.

Legend: 📸 image/screenshot needed · 🔗 link needed · ✍️ writing needed · 📊 data needed · ❓ decision needed

---

## Landing page (`README.md`)

- [ ] ✍️ Add the **"Eelgrass Workshop Skills Checklist"** (placeholder comment near the Objectives list).
- [ ] ❓ Confirm the flipped ordering reads right: the two jobs are now listed **Making the data useful → Collecting the data** (plan-then-collect), to match the Section 2 → 3 order.

## Part 1 — Background (`01_Background/README.md`)

- [ ] ❓ The three carbon-curve GIFs are now wired to `images/download (Null).gif`, `download (pulse).gif`, and `download.gif`. Confirm each caption matches the correct animation (baseline equilibrium / single disturbance+recovery / pulse+press collapse).
- [ ] 🗑️ `images/download (1).gif` is unused — delete it or wire it in if it belongs somewhere.

## Part 2 — Project Planning (`02_Project_Planning/README.md`)

- [ ] 🔗 Step 1: Google Earth Engine boundary-drawing tool — replace *(link to be added)*.
- [ ] 🔗 Step 2: remote-sensing / auto-stratification method — replace *(links to be added)*.
- [ ] 🔗 Step 3 video callout (*"Site Selection and Required Materials"*): swap the playlist link for the **direct** video URL. There is also an empty 🎥 callout in Step 2.
- [ ] ❓ **Two sheets or three?** The intro says the calculator has *three sheets* but only Sheet 1 and Sheet 2 are documented. Either add a "Sheet 3" description or change the count to "two sheets."
- [ ] 📸 A small screenshot/GIF of the calculator's **"check precision after survey"** cells (SE / t-value / relative precision rows) to sit under the post-survey RME section.
- [ ] 📸 **Margin-of-error comparison** (Step 4): calculator at ±20% vs ±10% side by side, *n* readout circled.
- [ ] 📸 **Variability comparison** (Step 4): a smooth vs patchy meadow at the same target precision, showing *n* roughly quadruple as CV goes 0.5 → 1.0.
- [ ] 🔗 `Sampling Design Tools/SamplingPlanTool_README.md` names `BlueCarbon_SampleAllocation_2026.xlsx`; the file is `BlueCarbon_SampleAllocation_Spreadsheet_V2.xlsx`.
- [ ] ❓ **Detecting change over time.** Monitoring analysis is out of scope for this release (Part 2 explains what to keep so it stays possible). If repeat surveys become a goal, Part 2 would need a minimum-detectable-difference calculation at the design stage.

## Part 3 — Field Methods (`03_Field_Methods/README.md`)

- [ ] ✍️ **Field data sheet (Google Doc `Soil_Carbon_Datasheet_v2`)** — add a *Corer internal diameter (cm)* box to Step 2 Core Notes, then re-export both PDFs into `datasheets/`. Example sheet: latitude `49.003354`, date as `2026-06-16`, Study Area `Tsawwassen Beach, BC (teaching example)`.
- [ ] 📸 **NFLD corer photos** for the underwater / stop-cap section.
- [ ] 📸 A real field photo in **each of the 5 coring steps** (left-hand cells currently say *[Paste field photo]*).
- [ ] 📸 A workshop photo of the team coring / extruding, to anchor the "Extrude and section" step.
- [ ] 🔗 **Core Depths** video (step 1): needs its own direct URL — the old link pointed at the same clip as "Site Selection." Currently linked to the playlist with the position flagged.
- [ ] 📸 **Compaction method diagrams** (Step 3) — a blank two-panel table is in place: left cell for **Method A** (reading graduations on the tube), right cell for **Method B** (inside vs. outside distance from the tube top).

## Part 4 — Data Interpretation (`04_Data_Interpretation/README.md`)

- [ ] 🔗 **Google Sheets copy of the digital data sheet** predates the 2026 revision (carbon type, slice checks, depth increments, corer diameter setting). Replace it with an upload of `files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx`.
- [ ] 📸 Bagged samples next to the completed field data sheet ("arriving back from the field").
- [ ] 📸 The digital data sheet with example rows filled in, showing typed vs. auto-calculated columns.
- [ ] 📸 The example lab **submission** sheet, filled in.
- [ ] 📸 A rendered Option A figure (profiles or comparison) and a screenshot of `report_option_A.html`.
- [ ] 📸 An example summary figure / one-page results summary.
- [ ] 📊 **Lab directory table** — add real labs: website, contact, analyses, cost per sample, "quoted on" date.
- [ ] ✍️ Tidy the **References** into your preferred citation style.
- [ ] ❓ **Field Guide and Lab Guide corrections.** Part 4 lists where the workshop departs from the guides: the TC/OC note and "total ecosystem carbon" heading (p. 18), Eq 7, the bulk-density glossary entry, and the Lab Guide's × 0.5 LOI factor. Raise them with the guides' authors for the next edition.

## Analysis workflow (`04_Data_Interpretation/DataAnalysisWorkflow/`)

- [ ] ❓ **Published LOI equation.** The blank workbook ships with no LOI equation (participants enter a local calibration). If a published seagrass equation is ever offered as a fallback, verify its coefficients against the primary source first. The Fourqurean et al. (2012) figure currently quoted in some materials could not be checked.
- [ ] ✍️ **Going further, modules 5–6.** Port the hierarchical transfer model and the spatial prediction from the research prototype, starting from its lightest variant (ecosystem class plus the local update).
- [ ] 📊 Option B worked example uses a **hypothetical** boundary. If a mapped Cowichan eelgrass boundary with open terms becomes available, swap it in (and keep the exploratory design, since the cores were not randomly placed).

## Advanced material (`04_Data_Interpretation/DataAnalysisWorkflow/advanced/`)

The earlier pipeline is kept for reference and is not part of the participant workflow. Its known
issues are listed in `advanced/README.md`; fix them only if that material is brought back into use.

---

## Enhancements — implemented

- [x] **Shared field → lab → checks → core-stock foundation** with two analysis options (Part 4):
  Option A (core analysis and comparison with published eelgrass cores) and Option B (simple
  extrapolation within a defined area, design-based).
- [x] **Digital data sheet revised:** carbon type (OC / TC / LOI) with an explicit LOI equation; slice
  and core checks that never turn a blank into a zero; standard depth increments; corer diameter set
  once with a per-core override; workbook and R cross-checked.
- [x] **Mock lab results sheet** with a guide to reading it.
- [x] **Automated tests** of the calculations (`tests/testthat/`).
- [x] **Sample Size Visualizer to *show* the math** (Part 2).
- [x] **Reorganized Part 2** (A + B + C): roadmap table moved up front; sampling theory trimmed to
  a short primer; all how-many-samples math consolidated into Step 4.
- [x] Worked-example precision target resolved: ±20% at 90% confidence, matching the GEE sampling tool defaults.
