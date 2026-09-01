# Part 4 — Data Interpretation

*From sediment samples to carbon-stock estimates.*

[← 3 — Field Methods](../03_Field_Methods/) · [Back to main guide](../README.md)

---

## Overview

This section covers what happens after the cores come out of the field: organizing your
field data, sending samples to a lab, understanding what the lab returns, analysing those
results, and interpreting them for reporting and planning. Here we follow WWF-Canada's field
guide (*Part 3: Sample Analysis* and *Part 4: Calculating Carbon Stocks*, pp. 15–19 of the
[Coastal Blue Carbon Field Guide](../Coastal-Blue-Carbon-Field-Guide-FINAL.pdf)), with a
dedicated [Lab Guide](Lab-Guide-Eng-2026.pdf) for the laboratory procedures, alongside
Howard et al. (2014).

After sampling, three steps take you from bagged samples to a reportable carbon estimate:

| # | Step | Answers | Covered in |
|---|------|---------|------------|
| 1 | **Organize data and get it analysed** | *How do I get my samples measured?* | [Section 1.1](#11-organizing-data-and-submitting-to-a-lab) · [Section 1.2](#12-expected-lab-results) |
| 2 | **Analyse the data** | *How do I turn lab numbers into carbon stocks?* | [Section 2 — the analysis workflow](#2-the-analysis-workflow) |
| 3 | **Report and use the results** | *How do I communicate and act on it?* | [Section 3](#3-reporting-and-using-the-results) |

> 🧭 **The worked example.** Throughout this section, the grey **📊 dropdowns** show what one
> real team did — six cores from a small inlet at **Tsawwassen Beach, BC** (plot `WWF-01`),
> three in **salt marsh** and three in **eelgrass**. Open them to see the numbers; skip them
> to read the method straight through.
>
> **→ [Read the full analysis walkthrough](../Worked_Example/04_Data_Interpretation.md)**

---

## 1.1 Organizing data and submitting to a lab

*What do I send, and to whom?*

Consider the data collected from the field in the previous module: we have bagged samples in
labelled Ziploc bags, and a completed data sheet.

> 📸 **[SCREENSHOT NEEDED]** — the bagged samples alongside the completed field data sheet,
> so the reader can see what "arriving back from the field" actually looks like.

### What comes back from the field

The paper datasheet records information at two levels, and the spreadsheet keeps them on two
separate tabs for exactly that reason: some things are true of the **whole core**, and some
are true of a **single slice**.

**Recorded once per core** — this is the *Plot & Core Log* tab:

| Field | What it is | Example (`WWF-01-A`) |
|---|---|---|
| Plot ID | The plot the core was taken in | `WWF-01` |
| Core ID | Unique identifier: site, plot, sampling location | `WWF-01-A` |
| Date / Time | When the core was taken | 2025-06-25, 11:32 |
| Study area / site | Location and stratum | Tsawwassen Beach — salt marsh |
| Latitude / Longitude | Coordinates of the core | 49.003354, −123.131287 |
| Photo series ID | Links the core to its photo record | `WWF-01-A-P` |
| Weather / tidal conditions | Context for the sampling day | Slightly overcast, 17 °C; low tide 18:02 (1.429 m) |
| Corer internal diameter (cm) | Sets the cross-sectional area — **measure it, don't assume it** | 7.62 |
| Outside depth (cm) | How far the corer was driven in (penetration) | 65.0 |
| Inside depth (cm) | Length of core actually recovered | 58.0 |

**Recorded once per slice** — this is the *Sample Data* tab:

| Field | What it is | Example (`WWF-01-A`, slice 1) |
|---|---|---|
| Core ID | Must match the Core Log exactly | `WWF-01-A` |
| Sample ID | Slice number, counting down from the surface | 1 |
| Top depth (cm) | Top of the slice, measured down the core | 0 |
| Bottom depth (cm) | Bottom of the slice | 5 |
| Notes | Texture, colour, roots, shell, rocks | Dense live root mat, dark brown silty clay |

<details>
<summary><b>📊 What the Tsawwassen team recorded</b> &nbsp;·&nbsp; <i>one core, as it appears in the spreadsheet</i></summary>

<br>

Core `WWF-01-A` was driven **65 cm** into the sediment and returned **58 cm** of core. Laid
out on the *Sample Data* tab, its six slices look like this:

| Core ID | Sample ID | Top depth (cm) | Bottom depth (cm) | Notes |
|---|---|---|---|---|
| WWF-01-A | 1 | 0 | 5 | Dense live root mat, dark brown silty clay |
| WWF-01-A | 2 | 5 | 10 | Root mat thinning, dark brown silty clay |
| WWF-01-A | 3 | 10 | 15 | Fine roots, dark grey-brown silt |
| WWF-01-A | 4 | 15 | 25 | Occasional root fragments, grey silty clay |
| WWF-01-A | 5 | 25 | 40 | Grey silt, faint organic banding, few roots |
| WWF-01-A | 6 | 40 | 58 | Firm grey silt grading to fine sand at base |

Two things worth noticing. The slices get **thicker with depth** — 5 cm near the surface
where carbon changes fastest, coarser further down — which is a deliberate sampling choice,
not an inconsistency. And the bottom depth of the last slice (58 cm) equals the **inside
depth** on the Core Log, which is a useful check that no slice went unrecorded.

</details>

### Calculating depth interval and volume

From these we have the **Sample ID**, the **top and bottom depth** of each slice, the **depth
the corer was inserted**, and any **notes**. From that we can calculate the **depth interval**
of each sample and the **volume** of each sample.

**Depth interval (cm)** = bottom depth (cm) − top depth (cm)

**Volume (cm³)** = depth interval (cm) × area of the circular face of the corer, where
area = π r²

Using a corer with a 7.62 cm (3″) internal diameter:

```
area = π × (7.62 / 2)²  =  π × 3.81²  =  45.60 cm²
```

So for each sample we multiply the depth interval by 45.60 cm² to obtain its volume in cm³.
A standard 2 cm slice therefore has a volume of 2 × 45.60 = **91.2 cm³**, matching the worked
example in the field guide (p.17).

<details>
<summary><b>📊 Applied to one core</b> &nbsp;·&nbsp; <i>slices of different thicknesses</i></summary>

<br>

| Sample ID | Top (cm) | Bottom (cm) | Depth interval (cm)<br>*= bottom − top* | Volume (cm³)<br>*= 45.60 × interval* |
|---|---|---|---|---|
| 1 | 0 | 5 | 5 | 228.02 |
| 2 | 5 | 10 | 5 | 228.02 |
| 3 | 10 | 15 | 5 | 228.02 |
| 4 | 15 | 25 | 10 | 456.04 |
| 5 | 25 | 40 | 15 | 684.06 |
| 6 | 40 | 58 | 18 | 820.87 |

</details>

Both columns are calculated for you in the spreadsheet — you only ever type the top and
bottom depths.

> ⚠️ **Measure your actual internal diameter.** Nominal pipe size is not internal diameter —
> a "3-inch" Schedule 40 PVC pipe has an internal diameter noticeably larger than 7.62 cm, and
> wall thickness varies by schedule and supplier. Because volume enters the bulk-density
> denominator directly, an unchecked diameter propagates as a **systematic bias** into every
> bulk density, and therefore into every carbon stock, in the entire dataset. Measure the ID
> of the tubing you actually used with calipers and use that value.

### The digital data sheet

To make things easier, we have attached a spreadsheet where you can enter the field values
directly from the datasheet, and it will automatically populate the remaining columns.

**📊 [Open the digital data sheet in Google Sheets](https://docs.google.com/spreadsheets/d/1XMA_zaFNKtxCw2tAiQa3gHaIiT_wJAecmwW7Rz4hhaQ/edit?usp=sharing)**
· blank copy: [`files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx`](files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx)

The workbook has four tabs, following the same order as the workflow:

| Tab | What it holds | Do you type in it? |
|---|---|---|
| **1. Instructions** | Legend, colour key, units, and the field names the R pipeline expects | No |
| **2. Plot & Core Log** | One row per core — plot/core notes, corer diameter, insertion depths | Yes |
| **3. Sample Data** | One row per slice, in four bands: field · calculated · lab · calculated | Yes |
| **4. Core Summary** | Per-core totals, calculated automatically | No |

Only the **yellow cells** are for typing. Everything grey is a formula — the depth interval,
the volume, the compaction factor, and after the lab results arrive, the bulk density and
carbon stock. The compaction factor and corer diameter are looked up from the Core Log by
Core ID, so **the Core ID on the Sample Data tab must match the Core Log exactly**; if it
doesn't, those cells stay blank rather than silently using another core's geometry.

> 📸 **[SCREENSHOT NEEDED]** — the spreadsheet with the example rows filled in, showing which
> columns are typed by hand and which auto-calculate.

For every core sampling location, the calculation ultimately needs three things:
**sediment depth (cm)**, **dry bulk density (g/cm³)**, and **organic carbon (%)**.

- **Bulk density** can be measured with a scale and a drying oven.
- **Carbon analysis** requires more equipment, and at this stage samples are usually sent to a
  laboratory specializing in carbon analysis.

Samples should be frozen at −20 °C for storage, then thawed at 5–6 °C for 2–5 days, dried at
65 °C to a stable weight, and ground homogeneous before analysis. See the
[Lab Guide](Lab-Guide-Eng-2026.pdf) for the full procedure and packaging requirements.

> 🎥 **Watch:** [*"Core Sample Analysis"*](https://www.youtube.com/watch?v=BuLRrFD78Fs&list=PLLsjpJMfNDP5w78ZJNDUvMj1VoRG_qSwd&index=11) — workshop playlist
>
> 🎥 **Also:** [IORA Blue Carbon Hub — sample analysis](https://www.youtube.com/watch?v=_Zm9R-kGiE8&list=PL9pJDSsl2ZslDVZ5oZ5MFkykY2Kn9rDS8&index=6)

### Finding a lab

<details>
<summary><b>📋 Laboratories offering sediment carbon analysis</b> (click to expand)</summary>

<br>

<!-- TODO (Cathal): fill in as you confirm labs, quotes and turnaround. Keep the "quoted on" date so costs can be re-checked — prices go stale fast. -->

| Lab | Website | Contact | Analyses offered | Cost (per sample) | Quoted on |
|---|---|---|---|---|---|
| *(add lab)* | | | | | |
| *(add lab)* | | | | | |
| *(add lab)* | | | | | |
| *(add lab)* | | | | | |

**Notes when comparing quotes**
- Confirm whether the price is per sample or per batch, and whether it includes drying/grinding.
- Ask whether **inorganic carbon** is removed (acidification) or reported separately — this
  changes what "total carbon" means on your results sheet.
- Ask for the **method detection limit**; eelgrass sediments are often low-carbon and can sit
  near the limit of some methods.
- Ask whether **replicates and reference standards** are run, and whether you are charged for them.
- Confirm minimum sample mass and packaging, and whether they accept frozen or dried samples.

</details>

### What the lab needs — submitting samples

<!-- TODO (Cathal): confirm the specifics below against whichever lab you go with, and against the Lab Guide. -->

Before shipping, confirm the lab's own requirements — they vary. In general you will need to
provide:

- **The samples themselves**, labelled with the Core ID convention from
  [Section 3](../03_Field_Methods/) (site, plot, sampling location, depth interval).
- **A sample manifest** — one row per sample, matching the bag labels exactly. This is the
  same table you built in the spreadsheet above.
- **The analyses you want** — dry bulk density, organic carbon, and whether you also want
  inorganic carbon, total carbon, N, or isotopes.
- **Packaging and shipping arrangements** — frozen vs. dried, courier, and arrival timing so
  samples are not sitting at a loading dock over a weekend.

The manifest is simply the field columns plus the volume you calculated, which the lab needs
if they are also determining bulk density.

<details>
<summary><b>📊 The first rows of the Tsawwassen manifest</b></summary>

<br>

| Core ID | Sample ID | Top (cm) | Bottom (cm) | Volume (cm³) | Analyses requested |
|---|---|---|---|---|---|
| WWF-01-A | 1 | 0 | 5 | 228.02 | DBD, %C<sub>org</sub> |
| WWF-01-A | 2 | 5 | 10 | 228.02 | DBD, %C<sub>org</sub> |
| WWF-01-A | 3 | 10 | 15 | 228.02 | DBD, %C<sub>org</sub> |
| … | … | … | … | … | … |

The team asked for **elemental analysis** rather than loss-on-ignition, because these
sediments are sandy and low in organic matter — exactly the conditions where LOI is least
reliable.

</details>

> 📸 **[SCREENSHOT NEEDED]** — the example lab submission sheet from our *Practical
> Implementation Example*, filled in, so readers can see how the field datasheet transfers
> across.

The information you collected in the field transfers directly onto this submission sheet, so
the lab can perform the analysis and return results that map back onto your cores.

---

## 1.2 Expected lab results

*What comes back from the lab, and what does it mean?*

The lab returns two quantities per sample slice, which map onto the analysis inputs:

| Lab measurement | Analysis field | Notes |
|---|---|---|
| Organic carbon | `soc_g_kg` | Often measured by loss-on-ignition (LOI₅₅₀); for best accuracy the guide recommends total carbon on an elemental analyser (p.16) |
| Dry bulk density | `bulk_density_g_cm3` | Dry mass ÷ original sample volume (p.17) |

<details>
<summary><b>📊 What the lab returned for one core</b> &nbsp;·&nbsp; <i>and what the sheet does with it</i></summary>

<br>

The lab returns the wet and dry weights and the carbon concentration (the three yellow
columns); the spreadsheet calculates the rest:

| Sample | Volume (cm³) | Wet wt (g) | Dry wt (g) | %C | → Bulk density (g/cm³)<br>*= dry ÷ volume* | → Carbon density (g C/cm³)<br>*= BD × %C/100* | → Stock (g C/cm²)<br>*= C density × interval* |
|---|---|---|---|---|---|---|---|
| 1 | 228.02 | 299.28 | 95.77 | 6.20 | 0.420 | 0.0260 | 0.1302 |
| 2 | 228.02 | 304.03 | 109.45 | 5.40 | 0.480 | 0.0259 | 0.1296 |
| 3 | 228.02 | 298.60 | 125.41 | 4.30 | 0.550 | 0.0237 | 0.1182 |
| 4 | 456.04 | 598.54 | 287.30 | 3.20 | 0.630 | 0.0202 | 0.2016 |
| 5 | 684.06 | 912.07 | 492.52 | 2.30 | 0.720 | 0.0166 | 0.2484 |
| 6 | 820.87 | 1126.95 | 664.90 | 1.60 | 0.810 | 0.0130 | 0.2333 |
| | | | | | | **Core total** | **1.0613 g C/cm² = 10.61 kg C/m²** |

This is the field guide's equations 3–6 running down the table: carbon density per slice
(Eq 3), stock per slice (Eq 4), summed over the core (Eq 5), then ×10 into kg C/m² (Eq 6).

Notice the inverse pattern in the two lab columns — bulk density **rises** with depth as
carbon **falls**, which is the relationship described further down this page.

</details>

<details>
<summary><b>🔬 How the lab measures carbon</b> — LOI and elemental analysis (click to expand)</summary>

<br>

**Loss-on-ignition (LOI)**

LOI takes a dried and ground portion of each sample and burns it in a muffle furnace at
550 °C. Through this process the organic materials present in the sample (composed of what
used to be plant material) are ignited and converted into gaseous carbon dioxide and water,
which exit the furnace via a fume hood.

It is the same process that occurs when you make a campfire. The wood (organic material) burns
at its combustion temperature, converting the carbohydrates in the wood into CO₂ and H₂O.
What is left over in the morning is a pile of ashes — the non-organic material that does not
burn, or at least not at the same temperature.

By weighing the sample before and after, we know the mass of organic matter lost. Since we
know roughly how much of that organic matter is carbon, we can estimate organic carbon using a
**carbon conversion factor**.

> ⚠️ **The conversion factor is the weak link.** LOI measures *organic matter*, not carbon, so
> a factor is applied to convert one to the other. A commonly used value for seagrass sediments
> is ~0.43 (Fourqurean et al. 2012, for sediments with >0.2% OM), but the true ratio varies
> with organic-matter source and mineralogy. Clay-rich samples can also lose structural water
> at 550 °C, inflating apparent organic matter. If carbon numbers need to withstand scrutiny —
> for example for a credited project — validate LOI against elemental analysis on a subset of
> samples and report the relationship you used.

**Elemental analysis (CHN / CHNS)**

An elemental analyser measures carbon directly rather than inferring it from mass loss. A
small, precisely weighed aliquot of dried, ground sample (typically a few milligrams, sealed
in a tin capsule) is dropped into a combustion column at roughly 950–1150 °C in an
oxygen-enriched atmosphere. Everything combusts completely; the resulting gas stream is passed
through reduction and separation stages, and the CO₂, H₂O and N₂ produced are quantified —
usually by thermal conductivity detection — against standards of known composition.

Because each element is measured as its own gas, the instrument reports **total carbon**,
**hydrogen** and **nitrogen** as a percentage of sample dry mass in a single run. That gives
you more than just a carbon number:

- **Carbon (C)** — total carbon. If the sediment contains shell fragments or other carbonates,
  this includes inorganic carbon, so samples are usually **acidified** first (or inorganic
  carbon is measured separately and subtracted) to isolate organic carbon.
- **Nitrogen (N)** — lets you calculate the **C:N ratio**, which is a source indicator. Low
  C:N generally points to marine/algal or planktonic material; higher C:N points to vascular
  plant or terrestrial input. Paired with δ¹³C, this is how you distinguish carbon the meadow
  produced itself (autochthonous) from carbon it trapped from elsewhere (allochthonous) — a
  distinction that matters for crediting.
- **Hydrogen (H)** — largely a diagnostic of organic-matter type and combustion completeness;
  it is reported routinely but is used less often in blue carbon accounting.

The trade-off is cost and access: elemental analysis is more expensive per sample and requires
a specialized lab, whereas LOI is cheap and uses the same equipment already needed for bulk
density. A common compromise is to run **LOI on all samples and elemental analysis on a
representative subset**, then use the calibration to correct the LOI series.

</details>

For the most accurate results, samples should be sent to a laboratory for total carbon
measurement using an elemental analyser.

### What to expect from eelgrass sediments

Eelgrass sediments typically return **lower organic carbon** than salt-marsh or mangrove
soils, but the range is wide — spanning more than an order of magnitude between meadows, and
sometimes between cores in the same meadow. The values below are for gauging whether your
results are plausible, **not** for substituting for your own measurements.

**Organic carbon content, by ecosystem**

| Ecosystem | Typical %C<sub>org</sub> (dry mass) | Source |
|---|---|---|
| Salt marsh | mean 5.0%, median ~3.0% | EURO-CARBON database (Europe, all depths) |
| Seagrass / eelgrass | mean ~2.4%; temperate *Z. marina* average 1.4 ± 0.4% | EURO-CARBON; Röhr et al. 2018 |
| Bare / unvegetated marine sediment | mean 1.9%, median ~1.2% | EURO-CARBON database |

The ordering — **salt marsh > seagrass > bare sediment** — is consistent, but the
distributions overlap heavily. Across all habitats and depths the EURO-CARBON compilation
spans <0.1% to 41.6%, so a single value is close to meaningless without context.

**Spatial variation within eelgrass alone**

| Region | %C<sub>org</sub> | Stock context |
|---|---|---|
| Pacific coast of Canada (Clayoquot Sound, BC) | did not exceed 1.30% | stocks averaged 1,343 ± 482 g C m⁻² |
| Baltic Sea | 0.25 ± 0.21% | 635 ± 321 g C m⁻² |
| Kattegat–Skagerrak | 3.25 ± 2.78% | 3,457 ± 3,382 g C m⁻² |
| Four European regions (Portugal → Black Sea) | 2.79 ± 0.50% down to 0.17 ± 0.02% | Dahl et al. 2016 |
| Global temperate *Z. marina* (54 meadows) | 1.4 ± 0.4% | stocks 318–26,523 g C m⁻² (0–25 cm), mean 2,721 |

**The Canadian numbers are the relevant benchmark for this workshop:** BC eelgrass sediments
did not exceed 1.30% C<sub>org</sub>, with stocks well below global averages, attributed to
shallow rooting, patchy meadows, sandy sediment and shallow sedimentation. If your Atlantic
Canadian cores return values in the same broad range, that is expected — low numbers are a
real result, not a failed analysis.

**Variation with depth**

Do not assume carbon declines smoothly downcore. In a 141-core, 47-site global eelgrass
dataset, depth profiles fell into **three patterns** — organic carbon *increased*, *decreased*,
or showed *no distinct pattern* with depth. Profiles dominated by eelgrass-derived material
tended to be the high-carbon ones, while low-carbon profiles were dominated by planktonic and
macroalgal material.

Our worked example shows both behaviours: the marsh cores decline steadily with depth, while
eelgrass core `WWF-01-E` carries a **buried organic layer at 10–20 cm** where bulk density dips
and carbon rises again. A core like that is not an error to be smoothed away — it is a
depositional signal, and averaging it out of your profile discards real information.

The practical consequence: **extrapolating a whole-core stock from a shallow core is
unreliable**, which is exactly why the field guide insists on coring to the depth of refusal
([Section 3](../03_Field_Methods/)). Plot your own depth profiles before assuming any trend —
[`01_prepare_cores.R`](DataAnalysisWorkflow/01_prepare_cores.R) does this.

**Dry bulk density**

Bulk density is inversely related to organic carbon — organic-rich sediments are lighter and
more porous, mineral/sandy sediments are denser. Reported relationships between DBD and %C are
consistently negative (often exponential).

| Ecosystem | Typical DBD (g/cm³) | Source |
|---|---|---|
| Salt marsh, high marsh (BC) | 0.53 ± 0.14 | Boundary Bay, BC |
| Salt marsh, low marsh (BC) | 0.69 ± 0.16 | Boundary Bay, BC |
| Salt marsh (Mediterranean, by species) | 0.50–0.75 | Venice Lagoon |
| Sandy eelgrass meadow | *(add your measured values)* | — |

<!-- TODO (Cathal): the eelgrass DBD row still needs your real NFLD/BC measurements. I have deliberately NOT put the Tsawwassen worked-example numbers here — this is a literature comparison table and the example dataset is illustrative, not measured. -->

Because eelgrass meadows in Atlantic Canada are typically sandy, expect **higher** bulk
densities than the marsh values above. Note the compensating effect: low %C paired with high
bulk density can still yield a moderate carbon stock, since stock is their product. Judge the
stock, not either input alone.

> 📸 **[SCREENSHOT NEEDED]** — an example lab result sheet, with notes on how to read the
> columns and map them onto `soc_g_kg` and `bulk_density_g_cm3`.

### The worked example, end to end

<details>
<summary><b>📊 All six Tsawwassen cores through the spreadsheet</b></summary>

<br>

| Core | Stratum | Slices | In-situ depth (cm) | Mean DBD (g/cm³) | Mean %C | Stock (kg C/m²) |
|---|---|---|---|---|---|---|
| WWF-01-A | Salt marsh | 6 | 65 | 0.671 | 3.01 | 10.61 |
| WWF-01-C | Salt marsh | 6 | 72 | 0.652 | 3.24 | 11.98 |
| WWF-01-D | Salt marsh | 6 | 58 | 0.756 | 2.36 | 8.41 |
| WWF-01-B | Eelgrass | 5 | 30 | 1.266 | 0.65 | 2.16 |
| WWF-01-E | Eelgrass | 5 | 35 | 1.172 | 0.90 | 3.21 |
| WWF-01-F | Eelgrass | 4 | 26 | 1.357 | 0.42 | 1.33 |

Salt marsh averages **10.33 kg C/m²** and eelgrass **2.23 kg C/m²** — roughly a **4.6 : 1**
contrast, driven by the marsh's much higher carbon concentration more than offsetting its
lower bulk density. The eelgrass mean sits comfortably inside the published range for Pacific
Canadian eelgrass quoted above.

</details>

These are **whole-core** totals, and core depth differs by a factor of nearly three across
the six cores — so they are **not directly comparable to each other** until they are
standardised to a common depth, which is what
[`03_harmonize_depths.R`](DataAnalysisWorkflow/03_harmonize_depths.R) is for. The workflow's
headline number is a stock to **25 cm**, the depth every core reached.

> ⚠️ **Provenance.** The Tsawwassen dataset is a **teaching example**. The coordinates and
> layout are realistic and the values are constructed to sit within published ranges for BC
> salt marsh and eelgrass, but they are **not field measurements** and must not be cited as
> such. Cite the primary sources listed at the end of this page instead.

---

## 2. The analysis workflow

*How do I turn lab numbers into carbon stocks?*

A reproducible R workflow takes the lab results from a spreadsheet to a carbon stock with an
honest confidence interval — correcting for compaction, standardising cores to common depths,
estimating an area-weighted stock, and combining it with what was already known about meadows
like yours.

You do not need to be able to write R to use it. Everything site-specific lives in one
settings file, and the workflow is run with a single line:

```r
source("run_pipeline.R")
```

**👉 [`DataAnalysisWorkflow/`](DataAnalysisWorkflow/) — how to install it, what data it needs,
and what every dial does, in its [README](DataAnalysisWorkflow/README.md).**

The steps in brief:

| Stage | Script | Does | Method from |
|-------|--------|------|-------------|
| Prepare cores | [`01_prepare_cores.R`](DataAnalysisWorkflow/01_prepare_cores.R) | Load, QC, and correct percussion-core compression (uses the field measurements from [Section 3](../03_Field_Methods/)) | — |
| Prior | [`02_derive_prior.R`](DataAnalysisWorkflow/02_derive_prior.R) | Build a prior from cores at sites like yours | Janousek et al. (2025) |
| Depth harmonization | [`03_harmonize_depths.R`](DataAnalysisWorkflow/03_harmonize_depths.R) | Standardise cores to common depths; model the profile below core base | **`mpspline2`** |
| Estimation | [`04_estimate_stock.R`](DataAnalysisWorkflow/04_estimate_stock.R) | Area-weighted stratified stocks + confidence intervals | **`survey`** |
| Combination | [`05_combine_prior.R`](DataAnalysisWorkflow/05_combine_prior.R) | Combine prior and cores; PASS/FAIL against the precision target | — |
| Advanced spatial | [`06_advanced_spatial.R`](DataAnalysisWorkflow/06_advanced_spatial.R) | *Placeholder* — mapping where the carbon is. Not built yet | — |
| Viewer | [`view_prior.R`](DataAnalysisWorkflow/view_prior.R) | The prior cores and yours, on a map | **`leaflet`** |

Wherever a peer-reviewed implementation exists the workflow **uses it rather than
re-writing it**, so the methods can be cited instead of audited line by line.

> 🧮 **Why the estimator is stratified.** [Section 2](../02_Project_Planning/) designs a
> *stratified* sample, so the analysis uses the matching *stratified* estimator: each
> stratum's mean is weighted by its **area**, not by how many cores happened to land in
> it. Pooling strata that differ several-fold would produce a mean describing no real
> place, and would inflate the variance with the between-stratum contrast the design
> deliberately removed. Stratum areas come from your Step 1–2 boundary and are set in
> `00_config.R`.

> 📏 **Two stock numbers, not one.** Cores stop at different depths, so the workflow reports
> stock to a **primary depth every core physically reached** (25 cm by default — directly
> comparable to Röhr et al. 2018 and Fourqurean et al. 2012), *and* to the deepest depth
> every core can still support, with the modelled share stated per core. Below the base of
> a core the profile is extrapolated with an **asymptotic** model that fits a
> recalcitrant-carbon floor rather than decaying to zero, matching the eelgrass profile
> shape described by Kindeberg et al. (2019).

> 🌍 **It also uses what was already known.** Planning (Section 2) needed a rough idea of how
> much carbon is in a meadow like yours, and that estimate is still true after the fieldwork.
> The workflow builds it from real cores — a synthesis of Pacific-coast eelgrass cores,
> filtered to sites that resemble yours — and combines it with your own results, weighting
> each by how precise it is. It reports how much weight the prior earned, because "did the
> outside data actually matter?" is the first thing a reviewer asks.

The two columns the pipeline reads from the spreadsheet are `bulk_density_g_cm3` and
`soc_g_kg`, which are named exactly that way on the *Sample Data* tab so the sheet can be
exported and loaded without renaming anything.

A pre-rendered report — [`DataAnalysisWorkflow/eelgrass_carbon_report.html`](DataAnalysisWorkflow/eelgrass_carbon_report.html)
— walks through the whole analysis and can be opened in any browser without running R.

<details>
<summary><b>📊 What the workflow returned for Tsawwassen</b></summary>

<br>

| | Result |
|---|---|
| Carbon stock 0–25 cm (measured) | **31.4 ± 2.7 Mg C/ha** |
| Carbon stock 0–50 cm (partly modelled) | 51.5 ± 3.8 Mg C/ha |
| After combining with the regional prior | 30.4 ± 2.6 Mg C/ha *(prior earned 11% of the weight)* |
| Site total, 0–25 cm | **157 Mg C** over 5.0 ha |
| Precision achieved | ±18.6% at 90% confidence against a ±20% target — **target met** |
| Salt marsh vs eelgrass | 2.6 : 1 per m² to 25 cm |

*(± is the standard error; the achieved precision applies the t-multiplier at 4 degrees of
freedom.)*

Six cores against a plan that called for 23 cleared the ±20% target — but only just, at
±18.6%, on **4 degrees of freedom**. That margin is the honest headline here. Two things
made it possible: stratification, because most of the variation at this site is *between*
marsh and eelgrass rather than within either, so the design absorbed it before the estimator
saw it; and a ±20% target rather than a tighter one. At ±10% the same six cores would have
missed, which is what the earlier draft of this page reported.

**→ [Read the full analysis walkthrough](../Worked_Example/04_Data_Interpretation.md)**

</details>

> 📸 **[SCREENSHOT NEEDED]** — a rendered plot from the pipeline (e.g. the SOC depth
> profile from [`01_prepare_cores.R`](DataAnalysisWorkflow/01_prepare_cores.R)
> or the prior-to-posterior figure from [`05_combine_prior.R`](DataAnalysisWorkflow/05_combine_prior.R)), plus a screenshot
> of the rendered `eelgrass_carbon_report.html`.

### How the carbon-stock formula relates to the guide

The single line the pipeline uses is the field guide's equations 3–6 (pp. 17–18) combined:

```
Carbon stock (kg C/m²) = SOC (g/kg) × bulk density (g/cm³) × layer thickness (cm) ÷ 100
```

Per slice, the guide computes sediment carbon density = bulk density × (%C ⁄ 100),
multiplies by the depth interval to get g C/cm², sums the slices, and ×10 to reach
kg C/m². Because organic carbon in g/kg is ten times %C, that whole chain reduces to the
one formula above — then summing slices per core, averaging across cores, and scaling by
area gives the site total (guide equations 7–10).

> 🧮 **Compaction moves the carbon, it does not change how much there is.** The tube holds
> exactly the sediment that came out of the hole — decompaction only restores where each
> slice sat. So the correction has two halves, and they cancel: **depths stretch** by the
> compaction factor, and **bulk density thins** by the same factor, because that same dry
> mass now occupies a taller column.
>
> $$\text{carbon} = \text{SOC} \times \underbrace{(\text{BD} \div \text{CF})}_{\text{thinner}} \times \underbrace{(\text{thickness} \times \text{CF})}_{\text{taller}}$$
>
> Stretching the depths *without* thinning the density inflates every stock by exactly the
> compaction factor — 8–14% for these cores. `01_prepare_cores.R` asserts the total is
> unchanged and stops if it is not.
>
> A useful check: the deepest corrected depth should equal the outside (penetration) depth
> on the Core Log — for `WWF-01-A`, 58 cm recovered × 1.121 = 65 cm penetrated.

---

## 3. Reporting and using the results

*How do I communicate and act on the numbers?*

Once stocks are estimated, the final step is turning them into something a partner, funder or
regulator can act on.

**What to report**

- Carbon stock with an explicit **uncertainty estimate**, not a bare point value.
- The **depth interval** the stock refers to — stocks are not comparable without it. The
  worked example reports two: 0–25 cm, which every core measured, and 0–50 cm, which is
  partly modelled. Say which one a number is.
- **Sample sizes**: number of cores, number of slices, and how many strata they represent.
- **Methods**: LOI or elemental analysis, and any conversion factor applied.

### Interpreting the numbers

The pipeline gives you four numbers, and they answer different questions. Reading them in
order is the whole story of the campaign.

**1. The measured stock — what you actually found.**
For the worked example, **31.4 ± 2.7 Mg C/ha** to 25 cm, or **157 Mg C** across the 5 ha
inlet. This is the number to lead with, because every core measured to that depth. It is
directly comparable with the published seagrass literature, which mostly reports 0–25 cm.

**2. The deeper stock — what you found plus what you inferred.**
**51.5 ± 3.8 Mg C/ha** to 50 cm. Below the base of each core the profile is *modelled*, not
measured, and the per-core modelled share is reported alongside it — 0% for the salt-marsh
cores, which reached 58–72 cm, and 20–39% for the eelgrass cores, which stopped at 26–35 cm.
A number that is 39% modelled is still useful; a number that is 39% modelled and presented
as measured is not.

**3. The precision you achieved — whether it is good enough to act on.**
This is the number most reports omit and most reviewers ask for. The worked example achieved
**±18.6% at 90% confidence** against a **±20%** target, so the target was **met** — and that
sentence, not the point estimate, is what tells a reader the survey did its job.

It was met narrowly, on six cores against a plan of 23, and the margin is worth
understanding. Planning necessarily used a **regional** estimate of variability, which mixes
together differences within a meadow and differences between meadows, and so asks for more
cores than a well-stratified site actually needs — at Tsawwassen most of the variation is
**between** the marsh and the eelgrass, and the design separated those before the estimator
saw them. Pulling the other way, three cores per stratum leaves only **4 degrees of
freedom**, which is very few: the interval is honest but wide, and the marsh-versus-eelgrass
comparison has low power. A ±10% target would have been missed on this data.

> If you miss your target, that is not a failed survey. It is a survey that has told you what
> the next one needs to look like, and the workflow prints how many cores would close the
> gap. The failure mode is reporting a point estimate as though the target had been met.

**4. The combined estimate — what you know, given everything.**
**30.4 ± 2.6 Mg C/ha** after combining with the regional prior, which earned **11%** of the
weight. How much weight the prior earns is itself a finding, and it moves with your sample
size: six cores from this meadow cannot outweigh 82 cores from comparable meadows the way a
full campaign would, so the prior carries more here — 11% — than it would have at 23 cores.
That is the mechanism working as intended: the prior leans in hardest exactly when your own
data is thinnest, and steps back as you collect more. Most of the answer still comes from
the fieldwork, which is what a campaign of this size should produce.

**What the numbers cannot tell you.** None of this is a map. With six cores you have an
average for the meadow and a comparison between two strata — you do not have "where the
carbon is", and any figure implying otherwise is over-claiming. That question needs an
order of magnitude more cores.

### Communicating with partners

The hard part is not the statistics, it is that the honest version has an interval in it and
most audiences want a single number. Three things make that easier:

**Lead with the total, carry the interval.** "Roughly 155 tonnes of carbon in the top 25 cm
of this 5-hectare inlet, give or take about 8%" is honest and understandable. The tonnage
is what people can picture; the interval is what keeps you credible when someone re-surveys.

**Never quote a stock without its depth.** Most disagreements between two carbon numbers for
the same meadow turn out to be a depth-basis mismatch rather than a real difference — a
0–1 m figure is roughly three times a 0–25 cm one. This is common enough that the pipeline
refuses to combine a prior with an estimate on a different basis.

**Say what would change the answer.** Partners trust an estimate more when they know its
limits. For the worked example: the stratum areas drive the site total and came from a drawn
boundary rather than a survey, and the 0–50 cm figure is partly modelled in the eelgrass
stratum. Both are fixable, and naming them turns a caveat into a plan for the next season.

**Be careful with the word "sequestration".** What this workflow measures is a **stock** —
carbon that is in the sediment now. Sequestration is a *rate*, how fast carbon is being
added, and it needs dated cores (²¹⁰Pb or ¹⁴C) that this workflow does not use. Reporting a
stock as a sequestration rate is the most common error in blue-carbon communication, and it
is the one a technical reviewer will catch first.

> 📸 **[SCREENSHOT NEEDED]** — an example summary figure or one-page results summary from the
> Practical Implementation Example.

---

## References for the expected-values section

- Dahl, M. et al. (2016). Sediment properties as important predictors of carbon storage in *Zostera marina* meadows: a comparison of four European areas. *PLoS ONE*.
- EURO-CARBON: a marine and salt marsh sediment organic carbon database for European regional seas (2025). *Data in Brief*.
- Kindeberg, T. et al. (2019). Variation of carbon contents in eelgrass (*Zostera marina*) sediments implied from depth profiles. *Biology Letters* 15: 20180831. DOI: 10.1098/rsbl.2018.0831
- Postlethwaite, V.R. et al. (2018). Low blue carbon storage in eelgrass (*Zostera marina*) meadows on the Pacific Coast of Canada. *PLoS ONE*. DOI: 10.1371/journal.pone.0198348
- Röhr, M.E. et al. (2018). Blue carbon storage capacity of temperate eelgrass (*Zostera marina*) meadows. *Global Biogeochemical Cycles* 32: 1457–1475. DOI: 10.1029/2018GB005941
- Gailis, M. et al. / Boundary Bay salt marsh blue carbon studies (BC) — for marsh dry bulk density comparisons.
- Howard, J. et al. (2014). *Coastal Blue Carbon: Methods for assessing carbon stocks and emissions factors.*

<!-- TODO (Cathal): tidy these into your preferred citation style and confirm the Boundary Bay reference you want to use. -->

---

## In this section

- [`DataAnalysisWorkflow/`](DataAnalysisWorkflow/) — the R analysis workflow, with its own
  quick-start README.
- [`files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx`](files/Eelgrass_Carbon_DigitalData_BlankSheet.xlsx) — blank digital data sheet.
- [`Lab-Guide-Eng-2026.pdf`](Lab-Guide-Eng-2026.pdf) — WWF-Canada laboratory procedures guide.
- `images/` — lab result screenshots and analysis figures.

## Elsewhere

- **[Worked example — Part 4](../Worked_Example/04_Data_Interpretation.md)** — the full
  Tsawwassen analysis, one core followed from a bagged sample to a carbon stock.
- [Worked example — Part 2](../Worked_Example/02_Project_Planning.md) — how the same
  team planned the campaign.
- [Part 3 — Field Methods](../03_Field_Methods/) — where the cores and the compaction
  measurements come from.
