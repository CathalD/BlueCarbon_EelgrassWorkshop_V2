# Worked example — Part 2: Planning the Tsawwassen campaign

*How one team turned a carbon question into a field-ready sampling plan.*

[← Worked example overview](README.md) · [Back to Part 2 — Project Planning](../02_Project_Planning/)

---

## The team and their question

A small team of four working in British Columbia, assessing **baseline carbon in the
Tsawwassen Beach eelgrass meadows** before protection and restoration measures are implemented.

They want to know two things:

**A)** The **average carbon stock** across the meadow, and

**B)** How those measurements **compare** between different areas of the eelgrass, and against
future surveys, so they can tell whether management is changing the ecosystem.

Both are **Option B** questions — an estimate for a defined area, compared between its strata
— so they set the decisions Part 2 asks for before fieldwork:

| Decision | The team's choice |
|---|---|
| What is estimated | Mean sediment organic-carbon stock (Mg C ha⁻¹) and total (Mg C), per stratum and overall |
| Study boundary | The 5 ha inlet traced in Step 1 |
| Strata | Dense meadow and sparse fringe (Step 2) |
| Reporting depth | **0–30 cm** — the depth of their prior, so every core must reach at least 30 cm |
| Sampling design | Stratified random (Step 5) |
| Precision target | ±20% at 90% confidence (Step 4) |
| Analysis | Part 4, Option B. For later surveys: keep plot IDs, coordinates and methods the same |

Which reduces to two planning questions:

1. How many samples to take
2. Where to take them

> ⚠️ **This is constructed teaching data.** The site and layout are realistic, but the team and
> their numbers are **not field measurements**. See the [worked example overview](README.md).

---

## Step 1 — Study area

Using the Google Earth Engine sampling-design tool, they drew a rough outline of the area they
knew was mostly eelgrass — a **5 ha inlet (50,000 m²)**. They did not survey the edge; they
traced what they could see on recent imagery.

<img width="60%" alt="Drawing a study area boundary in Google Earth Engine" src="../02_Project_Planning/images/download%20(5).gif">

**Result:** a boundary polygon, total area **50,000 m²**.

---

## Step 2 — Stratify

They knew there were slight differences across the site, so they used the **auto-stratification**
tool to delineate distinct areas.

<img width="60%" alt="Auto-stratifying the study area into distinct strata" src="../02_Project_Planning/images/download%20(7).gif">

**Result:** two strata — a denser meadow and a sparser fringe — each with its own area.

---

## Step 3 — What to measure

They only wanted to measure **sediment** carbon in this area.

**Result:** carbon pool = sediment organic carbon, reported to **30 cm**. Every core must reach at
least 30 cm; they core to the depth of refusal where they can.

---

## Step 4 — How many samples

They calculated the required number of cores from:

| Input | Value | Where it came from |
|---|---|---|
| Total area | **50,000 m²** (5 ha) | Step 1 boundary |
| Plot area | **100 m²** (10 × 10 m) | design choice → $N$ = 500 possible plots |
| Confidence level | **90%** → $z = 1.645$ | the tool's default |
| Margin of error | **±20%** ($E = 0.20$) | the tool's default |
| Prior mean | **≈ 20.6 Mg C ha⁻¹** to 30 cm | BC eelgrass cores, Janousek et al. (2025) — the calculator's *3 Priors* sheet |
| Prior SD | **≈ 11.9** | same source |
| → $CV$ | **0.58** | $11.9 / 20.6$ |

The spreadsheet calculator, which treats the inlet as one uniform area, returns **22 cores**.
The [GEE sampling tool](../02_Project_Planning/Sampling%20Design%20Tools/), given the same
precision target plus the site-specific priors and the two strata from Step 2, returns
**23 cores**. The team planned on **23** — the stratification-aware number, and the more
conservative of the two.

Padding for ~70% usable-sample recovery — attrition, lost cores, damaged samples — they planned
to collect **≈ 33**.

**Result:** 23 cores of usable data required; ~33 planned for collection.

---

## Step 5 — Where to sample

They allocated those 23 cores **proportionally across the two strata** — a meadow twice the
area of the fringe gets roughly twice the cores — keeping a **minimum of 5 per stratum**.

<img width="60%" alt="Allocating samples across strata over the study area" src="../02_Project_Planning/images/download%20(6).gif">

**Result:** a set of coordinates, sent to the field team to go and collect.

---

## Summary of what to expect

*Given a 5 ha inlet and a target of ±20% at 90% confidence, plan for roughly **23 cores of
usable data** (about **33 collected** after padding), split proportionally between the dense and
sparse strata.*

*If the meadow turns out patchier than the CV prior assumed, expect to either add cores or
report a slightly wider interval — which is exactly why oversampling at the design stage is
worth it.*

---

## What happened next

| Stage | Where |
|---|---|
| Collecting the cores this plan specifies | [Part 3 — Field Methods](../03_Field_Methods/) |
| Lab results and carbon estimates | [Part 4 — Data Interpretation](../04_Data_Interpretation/) |
| How a filled-in data sheet and analysis look | The Cowichan worked example in [Part 4](../04_Data_Interpretation/) (published cores) |

> **Note on scale.** The plan above sizes a full campaign at **23 cores**. A first season often
> brings back fewer — which is the ordinary shape of a first field campaign, not a failure. Part 4's
> Option B reports the precision actually achieved against the ±20% target, rather than presenting
> an under-powered result as a finished one. The constructed Tsawwassen analysis that used to follow
> this plan is kept in [`archive/`](archive/) for reference.
