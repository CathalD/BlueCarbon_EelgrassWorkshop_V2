# Worked Example — Tsawwassen Beach, BC

*One dataset, followed end to end: from a filled-in data sheet to carbon-stock estimates.*

[← Back to the main guide](../README.md)

---

This folder holds the **completed** version of the workshop's worked example, so you can
see what a finished project looks like before (or while) you do your own. It follows a
single plot — **`WWF-01`** at Tsawwassen Beach, BC — with **twelve cores**: six in **salt
marsh** (`WWF-01-A/C/D/G/H/I`) and six in **eelgrass** (`WWF-01-B/E/F/J/K/L`).

The idea is simple: **work alongside this example, and apply the blank templates to your
own site.**

| You want… | Use this |
|---|---|
| A completed example to follow | this folder + the tables in [Part 4](../04_Data_Interpretation/) |
| A blank data sheet to fill in | [`04_Data_Interpretation/files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx`](../04_Data_Interpretation/files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx) |
| A blank sampling calculator | [`02_Project_Planning/`](../02_Project_Planning/) |
| The analysis workflow (reusable) | [`04_Data_Interpretation/DataAnalysisWorkflow/`](../04_Data_Interpretation/DataAnalysisWorkflow/) |

---

## What's here

- **[`02_Project_Planning.md`](02_Project_Planning.md)** — the planning walkthrough: how the team
  went from a carbon question to a target sample size and a set of coordinates, step by step.
- **[`04_Data_Interpretation.md`](04_Data_Interpretation.md)** — the analysis walkthrough: one
  core followed from a bagged sample to a carbon stock, then the whole campaign through to a
  reportable number.
- **[`Eelgrass_Carbon_DigitalData_Example.xlsx`](Eelgrass_Carbon_DigitalData_Example.xlsx)** —
  the digital data sheet, filled in: field measurements, lab results, and every calculated
  column (bulk density, carbon stock per slice, per-core totals).

The R pipeline in [`04_Data_Interpretation/DataAnalysisWorkflow/`](../04_Data_Interpretation/DataAnalysisWorkflow/)
runs on this exact dataset — its `data/` CSVs are a direct export of the sheet — so
`source("run_pipeline.R")` reproduces the analysis and report from these numbers.

## The thread, end to end

1. **Plan** ([Part 2](../02_Project_Planning/)) — how many cores, and where.
2. **Collect** ([Part 3](../03_Field_Methods/)) — the cores that fill the *Plot & Core Log*
   and *Sample Data* tabs of the sheet.
3. **Analyse** ([Part 4](../04_Data_Interpretation/)) — lab results complete the sheet, and
   the R pipeline turns them into carbon stocks.

## Headline result

The workflow's reported number is a stock to **25 cm**, the depth every core reached,
weighted by each stratum's area:

| | Result |
|---|---|
| Carbon stock 0–25 cm | **30.9 ± 1.4 Mg C/ha** |
| Site total over 5 ha | **154 Mg C** |
| Precision achieved | ±8.2% at 90% confidence — target met |
| Salt marsh vs eelgrass | **2.6 : 1** per m² to 25 cm |

Whole-core totals — every slice, to whatever depth each core reached — average
**10.0 kg C/m²** in the marsh and **2.2 kg C/m²** in the eelgrass, a ~4.6 : 1 contrast. That
is a different quantity from the 25 cm figure above, because the marsh cores are roughly
twice as long; the two are not comparable until standardised to a common depth, which is
what the workflow does. In both cases the marsh's higher carbon concentration outweighs its
lower bulk density, and the eelgrass mean sits inside the published range for Pacific
Canadian eelgrass.

**→ [The full analysis walkthrough](04_Data_Interpretation.md)**

> ⚠️ **This is constructed teaching data.** The coordinates and layout are realistic and the
> values are built to sit within published ranges for BC salt marsh and eelgrass, but they
> are **not field measurements** and must not be cited as such. See the provenance notes in
> [Part 4](../04_Data_Interpretation/) and cite the primary sources listed there.
