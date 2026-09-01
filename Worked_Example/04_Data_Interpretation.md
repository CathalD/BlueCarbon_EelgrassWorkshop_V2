# Worked example — Part 4: Analysing the Tsawwassen cores

*How one team went from twelve bags of wet sediment to a defensible carbon number.*

[← Worked example overview](README.md) · [Back to Part 4 — Data Interpretation](../04_Data_Interpretation/)

---

The team from [Part 2](02_Project_Planning.md) collected their cores. This is what
happened to them next — one core followed all the way through, then the whole campaign.

> ⚠️ **This is constructed teaching data.** The site and layout are realistic and the values
> sit within published ranges for BC salt marsh and eelgrass, but they are **not field
> measurements** and must not be cited as such.

---

## What came back from the field

Twelve cores — six in **salt marsh** (`WWF-01-A/C/D/G/H/I`) and six in **eelgrass**
(`WWF-01-B/E/F/J/K/L`) — arrived as 64 labelled bags, plus two field sheets: the *Plot &
Core Log* and the *Sample Data* tab.

Take core **`WWF-01-A`**. The corer was driven **65 cm** into the sediment but only **58 cm**
of core came out, so the team recorded both numbers. That pair is the whole compaction
record, and without it the core cannot be placed back on real depths.

The core was extruded and cut into six slices, thicker with depth because the interesting
change is near the surface:

| Slice | Depth in the tube (cm) | Description |
|---|---|---|
| 1 | 0–5 | Dense live root mat, dark brown silty clay |
| 2 | 5–10 | Root mat thinning, dark brown silty clay |
| 3 | 10–15 | Fine roots, dark grey-brown silt |
| 4 | 15–25 | Occasional root fragments, grey silty clay |
| 5 | 25–40 | Grey silt, faint organic banding, few roots |
| 6 | 40–58 | Firm grey silt grading to fine sand at base |

## Sending it to the lab

Each slice was weighed wet, dried at 60 °C to constant mass, weighed again, and sent for
**dry bulk density** and **organic carbon**. The team asked for elemental analysis rather
than loss-on-ignition, because eelgrass sediments here are sandy and low in organic matter,
where LOI is least reliable.

What came back, for core `WWF-01-A`:

| Slice | Depth (cm) | Bulk density (g/cm³) | Organic carbon (g/kg) |
|---|---|---|---|
| 1 | 0–5 | 0.42 | 62 |
| 2 | 5–10 | 0.48 | 54 |
| 3 | 10–15 | 0.55 | 43 |
| 4 | 15–25 | 0.63 | 32 |
| 5 | 25–40 | 0.72 | 23 |
| 6 | 40–58 | 0.81 | 16 |

Carbon falls and density rises with depth, which is the expected pattern: the surface is
young, root-rich and light; the base is compacted mineral sediment.

## Putting the core back on real depths

58 cm of core came out of a 65 cm hole, so the sediment was compressed by a factor of
**65 ÷ 58 = 1.121**. Every slice sat deeper in the ground than it did in the tube.

Correcting for that stretches the depths — slice 6 moves from 40–58 cm to **44.8–65.0 cm**
— and thins the bulk density by the same factor, from 0.81 to **0.723 g/cm³**. The two
cancel exactly, which they must: the tube holds precisely the sediment that came out of the
hole. Core `WWF-01-A` contains **10.61 kg C/m²** before the correction and 10.61 kg C/m²
after. What changes is *where* that carbon is, not how much.

> This is the step most often got wrong. Stretching depths without thinning density inflates
> every stock by the compaction factor — 8–14% across these twelve cores. The workflow
> asserts the total is unchanged and stops if it is not.

## Making twelve different cores comparable

The cores are not the same length: the marsh cores reach 49–72 cm in the ground, the
eelgrass cores only 26–35 cm. They were also sliced at different thicknesses. Before
anything can be averaged they have to be put on the same depth intervals — done with a
mass-preserving spline, which redistributes carbon onto standard bins without inventing or
losing any.

Below the base of each core there is nothing to measure, so the profile is **modelled**:
carbon declining toward a non-zero floor, because eelgrass sediments retain recalcitrant
carbon at depth rather than decaying to nothing.

That leaves two honest numbers instead of one:

