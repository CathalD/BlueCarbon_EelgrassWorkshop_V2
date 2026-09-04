# Part 4 — Data Interpretation

*From sediment samples to carbon-stock estimates.*

[← 3 — Field Methods](../03_Field_Methods/) · [Back to main guide](../README.md)

---

## Overview

This section covers what happens after the cores come out of the field: prepping your samples,
digitizing your field sheet, sending samples to a lab, and turning what the lab returns into a
carbon stock you can report.

It follows WWF-Canada's field guide (*Part 3: Sample Analysis* and *Part 4: Calculating Carbon
Stocks*, pp. 15–19 of the [Coastal Blue Carbon Field Guide](../Coastal-Blue-Carbon-Field-Guide-FINAL.pdf)),
with a dedicated [Lab Guide](Lab-Guide-Eng-2026.pdf) for the laboratory procedures, alongside
Howard et al. (2014).

There are three steps:

| # | Step | Answers |
|---|------|---------|
| 1 | **[Get your samples measured](#step-1--from-the-field-to-the-lab)** | *How do I prep samples, digitize my data, and find a lab?* |
| 2 | **[Run the analysis](#step-2--the-community-mapping-workflow)** | *How do I turn lab numbers into carbon stocks?* |
| 3 | **[Report the results](#step-3--reporting-the-results)** | *What do I report, and what does each number mean?* |

> 🧭 **Want to see it done?** A full worked example — six cores followed from bagged samples to
> a reportable carbon stock — lives in
> **[`Worked_Example/04_Data_Interpretation.md`](../Worked_Example/04_Data_Interpretation.md)**.

---

## Step 1 — From the field to the lab

You come back from the field with two things:

1. **A cooler of bagged samples**, which need to be processed and prepped for the lab.
2. **A completed paper field data sheet**, which needs to be digitized.

The rest of this step deals with each in turn, then with getting the samples analysed.

> 🎥 **Watch:** [*Processing cores*](https://www.youtube.com/shorts/wZccCeFPZqY) — a short
> walkthrough of what sample processing looks like.

---

### 1.1 Digitize the data sheet

*Type your field notes into the digital sheet, which calculates the rest for you.*

The paper datasheet records information at two levels, and the digital sheet keeps them on two
separate tabs for that reason: some things are true of the **whole core**, and some are true of a
**single slice**.

**Recorded once per core** — the *Plot & Core Log* tab:

| Field | What it is | Example |
|---|---|---|
| Plot ID | The plot the core was taken in | `WWF-01` |
| Core ID | Unique identifier: site, plot, sampling location | `WWF-01-A` |
| Date / Time | When the core was taken | 2025-06-25, 11:32 |
| Study area / site | Location and stratum | Tsawwassen Beach — salt marsh |
| Latitude / Longitude | Coordinates of the core | 49.003354, −123.131287 |
| Photo series ID | Links the core to its photo record | `WWF-01-A-P` |
| Weather / tidal conditions | Context for the sampling day | Overcast, 17 °C; low tide 18:02 |
| Corer internal diameter (cm) | Sets the cross-sectional area — **measure it, don't assume it** | 7.62 |
| Outside depth (cm) | How far the corer was driven in (penetration) | 65.0 |
| Inside depth (cm) | Length of core actually recovered | 58.0 |

**Recorded once per slice** — the *Sample Data* tab:

| Field | What it is | Example |
|---|---|---|
| Core ID | Must match the Core Log exactly | `WWF-01-A` |
| Sample ID | Slice number, counting down from the surface | 1 |
| Top depth (cm) | Top of the slice, measured down the core | 0 |
| Bottom depth (cm) | Bottom of the slice | 5 |
| Notes | Texture, colour, roots, shell, rocks | Dense live root mat, dark brown silty clay |

> 📸 **[SCREENSHOT NEEDED]** — the completed paper field data sheet.
>
> 📸 **[SCREENSHOT NEEDED]** — the same sheet digitized, so readers can see how one transfers
> onto the other.

**The digital data sheet**

**📊 [Open the digital data sheet in Google Sheets](https://docs.google.com/spreadsheets/d/1XMA_zaFNKtxCw2tAiQa3gHaIiT_wJAecmwW7Rz4hhaQ/edit?usp=sharing)**
· blank copy: [`files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx`](files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx)

The workbook has four tabs, in the same order as the workflow:

| Tab | What it holds | Do you type in it? |
|---|---|---|
| **1. Instructions** | Legend, colour key, units, and the field names the analysis expects | No |
| **2. Plot & Core Log** | One row per core — plot/core notes, corer diameter, insertion depths | Yes |
| **3. Sample Data** | One row per slice, in four bands: field · calculated · lab · calculated | Yes |
| **4. Core Summary** | Per-core totals, calculated automatically | No |

Only the **yellow cells** are for typing. Everything grey is a formula — depth interval, volume,
compaction factor, and, once lab results arrive, bulk density and carbon stock.

> ⚠️ **Core IDs must match across tabs.** The compaction factor and corer diameter are looked up
> from the Core Log by Core ID. If the ID on the *Sample Data* tab doesn't match, those cells stay
> blank rather than silently using another core's geometry.

---

### 1.2 Prep the samples

*Process the sediment, and work out how much of it you have.*

**Physical preparation.** Samples should be frozen at −20 °C for storage, then thawed at 5–6 °C for
2–5 days, dried at 65 °C to a stable weight, and ground homogeneous before analysis. See the
[Lab Guide](Lab-Guide-Eng-2026.pdf) for the full procedure and packaging requirements.

> 🎥 **Also:** [*Core Sample Analysis*](https://www.youtube.com/watch?v=BuLRrFD78Fs&list=PLLsjpJMfNDP5w78ZJNDUvMj1VoRG_qSwd&index=11) — workshop playlist
> · [IORA Blue Carbon Hub — sample analysis](https://www.youtube.com/watch?v=_Zm9R-kGiE8&list=PL9pJDSsl2ZslDVZ5oZ5MFkykY2Kn9rDS8&index=6)

**Depth interval and volume.** Every slice needs a volume, because volume is the denominator of
bulk density. Both columns are calculated for you in the digital sheet — you only ever type the top
and bottom depths — but the arithmetic is simple:

| Quantity | Formula |
|---|---|
| Depth interval (cm) | bottom depth − top depth |
| Corer face area (cm²) | π r², where r = internal diameter ÷ 2 |
| Volume (cm³) | depth interval × corer face area |

For a corer with a 7.62 cm (3″) internal diameter, area = π × 3.81² = **45.60 cm²**. A 2 cm slice
therefore has a volume of 2 × 45.60 = **91.2 cm³**, matching the field guide (p. 17).

> ⚠️ **Measure your actual internal diameter.** Nominal pipe size is not internal diameter — a
> "3-inch" Schedule 40 PVC pipe has an ID noticeably larger than 7.62 cm, and wall thickness varies
> by schedule and supplier. Because volume sits in the bulk-density denominator, an unchecked
> diameter propagates as a **systematic bias** into every bulk density, and therefore every carbon
> stock, in the entire dataset. Measure the tubing you actually used with calipers.

**What the calculation ultimately needs.** For every core sampling location, three things:

| Input | How it's obtained |
|---|---|
| Sediment depth (cm) | Measured in the field, recorded on the Core Log |
| Dry bulk density (g/cm³) | A scale and a drying oven — or the lab |
| Organic carbon (%) | A lab with carbon analysis equipment |

Bulk density you can measure yourself. Carbon analysis needs more equipment, so at this stage
samples usually go to a specialist laboratory.

---

### 1.3 Find a lab and submit your samples

*Choose a lab, then send samples and a manifest that matches your bag labels.*

<details>
<summary><b>📋 Laboratories offering sediment carbon analysis</b> (click to expand)</summary>

<br>

<!-- TODO (Cathal): fill in as you confirm labs, quotes and turnaround. Keep the "quoted on" date so costs can be re-checked — prices go stale fast. -->

| Lab | Website | Contact | Analyses offered | Cost (per sample) | Quoted on |
|---|---|---|---|---|---|
| *(add lab)* | | | | | |
| *(add lab)* | | | | | |
| *(add lab)* | | | | | |

</details>

**What to ask when comparing quotes**

- Is the price per sample or per batch, and does it include drying and grinding?
- Is **inorganic carbon** removed (acidification) or reported separately? This changes what "total
  carbon" means on your results sheet.
- What is the **method detection limit**? Eelgrass sediments are often low-carbon and can sit near
  the limit of some methods.
- Are **replicates and reference standards** run, and are you charged for them?
- What is the minimum sample mass, and do they accept frozen or dried samples?

**What to send**

<!-- TODO (Cathal): confirm the specifics below against whichever lab you go with, and against the Lab Guide. -->

| Item | Detail |
|---|---|
| The samples | Labelled with the Core ID convention from [Section 3](../03_Field_Methods/) — site, plot, sampling location, depth interval |
| A sample manifest | One row per sample, matching the bag labels exactly. This is the table you already built in the digital sheet, plus the calculated volume |
| The analyses you want | Dry bulk density, organic carbon, and whether you also want inorganic carbon, total carbon, N, or isotopes |
| Packaging and shipping | Frozen vs. dried, courier, and arrival timing — so samples aren't sitting at a loading dock over a weekend |

Requirements vary between labs, so confirm theirs before shipping.

> 📸 **[SCREENSHOT NEEDED]** — a filled-in lab submission sheet, showing how the field datasheet
> transfers across.

---

### 1.4 What comes back from the lab

*Two numbers per slice, which map straight onto the analysis inputs.*

| Lab measurement | Analysis field | Notes |
|---|---|---|
| Organic carbon | `soc_g_kg` | Often measured by loss-on-ignition (LOI₅₅₀); for best accuracy the guide recommends total carbon on an elemental analyser (p. 16) |
| Dry bulk density | `bulk_density_g_cm3` | Dry mass ÷ original sample volume (p. 17) |

These two columns are named exactly that way on the *Sample Data* tab, so the sheet can be exported
and loaded without renaming anything.

<details>
<summary><b>🔬 How the lab measures carbon</b> — LOI and elemental analysis (click to expand)</summary>

<br>

**Loss-on-ignition (LOI)**

LOI burns a dried, ground portion of each sample in a muffle furnace at 550 °C. The organic material
— what used to be plant matter — ignites and leaves as carbon dioxide and water. It is the same
process as a campfire: the wood burns off, and what's left in the morning is ash, the non-organic
material that doesn't burn at that temperature.

Weighing the sample before and after gives the mass of organic matter lost. A **carbon conversion
factor** then converts organic matter to carbon.

> ⚠️ **The conversion factor is the weak link.** LOI measures *organic matter*, not carbon. A
> commonly used value for seagrass sediments is ~0.43 (Fourqurean et al. 2012, for sediments with
> >0.2% OM), but the true ratio varies with organic-matter source and mineralogy. Clay-rich samples
> can also lose structural water at 550 °C, inflating apparent organic matter. If your numbers need
> to withstand scrutiny — a credited project, for example — validate LOI against elemental analysis
> on a subset of samples, and report the relationship you used.

**Elemental analysis (CHN / CHNS)**

An elemental analyser measures carbon directly rather than inferring it from mass loss. A few
milligrams of dried, ground sample, sealed in a tin capsule, is dropped into a combustion column at
roughly 950–1150 °C in an oxygen-enriched atmosphere. Everything combusts; the resulting CO₂, H₂O
and N₂ are separated and quantified against standards of known composition.

Because each element is measured as its own gas, one run reports carbon, hydrogen and nitrogen as a
percentage of dry mass:

- **Carbon (C)** — total carbon. If the sediment contains shell or other carbonates this includes
  inorganic carbon, so samples are usually **acidified** first, or inorganic carbon is measured
  separately and subtracted.
- **Nitrogen (N)** — gives you the **C:N ratio**, a source indicator. Low C:N points to
  marine/algal material; higher C:N to vascular plant or terrestrial input. Paired with δ¹³C, this
  is how you separate carbon the meadow produced itself (autochthonous) from carbon it trapped
  (allochthonous) — a distinction that matters for crediting.
- **Hydrogen (H)** — mainly a diagnostic of organic-matter type and combustion completeness;
  reported routinely, used less often in blue carbon accounting.

The trade-off is cost and access. Elemental analysis is more expensive per sample and needs a
specialist lab; LOI is cheap and uses the same equipment you already need for bulk density. A common
compromise is **LOI on all samples, elemental analysis on a representative subset**, then using the
calibration to correct the LOI series.

</details>

For the most accurate results, send samples for total carbon measurement on an elemental analyser.

---

## Step 2 — The Community Mapping Workflow

*A reproducible R workflow that takes lab results to a carbon stock with an honest confidence
interval.*

The workflow corrects for core compaction, standardises cores to common depths, estimates an
area-weighted stock across your strata, and combines the result with what was already known about
meadows like yours.

You do not need to write R to use it. Everything site-specific lives in one settings file, and the
workflow runs with a single line:

```r
source("run_pipeline.R")
```

**👉 [`CommunityMappingWorkflow/`](CommunityMappingWorkflow/) — how to install it, what data it
needs, and what every dial does, in its [README](CommunityMappingWorkflow/README.md).**

Two things worth knowing before you run it:

- **The estimator is stratified.** [Section 2](../02_Project_Planning/) designs a stratified sample,
  so the analysis weights each stratum's mean by its **area**, not by how many cores landed in it.
- **It reports two stock numbers, not one.** A primary depth every core physically reached (25 cm by
  default, comparable to the published literature), and a deeper figure that is partly modelled,
  with the modelled share stated per core.

Wherever a peer-reviewed implementation exists the workflow uses it rather than re-writing it, so
the methods can be cited instead of audited line by line.

A pre-rendered report —
[`CommunityMappingWorkflow/eelgrass_carbon_report.html`](CommunityMappingWorkflow/eelgrass_carbon_report.html)
— walks through a full analysis and opens in any browser without running R.

<details>
<summary><b>🧮 How the carbon-stock formula relates to the field guide</b></summary>

<br>

The single line the workflow uses is the field guide's equations 3–6 (pp. 17–18) combined:

```
Carbon stock (kg C/m²) = SOC (g/kg) × bulk density (g/cm³) × layer thickness (cm) ÷ 100
```

Per slice, the guide computes sediment carbon density = bulk density × (%C ⁄ 100), multiplies by the
depth interval to get g C/cm², sums the slices, and ×10 to reach kg C/m². Because organic carbon in
g/kg is ten times %C, that chain reduces to the one formula above. Summing slices per core,
averaging across cores, and scaling by area then gives the site total (guide equations 7–10).

</details>

<details>
<summary><b>🧮 Why compaction correction doesn't change the total</b></summary>

<br>

The tube holds exactly the sediment that came out of the hole. Decompaction only restores where each
slice sat — so the correction has two halves, and they cancel: **depths stretch** by the compaction
factor, and **bulk density thins** by the same factor, because the same dry mass now occupies a
taller column.

$$\text{carbon} = \text{SOC} \times \underbrace{(\text{BD} \div \text{CF})}_{\text{thinner}} \times \underbrace{(\text{thickness} \times \text{CF})}_{\text{taller}}$$

Stretching the depths *without* thinning the density inflates every stock by exactly the compaction
factor. The workflow asserts the total is unchanged and stops if it is not.

A useful check: the deepest corrected depth should equal the outside (penetration) depth on the Core
Log — 58 cm recovered × 1.121 = 65 cm penetrated.

</details>

---

## Step 3 — Reporting the results

*Four numbers, answering four different questions.*

### What every report needs

| Report | Why |
|---|---|
| Carbon stock **with an uncertainty estimate** | A bare point value can't be checked or compared |
| The **depth interval** the stock refers to | Stocks are not comparable without it |
| **Sample sizes** — cores, slices, strata | Tells a reader how much the estimate rests on |
| **Methods** — LOI or elemental analysis, and any conversion factor | Determines what "carbon" means in your numbers |

### What each number means

| Number | What it is | How to read it |
|---|---|---|
| **1. Measured stock** | Stock to a depth every core reached | Lead with this. It's fully measured and directly comparable to the published literature, which mostly reports 0–25 cm |
| **2. Deeper stock** | Measured plus modelled below core base | Report the modelled share per core. A number that is 39% modelled is still useful; one that is 39% modelled and presented as measured is not |
| **3. Precision achieved** | Your interval against your target | The number most reports omit and most reviewers ask for. "Target met at ±18%" tells a reader more than the point estimate does |
| **4. Combined estimate** | Your cores plus the regional prior | How much weight the prior earned is itself a finding. It leans in hardest when your own data is thinnest, and steps back as you collect more |

> **Missing your precision target is not a failed survey.** It is a survey that has told you what
> the next one needs to look like — and the workflow prints how many cores would close the gap. The
> failure mode is reporting a point estimate as though the target had been met.

**What the numbers cannot tell you.** A handful of cores gives you an average for the meadow and a
comparison between strata. It does not give you *where* the carbon is, and any figure implying
otherwise is over-claiming. That question needs an order of magnitude more cores.

### Communicating with partners

The hard part is not the statistics. It is that the honest version has an interval in it, and most
audiences want a single number. Three things help:

**Lead with the total, carry the interval.** "Roughly 155 tonnes of carbon in the top 25 cm of this
5-hectare inlet, give or take about 8%" is both honest and understandable. The tonnage is what
people can picture; the interval is what keeps you credible when someone re-surveys.

**Never quote a stock without its depth.** Most disagreements between two carbon numbers for the
same meadow turn out to be a depth-basis mismatch rather than a real difference — a 0–1 m figure is
roughly three times a 0–25 cm one.

**Say what would change the answer.** Partners trust an estimate more when they know its limits.
Stratum areas drawn from a boundary rather than surveyed, or a deeper figure that is partly
modelled, are both fixable — and naming them turns a caveat into a plan for next season.

**Be careful with the word "sequestration".** This workflow measures a **stock** — carbon that is in
the sediment now. Sequestration is a *rate*: how fast carbon is being added, which needs dated cores
(²¹⁰Pb or ¹⁴C) that this workflow does not use. Reporting a stock as a sequestration rate is the
most common error in blue-carbon communication, and the one a technical reviewer will catch first.

> 📸 **[SCREENSHOT NEEDED]** — an example summary figure or one-page results summary.

---

## References

- WWF-Canada (2026). *Coastal Blue Carbon Field Guide: Measuring Carbon in Coastal Sediments.*
  [PDF](../Coastal-Blue-Carbon-Field-Guide-FINAL.pdf)
- WWF-Canada (2026). *Lab Guide.* [PDF](Lab-Guide-Eng-2026.pdf)
- Howard, J. et al. (2014). *Coastal Blue Carbon: Methods for assessing carbon stocks and emissions
  factors in mangroves, tidal salt marshes, and seagrass meadows.*

---

## In this section

- [`CommunityMappingWorkflow/`](CommunityMappingWorkflow/) — the R analysis workflow, with its own
  quick-start README.
- [`files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx`](files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx) — blank digital data sheet.
- [`Lab-Guide-Eng-2026.pdf`](Lab-Guide-Eng-2026.pdf) — WWF-Canada laboratory procedures guide.
- `images/` — lab result screenshots and analysis figures.

## Elsewhere

- **[Worked example — Part 4](../Worked_Example/04_Data_Interpretation.md)** — a full analysis, one
  core followed from a bagged sample to a carbon stock.
- [Worked example — Part 2](../Worked_Example/02_Project_Planning.md) — how the same team planned
  the campaign.
- [Part 3 — Field Methods](../03_Field_Methods/) — where the cores and compaction measurements come
  from.
