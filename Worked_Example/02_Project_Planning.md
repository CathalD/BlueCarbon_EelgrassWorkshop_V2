# Worked example — Part 2: Planning the Tsawwassen campaign

*How one team turned a carbon question into a field-ready sampling plan.*

[← Worked example overview](README.md) · [Back to Part 2 — Project Planning](../02_Project_Planning/)

---

## The team and their question

A small team of four working in British Columbia, assessing **baseline carbon in the
Tsawwassen Beach marshes** before protection and restoration measures are implemented.

They want to know two things:

**A)** The **average carbon stock** across the meadow, and

**B)** How those measurements **compare** between different areas of the eelgrass, and against
future surveys, so they can tell whether management is changing the ecosystem.

Which reduces to two planning questions:

1. How many samples to take
2. Where to take them

> ⚠️ **This is constructed teaching data.** The site and layout are realistic and the values sit
> within published ranges for BC salt marsh and eelgrass, but they are **not field
> measurements**. See the provenance note in [Part 4](../04_Data_Interpretation/).

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

**Result:** carbon pool = sediment; core to depth of refusal.

---

## Step 4 — How many samples

They calculated the required number of cores from:

| Input | Value | Where it came from |
|---|---|---|
| Total area | **50,000 m²** (5 ha) | Step 1 boundary |
| Plot area | **100 m²** (10 × 10 m) | design choice → $N$ = 500 possible plots |
| Confidence level | **90%** → $z = 1.645$ | chosen by the team |
| Margin of error | **±10%** ($E = 0.10$) | chosen by the team |
| Prior mean | **≈ 120 Mg C ha⁻¹** | regional WWF-Canada carbon map |
| Prior SD | **≈ 60** | regional WWF-Canada carbon map |
| → $CV$ | **0.5** | $60 / 120$ |

Running these through the calculator gives **≈ 60 cores**.

Padding for ~70% usable-sample recovery — attrition, lost cores, damaged samples — they planned
to collect **≈ 86**.

**Result:** 60 cores of usable data required; 86 planned for collection.

---

## Step 5 — Where to sample

They allocated those ~86 cores **proportionally across the two strata** — a meadow twice the
area of the fringe gets roughly twice the cores — keeping a **minimum of 5 per stratum**.

<img width="60%" alt="Allocating samples across strata over the study area" src="../02_Project_Planning/images/download%20(6).gif">

**Result:** a set of coordinates, sent to the field team to go and collect.

---

## Summary of what to expect

*Given a 5 ha inlet and a target of ±10% at 90% confidence, plan for roughly **60 cores of
usable data** (about **86 collected** after padding), split proportionally between the dense and
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
| The completed data sheet | [`Eelgrass_Carbon_DigitalData_Example.xlsx`](Eelgrass_Carbon_DigitalData_Example.xlsx) |

> **Note on scale.** The plan above sizes a full campaign at ~86 cores. The analysis carried
> through Part 4 uses **6 cores** — a reduced set, sized to keep the worked example legible
> while demonstrating every step of the workflow. Treat the Part 4 numbers as a demonstration
> of method, not as a completed campaign.