- **0–25 cm** — every one of the twelve cores physically reached this depth. Fully measured.
- **0–50 cm** — the deepest interval *every* core can support. For the marsh cores this is
  still entirely measured; for the eelgrass cores, 20–39% of it is modelled.

Anything deeper would mean averaging a 100 cm marsh core against a 50 cm eelgrass core and
calling the result one number.

## The estimate

Each stratum's mean is weighted by its **area** — 1.8 ha of marsh, 3.2 ha of eelgrass — not
by how many cores landed in it. Both strata got six cores, but the eelgrass covers nearly
twice the ground, so it carries nearly twice the weight.

| | Salt marsh | Eelgrass |
|---|---|---|
| Cores | 6 | 6 |
| Area | 1.8 ha (36%) | 3.2 ha (64%) |
| Mean stock 0–25 cm | 5.13 kg C/m² | 1.94 kg C/m² |

**Area-weighted result: 3.09 kg C/m², or 30.9 ± 1.4 Mg C/ha, to 25 cm.**
Across the 5 ha inlet, **154 Mg C** — roughly 566 tonnes of CO₂-equivalent.

To 50 cm, **51.0 ± 2.1 Mg C/ha**, or **255 Mg C** for the inlet.

The marsh holds **2.6 times** the carbon of the eelgrass per square metre (difference
3.19 kg C/m², p < 0.001). The marsh sediment is far richer in carbon even though it is less
dense — concentration wins over density.

## Did the campaign work?

The plan called for **±20% at 90% confidence**. The twelve cores delivered **±8.2%**.

**The target was met.** That is the number the team reports, and it is the number a
reviewer will check first.

Worth seeing why twelve cores were enough when the plan asked for many more. The comparison
below is drawn at **±10%** — a tighter target than this campaign's ±20% — because the
contrast between the three bases is easier to read when the numbers are larger:

<!-- TODO (Cathal): these three figures are pipeline output computed at E = 0.10. If you
     want them restated at the campaign's own ±20% target, re-run the workflow and paste
     the new values in. The ordering (and the teaching point) is unchanged either way. -->

| Basis for the variability | Implied cores at ±10% |
|---|---|
| Planning CV 0.68 — regional eelgrass, all sources of spread | 101 |
| Observed, ignoring strata | 57 |
| Observed, within strata — what stratifying actually buys | 5 |

Planning used the conservative figure, which is the right way to be wrong: an under-powered
survey costs another field season. But **stratifying the meadow cut the effective
variability roughly fourfold**, because most of the variation at this site is *between*
marsh and eelgrass, not within either. The design absorbed it before the statistics had to.

## What the prior added

The regional prior — 82 *Zostera marina* cores from 11 comparable estuaries — says
**21.7 ± 7.9 Mg C/ha**. Combined with the fieldwork it gives **30.6 ± 1.4 Mg C/ha**, and it
earned **3%** of the weight.

That the prior barely moves the answer is the finding, not a disappointment. Twelve cores
from this meadow outweigh 82 cores from meadows like it, because the prior describes
*meadows of this kind* while the cores describe *this one*. Had the team collected three
cores instead of twelve, the prior would have carried far more, and it would have been doing
real work.

> The synthesis contains three eelgrass cores from Tsawwassen itself. They were **excluded**
> from the prior — otherwise those cores would count once as prior and again as evidence,
> and the result would look more certain than it is.

## What happened next

The team reported **154 Mg C in the top 25 cm of a 5 ha inlet, ±8%**, alongside the
2.6 : 1 marsh-to-eelgrass contrast — which is the number that actually matters for
management, because it says which habitat is worth protecting per hectare.

Three things they flagged in the report:

1. The **stratum areas** drive the site total, and came from a drawn boundary rather than a
   survey. Tightening them tightens the total.
2. The 0–50 cm figure is **partly modelled** in the eelgrass stratum. Longer cores there
   would replace inference with measurement.
3. This is a **stock**, not a sequestration rate. Saying how fast carbon is accumulating
   needs dated cores, which this campaign did not collect.

---

**→ Run it yourself:** the analysis lives in
[`04_Data_Interpretation/DataAnalysisWorkflow/`](../04_Data_Interpretation/DataAnalysisWorkflow/).
`source("run_pipeline.R")` reproduces every number on this page.
