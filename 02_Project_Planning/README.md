<p align="center">
  <img src="images/banner_planning.svg" alt="Project Planning — Blue Carbon Eelgrass Workshop banner" width="100%">
</p>

---

[← 1 — Background](../01_Background/) · [Back to main guide](../README.md) · Next: [3 — Field Methods →](../03_Field_Methods/)

---

# Part 2 — Project Planning
## From a carbon question to a sampling design

**Quick links:** [Sampling Design Guide](Sampling-Design-Eng-2026.pdf) · [Sample Allocation Calculator](SampleDesign_SampleAllocationCalculator_WithStrata.xlsx) · [Coastal Blue Carbon Field Guide](../Coastal-Blue-Carbon-Field-Guide-FINAL.pdf) · [Howard et al. (2014) Blue Carbon Manual](https://www.thebluecarboninitiative.org/manual)

## Why planning matters

This section is the workshop's **making the data useful** component (see the
[main guide](../README.md)). Before you collect any sediment samples, it's worth making sure what you are collecting
will answer your team's questions. That's what a **Project Plan** aims to accomplish.

> The following methods are based on WWF-Canada's [Sampling Design guide](Sampling-Design-Eng-2026.pdf),
> as well as the sampling-design guidance provided in the
> [Howard et al. Blue Carbon Manual](https://www.thebluecarboninitiative.org/manual)
> (see [Section 1](../01_Background/)).

---

**Before collecting sediment cores** it's worth considering these four questions:

1. **What do I want to know?** - Are you collecting baseline data? Interested in comparing different management types?
2. **Where does that question apply?** What areas do I want to know about? Is it the whole ecosystem? Just the eelgrass? High-meadow vs low?
3. **How much data do I need?** How many samples is enough? Can I estimate this before planning to see if it fits my budget?
4. **Where should I collect samples?** Where exactly should I be collecting data from?

---

### The road from here to the field — and what you'll have at the end

<table>
<tr>
<td width="52%">

**The five steps**

```
     Your carbon question
              │
              ▼
  1.  Study area boundary
              │        where am I working?
              ▼
  2.  Stratification
              │        does it split into zones?
              ▼
  3.  Carbon pool
              │        what am I measuring?
              ▼
  4.  Sample size
              │        how many cores?
              ▼
  5.  Sample locations
              │        where do they go?
              ▼
     Field collection → Section 3
```

</td>
<td width="48%">

**What each step leaves you with**

```
  ✓  Study area boundary

  ✓  Ecosystem strata
     (if you need them)

  ✓  Carbon pool selected

  ✓  Required number of cores

  ✓  Sampling locations to
     collect sediment core data
```

</td>
</tr>
</table>

Each of the five steps below follows the same shape: **why it matters**, **a demonstration using our worked example**, **tools for you to try**, and **what you should have** before moving on.

---


## Introducing our worked example

> [!NOTE]
> **📊 See a demonstrated worked example here.** One small team in British Columbia, followed
> from planning through fieldwork to carbon estimates. It runs through **every part of this
> workshop**, so you can watch one project end to end.
>
> The full planning walkthrough lives in
> **[`Worked_Example/02_Project_Planning.md`](../Worked_Example/02_Project_Planning.md)**, and
> the complete project — data sheets, analysis and results — in
> [`Worked_Example/`](../Worked_Example/).
>
> Follow it to see the shape of a project. Don't copy its numbers: yours will differ.

<details>
<summary><b>📊 Meet the team at Tsawwassen Beach</b> &nbsp;·&nbsp; <i>their goal and their questions</i></summary>

<br>

Here we meet a small team working in B.C., aiming to gather baseline carbon data in the
**Tsawwassen Beach marshes**.

You and your team of 4 are tasked with **assessing the baseline measurements of an eelgrass ecosystem before protection and restoration** measures are implemented.

You want to know two things:

A) The **average carbon stock** across the meadow, and want to be able to

B) **Compare these measurements** between different areas of the eelgrass, as well as to future measurements
to assess how different management practices are affecting the ecosystem.

**How would you accomplish this?**
Let's break the scenario into digestible parts.

**First**, you want a rough idea of the different areas you're interested in. *This doesn't have to be precise, but it helps to have a general understanding of where those areas are and their boundaries. This helps constrain "where" the measurements will be made. By dividing up the ecosystem, you not only ensure all areas of interest are measured, but you also sample more effectively.*

**Second**, you want to collect samples from within these different areas, so you can "measure" the amount of carbon in these ecosystems.

But how do you know how many samples to collect and exactly where to take them? This can be answered with a **sampling design**.

</details>

---

## Background Information

### What is a sampling design?

A sampling design in this workshop is a framework for choosing what and where to sample to estimate the carbon stored in a larger ecosystem area.

<table>
<tr>
<td width="60%">

<img width="100%" alt="Site and plot selection — slide" src="https://github.com/user-attachments/assets/19e30448-624d-460d-98da-93acce8724c5">

</td>
<td width="40%">

Sampling designs allow for the strategic measurement of smaller sections (i.e., sites and plots) within the larger study area. Combining measurements from multiple plots allows us to estimate the value for the study area.

</td>
</tr>
</table>

---

### What sampling is and why it works

**Sampling** is based on probability-based estimation methods. It is used when directly measuring an entire population or area is impractical because of its size. Instead, a small sample is measured and used to estimate the value of the whole.

<table>
<tr>
<td width="60%">

<img width="100%" alt="What is sampling? — probability-based sampling explainer" src="https://github.com/user-attachments/assets/0c8db857-b05b-4969-936c-711d563e1978">

</td>
<td width="40%">

**What is sampling?**

= Taking a small portion (sample) of a thing to make an informed estimate of it

</td>
</tr>
</table>

The more samples you collect, the more precisely you can estimate the true value — the value you would obtain if you could measure the entire ecosystem. Because only a subset of the ecosystem is sampled, every estimate contains some uncertainty. A probability-based sampling result is therefore reported as three parts:

<details>
<summary><b>The 3 parts of a sample estimate</b></summary>

<br>

| Component | Symbol | What it tells you |
|---|---|---|
| **Estimate** | $\bar{x}$ | Your measured estimate of the carbon value, calculated as the average across all sampled plots. |
| **Confidence level** | $1-\alpha$ | Describes how often the sampling procedure would capture the true value if repeated many times. For example, a 95% confidence level means that about 95 out of every 100 confidence intervals produced by the same sampling method would contain the true value |
| **Margin of error** | $E$ | Describes the precision of the estimate. It is the distance from the estimate to the edge of the confidence interval and is often reported relative to the estimate (e.g., ±10%). Smaller margins of error indicate more precise estimates |

Put together, an example of a result would be: *"mean carbon = 100 ±10 (confidence level = 95%, so the confidence interval is 90–110)."*

</details>


### Visualizing Sampling on map

Below are clips taken from the **[Sample Size Visualization Tool](https://blue-carbon-hub.projects.earthengine.app/)**.

Here we can see how sampling an area can reveal the "True Map" underlying it

<table>
<tr>
<td width="60%">

<img width="100%" alt="Sample Allocation Visualizer — revealing the true carbon map as samples accumulate" src="images/download%20(2).gif">

</td>
<td width="40%">

Look at the bottom-left map aerial map, showing a hypothetical carbon map where each square represents the carbon value at that location. You can switch between the **"True value"** of carbon across the ecosystem and the **"Revealed"** view, which shows how with each sample, we are revealing this map, 1 sample at a time. With each sample collected, the estimate updates, and the true map underneath is revealed a little more. It would take thousands of samples to fully uncover it, but we only need a *reasonable* estimate, not a perfect one.

</td>
</tr>
</table>

<table>
<tr>
<td width="60%">

<img width="100%" alt="Sample Allocation Visualizer — estimate converging on the true value as sample size grows" src="images/download%20(3).gif">

</td>
<td width="40%">

On the right side, the top graph is showing "How many samples we need to collect". Below, we need our estimate relative to **true value**, the dashed blue line we're trying to reach. With only a few samples, our estimate is off and the error range (purple) is wide. As more samples are done, the map is revealed more, and the error on our graph shrinks. **That purple band is $E$, your margin of error**, watch it narrow as *n* grows.

</td>
</tr>
</table>


### The takeaway
**Sampling** is a tool for estimating things unfeasible to measure
In addition, the same methods that let us **estimate something too large to measure** also let us test
  whether changes *within* or *between* sites are statistically verifiable.
- By **rearranging the formula** (see dropdown menu below), we can work backwards to the
  number of samples needed to get there

<details>
<summary><b>Rearranging the sample estimate to solve sample size</b> &nbsp;·&nbsp; <i>showing the derivation</i></summary>

<br>

Start from what a margin of error *is* — the z-multiplier times the standard error of the mean:

$$E \cdot \bar{x} = z\,\frac{s}{\sqrt{n}}$$

Solve that for $n$, and write the variability as a **coefficient of variation**, $CV = s/\bar{x}$,
so the result is scale-free — it no longer depends on the units carbon is measured in:

$$n = \left(\frac{z \cdot CV}{E}\right)^{2}$$

This is the infinite-population form: it assumes your study area could hold unlimited plots.
Real sites cannot, so Cochran's correction accounts for a **finite** number of possible plot
locations $N$ (your study area ÷ your plot size):

$$n \geq \frac{z^2\, N\, CV^2}{(N-1)\,E^2 + z^2\, CV^2}$$

Read the two forms together and the behaviour of the whole method falls out: $E$ and $CV$ are
both **squared**, so precision and patchiness dominate the cost of a campaign — while $N$ only
matters when the area is small enough that plots are genuinely scarce.

</details>

---
# Implementing a Sampling Design

## The sampling roadmap in five steps

The guide breaks *applying* a sampling design into **five steps**.

| # | Step | Answers |
|---|------|---------|
| 1 | **Identify the boundary** of the study area | *Where, roughly, am I working?* |
| 2 | **Stratify** the study area (optional) | *Does the site split into distinct areas?* |
| 3 | **Choose what to measure** — the carbon pool | *Water, plant, or sediment carbon?* |
| 4 | **Determine how many samples** to take | *How many cores meet my intended goal?* |
| 5 | **Determine where to sample** — distribution | *Where exactly do I collect sample and data from?* |

Selecting a plot design (the physical layout of each core) follows from these; for eelgrass
sediment cores, see [Section 3 — Field Methods](../03_Field_Methods/).

---

## Step 1 — Define your study area

*Where, roughly, am I working?*

Why this matters: Every number you produce later is *per unit area*, so the boundary
is what turns a carbon density into a carbon total. It also sets $N$ — the number of possible
plot locations — which feeds the sample-size calculation in Step 4.
> [Note]
> For sample size planning estimates, the exact boundary does **not** need to be exact. A rough outline of where the meadow is beats a perfect
> outline of the wrong thing.

<details>
<summary><b>📊 See our worked example</b> &nbsp;·&nbsp; <i>how the Tsawwassen team defined their area</i></summary>

<br>

Using the Google Earth Engine sampling-design tool, they drew a rough outline of the area they
knew was mostly eelgrass — a **5 ha inlet (50,000 m²)**. They did not survey the edge; they
traced what they could see on recent imagery.

<img width="60%" alt="Drawing a study area boundary in Google Earth Engine" src="images/download%20(5).gif">

</details>

<table>
<tr>
<td width="45%">

<img width="100%" alt="Study area boundary — example" src="https://github.com/user-attachments/assets/68df05eb-c707-4cab-ab86-ec5117165b06">

</td>
<td width="55%">

The boundary can be a simple polygon drawn on a map, or a pre-defined area if one already
exists for your site.

If you run transects, or already know the general area you're interested in, a simple estimate
of the area is enough. A rough guess is genuinely informative here.

</td>
</tr>
</table>

### 🛠 Your turn

**Tool: [Blue Carbon Hub sampling-design app](https://blue-carbon-hub.projects.earthengine.app/)** — draw your area of interest directly on the map.

<table>
<tr>
<td width="45%">

<img width="100%" alt="Drawing a study area boundary in Google Earth Engine" src="images/download%20(4).gif">

</td>
<td width="55%">

Draw a simple polygon on a map — in the
[Blue Carbon Hub tool](https://blue-carbon-hub.projects.earthengine.app/), in Google Earth
Engine, or in whatever GIS you already use — or take a pre-defined area if one exists.

</td>
</tr>
</table>

> [!TIP]
> **✅ What you should have before you move on**
> - A boundary polygon (or a sketched area on a map)
> - Its **total area in m²** — you'll need this number in Step 4

---

## Step 2: Stratify your site (optional)

*Does the site split into distinct areas?* In other words, divide your site into distinct areas.

Why? Because we're collecting data at a single point and using it to extrapolate across
a larger area — the more similar that area is to where we sampled, the more accurate our
estimates will be. For example, you wouldn't want to use a sediment sample from an
eelgrass meadow to estimate carbon in an upland marsh; distinguishing between the two
ecosystems gives more accurate results.

Stratification can be done manually, or using remote sensing techniques *(links to be added)*.

<table>
<tr>
<td width="45%">

<img width="100%" alt="Stratification example — slide" src="https://github.com/user-attachments/assets/0aec62d8-db94-4ca2-8962-96d74799d016">

</td>
<td width="55%">

Stratification divides ecosystems into distinct areas, such that the data we collect in
one area is only applied within that ecosystem. In addition to distinguishing
ecosystems, stratification can also be used to compare different management
techniques, restoration years, etc.

</td>
</tr>
</table>

### 🛠 Your turn

**Tool: [Blue Carbon Hub sampling-design app](https://blue-carbon-hub.projects.earthengine.app/)** — use the auto-stratification function, or draw your strata by hand.

<table>
<tr>
<td width="45%">

<img width="100%" alt="Blue Carbon Stratified Sampling Tool — drawing and stratifying a study area" src="images/Screenshot%202026-07-21%20at%2010.46.13.png">

</td>
<td width="55%">

**In practice:** the [Blue Carbon Hub sampling-design tool](https://blue-carbon-hub.projects.earthengine.app/)
draws the area of interest (Step 1), then applies automatic stratification (Step 2) to
split it into distinct strata before calculating the sample size (Step 4).

</td>
</tr>
</table>

> [!TIP]
> **✅ What you should have before you move on**
>
> Either:
> - **One** large area containing a single ecosystem type, **or**
> - **Multiple** boundaries containing unique ecosystems, different management areas, or any
>   other areas you wish to distinguish for comparison
>
> Plus the **area in m² of each** — Step 4 uses these to divide the cores between them.

---

## Step 3: What to measure

*Water, plant, or sediment carbon?*

<table>
<tr>
<td width="45%">

<img width="100%" alt="Carbon pools — slide" src="https://github.com/user-attachments/assets/a7ea0100-6160-4498-a282-5d44db722a59">

</td>
<td width="55%">

Select the **carbon pool** you wish to measure. This can be from the water, the plant,
or the sediment. For an eelgrass carbon project, this is the **sediment**.

</td>
</tr>
</table>

> [!TIP]
> **✅ What you should have before you move on**
> - The **carbon pool** you're measuring, written down — for this workshop, sediment
> - A target **core depth**, or a decision to core to refusal (see [Section 3](../03_Field_Methods/))

---

## Step 4 — Decide how many samples

*How many cores meet my precision goal?*

> [!NOTE]
> **🎓 Why this matters.** This is the step that decides your budget and your field schedule —
> and the one most likely to be challenged by a reviewer. Too few cores and your estimate
> carries an interval too wide to act on; too many and you spend a season collecting data you
> didn't need.
>
> You set two things — **how precise** you need to be, and **how confident** — then describe how
> variable you expect the meadow to be. The calculator returns the number of cores. You never
> work the formula by hand, but it pays to know which inputs actually move the answer.

<details>
<summary><b>📊 What the Tsawwassen team did</b></summary>

<br>

They calculated the required number of cores from:

- Total area = **50,000 m²** (the 5 ha inlet from Step 1) → at **100 m² per plot**, $N$ = **500** possible plots
- Confidence level = **90%** → $z = 1.645$
- Margin of error = **±10%** ($E = 0.10$)
- Prior mean and variation = **≈ 120 Mg C ha⁻¹, SD ≈ 60** (regional WWF-Canada carbon map) → $CV = 0.5$

That returns **≈ 60 cores**. Padding for ~70% usable-sample recovery — attrition, lost cores,
damaged samples — they planned to collect **≈ 86**.

</details>

### What moves the answer

### What drives sample size?

Four inputs dominate, and two of them sit **squared** in the formula, so small changes have
outsized effects.

First, one modelling choice that everything else depends on: **each core is taken to represent a
plot, not a pinprick.** We use a **10 × 10 m plot (100 m²)** per core. That converts your study
area into the number of possible plot locations, $N$ — a 5 ha inlet holds 500 of them. Change the
plot size and every number below shifts.

The table is anchored on the worked example: a **5 ha inlet** ($N$ = 500 plots), ±10% margin of
error, 90% confidence, CV 0.5 → **≈ 60 cores**. One knob at a time:

```
                                              cores needed (from 60)
  Precision      ±10% → ±5%      ████████████████████████  176
  Variability    CV 0.5 → 1.0    ████████████████████████  176
  Confidence     90% → 95%       ███████████               81
  Study area     5 ha → 50 ha    █████████                 67
```

| Knob | Turn it… | Effect on cores (*n*) | Why |
|---|---|---|---|
| **Margin of error, $E$** | tighter: ±10% → ±5% | **~3× more** (60 → ~176) | $E$ is squared |
| **Variability, $CV = s/\bar{x}$** | patchier: 0.5 → 1.0 | **~3× more** (60 → ~176) | also squared |
| **Confidence, $1-\alpha$** | stricter: 90% → 95% | **~35% more** (60 → ~81) | more certainty costs cores, far less steeply |
| **Study area** | bigger: 5 ha → 50 ha | **~10% more** (60 → ~67) | rises, then plateaus — see below |

Three things here routinely surprise people:

- **CV is the hidden driver.** It's squared, exactly like $E$ — so a meadow twice as variable
  needs roughly **three times** the cores. This is why a good variability prior matters more than
  almost any other input, and why you pad it when you're unsure.
- **Precision is expensive, confidence is cheap.** Tightening your margin of error from ±10% to
  ±5% nearly triples the fieldwork. Raising confidence from 90% to 95% costs about a third more.
  If the budget is fixed, loosening $E$ buys back far more cores than dropping confidence.
- **Area matters at first, then stops.** Going 1 ha → 5 ha → 50 ha → 500 ha gives roughly
  **41 → 60 → 67 → 68** cores. Sample size climbs while the area is small relative to the plot
  size, then flattens out. **Doubling a large meadow does not double your cores** — you're
  estimating a *mean*, and pinning down a mean depends on variability, not on the size of the
  field.

> **Why "~3×" and not "4×"?** In a large area the squared terms give a clean fourfold: halving
> $E$ takes *n* from 68 to 271. In a 5 ha inlet there are only 500 possible plots, so the
> **finite-population correction** — the $(N-1)$ term — pulls the requirement back to about 3×.
> The smaller your study area, the more it dampens these effects.

<details>
<summary>📐 <b>Show the math — the sample-size formula and its symbols</b></summary>

<br>

For a continuous variable like carbon stock:

$$n \geq \frac{z^2\, N\, CV^2}{(N-1)\,E^2 + z^2\, CV^2}, \qquad CV=\frac{s}{\bar{x}}$$

For a **proportion** parameter instead (e.g. % of cores containing a peat horizon, % meadow still vegetated), swap in the proportion form — use $p = 0.5$ when you have no prior, since it gives the largest, most conservative $n$:

$$n \geq \frac{z^2\, N\, p\,q}{(N-1)\,E^2 p^2 + z^2\, p\, q}, \qquad q = 1-p$$

**Inputs you supply:**

| Input | What it is | Where it comes from |
|---|---|---|
| $N$ | Max possible plots = total study area ÷ plot footprint | Your Step 1 boundary |
| $1-\alpha$ | Confidence level → sets $z$ (1.645 → 90%, 1.96 → 95%) | You choose (usually 90% or 95%) |
| $E$ | Acceptable margin of error | You choose (e.g. ±10%) |
| $\bar{x}$ | Expected mean carbon | Prior study, regional map, or pilot data |
| $s$ | Expected standard deviation | Prior study, regional map, or pilot data |

**Symbol crosswalk to the UNFCCC A6.4 tool** (if you're cross-referencing the [UNFCCC A6.4 Sampling & Surveys tool](Sampling-Design-Eng-2026.pdf) or its calculator):

| This guide | UNFCCC tool | Meaning |
|---|---|---|
| $z$ | $Z_{\alpha/2}$ | z-multiplier set by confidence level |
| $E$ | $e_{abs}$ | target **relative** precision (0.10 = ±10% of the mean) |
| $s$ | $SD$ | expected standard deviation (your prior) |
| $\bar{x}$ | mean | expected mean (your prior) |
| $CV$ | $CV$ | coefficient of variation, $s/\bar{x}$ |
| $N$ | $N$ | population size (see note below) |
| $n$ | $n$ | number of plots/cores to collect |

> **Note on $N$ — this is where the two calculators differ.** The core formula is identical in the WWF-Canada area-based calculator and the UNFCCC A6.4 tool. They only differ in how $N$ is obtained: the WWF tool derives it from **total area ÷ plot size**, while the UNFCCC tool takes a **population count** ($N$) directly. Because $(N-1)$ barely moves the result once $N$ is large, both converge on the same answer — which is exactly why area "doesn't matter" above.

</details>

### See it for yourself

The quickest way to build intuition is to open the calculator (or the
[Blue Carbon Hub visualizer](https://blue-carbon-hub.projects.earthengine.app/)) and change **one
knob at a time**, watching *n* respond:

<table>
<tr>
<td width="45%">

> 📸 **[SCREENSHOT/GIF NEEDED]** — margin-of-error comparison: the calculator at **±20% vs ±10%**, side by side, with the *n* readout circled (~17 vs ~68) to show the ~4× jump.

</td>
<td width="55%">

> 📸 **[SCREENSHOT/GIF NEEDED]** — variability comparison: a **smooth vs patchy meadow** at the same target precision, showing *n* roughly quadruple as CV goes 0.5 → 1.0.

</td>
</tr>
</table>

### The calculator

The formula above is provided as a spreadsheet calculator.

<table>
<tr>
<td width="45%">

<img width="100%" alt="Sample allocation calculator — basic inputs" src="https://github.com/user-attachments/assets/080e16d2-3be6-4da8-a0d1-bb4154c82e96">

</td>
<td width="55%">

Provide an area size, allowable error, and precision, and the spreadsheet estimates the number of samples to collect.

</td>
</tr>
</table>

<table>
<tr>
<td width="45%">

<img width="100%" alt="Sample allocation calculator — with study area boundary and regional estimates" src="https://github.com/user-attachments/assets/1cf7295f-9143-4637-84dc-b6daab789f85">

</td>
<td width="55%">

A model is only as useful as the information you give it. Here we use the same formula but provide more: a study area boundary (a more precise measure of area) and a regional estimate for the mean and standard deviation of carbon stock.

</td>
</tr>
</table>


**📄 [`SampleDesign_SampleAllocationCalculator_WithStrata.xlsx`](SampleDesign_SampleAllocationCalculator_WithStrata.xlsx)**

This is the **"Sample Design Sample Allocation Calculator"** named directly in the
Sampling Design guide's Step 3:

> "This framework uses the central limit theorem to estimate the minimum number of
> plots needed to meet a desired level of accuracy and precision for estimating the
> carbon stock of a large area."

> "For example, if the study area is 10,000 km² and the allowable error is 10%, 43 plots will need to be set up."

For more information, please see WWF-Canada, *[Carbon Measurement: Sampling Design](Sampling-Design-Eng-2026.pdf)* (2026), p.16.

The spreadsheet has three sheets:

#### Sheet 1 — Sample Allocation Calculator
Estimates the total number of plots/cores (*n*) for the whole study area.

| Input | Meaning |
|-------|---------|
| Size of total study area (m²) | The area you want to characterise |
| Margin of error | Acceptable relative error (e.g. `0.2` = ±20%) |
| Confidence level (alpha) | Precision level (e.g. `0.1` → 90% confidence) |
| Carbon mean & standard deviation | Your **prior** — see below |

**Output:** number of plots *n* needed to hit the target precision.

> 🎯 **Where the mean and SD come from — this is an educated guess, and that's fine.**
> The calculator needs to know roughly how much carbon is there and how variable it is
> *before* you've measured anything. That's a chicken-and-egg problem, and the answer is a
> **prior**: a rough estimate from existing information, used only to size the campaign.
> The sheet offers two sources, in order of preference:
>
> | Source | Use when | How good is it? |
> |---|---|---|
> | **Your own data** — measured mean and SD from a pilot, a previous survey, or nearby cores | You have local measurements | Best. Local variability is what actually drives *n*. |
> | **Regional defaults** — the provided WWF-Canada carbon-map values | You have nothing local | Workable starting point. Regional averages usually *understate* local patchiness, so pad the SD. |
>
> You are not committing to these numbers — nothing in your final result depends on them.
> They only decide how many cores to plan for. After the campaign you check the precision
> you *actually* achieved (see below), which is what gets reported.
>
> ⚠️ **A note on the word "Tier."** The sheet labels these prior sources "Tier 1" and
> "Tier 2." That numbering refers **only to where your prior came from** and is unrelated
> to the IPCC Tier 1/2/3 methodological tiers used in national greenhouse gas inventory
> reporting. If you work with IPCC guidance, read these labels as "prior source," not as a
> statement about method quality.

#### Sheet 2 — Sample Allocation per Strata
Splits the total *n* across **strata** (sub-areas — e.g. dense vs. sparse meadow,
depth zones) in proportion to each stratum's area, with a **minimum of 5 plots per
stratum**. Enter each stratum's size and the sheet returns the proportion and the
number of plots to allocate — the same proportional-allocation principle the guide
describes for stratified-random sampling (see Step 5):

> "Allocate (Step 3 'Sample allocation') plots proportionally based on the size of each
> study site (e.g., a 50ha area will have twice as many plots as a 25ha area)."
>
> — WWF-Canada, *[Carbon Measurement: Sampling Design](Sampling-Design-Eng-2026.pdf)* (2026), p.17

<!-- TODO (Cathal): the intro above says the workbook has THREE sheets, but only Sheet 1 and Sheet 2 are documented. Add a "Sheet 3" description here, or change "three sheets" to "two sheets". -->


### After the campaign: did you actually hit your precision target?

Sample-size planning uses *expected* variability. Once real cores come back, the observed spread can differ — so before trusting the estimate, check the **achieved** precision against your target. The calculator's post-survey check cells do this for you: they compute a **relative margin of error (RME)** from your actual cores and compare it to the target $E$ you planned for. If RME is at or below your target, the estimate meets its reliability criterion and you're done.

<details>
<summary>📐 <b>Show the math — achieved precision (RME)</b></summary>

<br>

For a mean parameter:

$$\text{RME} = \frac{z \cdot SE}{\bar{x}}, \qquad SE = \sqrt{\left(1-\tfrac{n}{N}\right)\frac{s^2}{n}}$$

where $s$ and $\bar{x}$ are now the *sample* standard deviation and mean, and $\text{RME}$ (relative margin of error) is compared to your target $E$.

</details>

**If you miss it:** work down the ladder — scrutinize the raw data for outliers or skew, then post-stratify, then add cores; only as a last resort, report the conservative confidence bound (the interval end that *understates* carbon) so the estimate is defensible.

<!-- TODO (Cathal): a small screenshot/GIF of the calculator's "check precision after survey" cells (SRS-Mean rows for SE, t-value, relative precision) would slot in well here. -->

> [!WARNING]
> **⚠️ A common mistake.** *"I collected 10 cores, so I have a carbon estimate."*
>
> You have an estimate — but not necessarily a **defensible** one. A carbon number without a
> margin of error can't be compared to another site, to a future survey, or to a target. The
> sample size is what buys you the interval, and the interval is what makes the number usable.

> [!TIP]
> **✅ Before moving on, you should have:**
> - A **target margin of error** and **confidence level** you can justify
> - A **prior** for mean carbon and its variability, and a note of where it came from
> - A **required number of cores** from the calculator
> - That number **padded for recovery losses** — the count you'll actually plan to collect

---

## Step 5: Where to sample? — Sample distribution

*Where exactly do the cores go?*

<table>
<tr>
<td width="45%">

<img width="100%" alt="Sampling strategies — slide" src="https://github.com/user-attachments/assets/a2d13fda-6c63-417d-aad6-b506be50a59d">

</td>
<td width="55%">

There are different strategies for distributing samples, aptly referred to as "sampling strategies."

These include convenient, linear, grid, and stratified sampling.

</td>
</tr>
</table>

<table>
<tr>
<td width="45%">

<img width="100%" alt="Eelgrass-specific sampling considerations — slide" src="https://github.com/user-attachments/assets/d5d1f4f8-7040-434c-8a72-41f3a88cec09">

</td>
<td width="55%">

For eelgrass, some considerations include how the eelgrass might vary relative to the shore, both parallel and perpendicular.

</td>
</tr>
</table>

Rather than scattering cores at random, the meadow is divided into **strata** and
samples are allocated across them (Sheet 2 above). Stratifying by features that drive
carbon variability — meadow density, water depth, sediment type — gives a more precise
estimate for the same number of cores and ensures no part of the site is missed.

**How the total $n$ is split across strata.** Once Step 4 gives you a total sample size $n$, each stratum receives a share proportional to its area — a stratum covering half the meadow gets roughly half the cores. Two practical adjustments (both built into the calculator's Stratified tabs): round each share **up** to a whole core, and enforce a **minimum of 5 cores per stratum** so even small strata yield a usable estimate. These two rules mean the strata totals usually sum to slightly more than $n$ — that headroom is a feature, not an error.

<details>
<summary>📐 <b>Show the math — proportional allocation</b></summary>

<br>

$$n_h = \frac{g_h}{N}\times n$$

where $g_h$ is the size of stratum $h$ and $N$ is the total study area.

</details>

The guide names four sampling strategies for deciding *where* plots go; which one fits
depends on how much you already know about the site:

| Strategy | When to use it |
|---|---|
| **Random** | Plots placed randomly across the study area — the default when the area is uniform or there's no prior data. |
| **Systematic** | Plots at regular intervals — guarantees even coverage, but only when variation across the site is already known. |
| **Stratified-random** | Study area divided into strata first, then plots randomly assigned within each — most accurate and cost-effective when variability is known. **This is the strategy used here.** |
| **Convenience/practical** | Plots placed wherever is accessible — not statistically rigorous, but useful for a low-cost initial assessment. |

For more information, please see WWF-Canada, *[Measuring Carbon in Coastal Sediments](../Coastal-Blue-Carbon-Field-Guide-FINAL.pdf)* (2026), p.6.

For eelgrass specifically, the field guide recommends a shoreline-aligned transect layout:

> Seagrass meadows should be sampled along transects that run parallel to the shoreline and align with the depth of the sediment. Within each site, a random or probability-based grid sampling strategy is recommended, with at least two replicates per site.


> 🎥 **CHECK OUT THE VIDEO** — *"Site Selection and Required Materials"* · [workshop playlist](https://www.youtube.com/playlist?list=PLLsjpJMfNDP5w78ZJNDUvMj1VoRG_qSwd) *(swap in the direct video link)*

---

## Companion tools — WWF-Canada Blue Carbon Sampling Design Tools

The area-based calculator here is part of a broader set of sampling-design tools
developed previously for blue carbon work:

- **Interactive tool:** [Blue Carbon Hub sampling-design app](https://blue-carbon-hub.projects.earthengine.app/)
- **Source code:** [WWF-Canada-SKI/Carbon-Measurement — Sampling Design Tools](https://github.com/WWF-Canada-SKI/Carbon-Measurement/tree/main/Blue%20Carbon/Sampling%20Design%20Tools)

<table>
<tr>
<td width="50%">

<img width="100%" alt="Blue Carbon Hub sampling-design tool — drawing and stratifying a study area" src="images/Screenshot%202026-07-21%20at%2010.46.13.png">

</td>
<td width="50%">

<img width="100%" alt="Blue Carbon Hub sampling-design tool — stratified sample allocation results" src="images/Screenshot%202026-07-21%20at%2010.47.16.png">

</td>
</tr>
<tr>
<td width="50%">

The sample size visualizer shows how you can reveal the "true carbon" using sampling.
How many samples are required to reach a goal can vary based on the adjustable
parameters listed.

</td>
<td width="50%">

This sampling tool helps implement this in a practical way, allowing the user to adjust
these parameters over a user-defined study area. The user can choose if/how they want
to divide up (stratify) their study area, and allocate their samples.

</td>
</tr>
</table>

---
## Worked example — planning the Tsawwassen campaign

> [!NOTE]
> **📊 See a demonstrated worked example here.** Back to the team we met at the top of this
> section — here they work through all five steps for their own site, arriving at a number of
> cores and a set of coordinates.
>
> **→ [Read the full planning walkthrough](../Worked_Example/02_Project_Planning.md)**
>
> The fieldwork that follows is in [Section 3](../03_Field_Methods/); the analysis of what they
> collected is in [Section 4](../04_Data_Interpretation/).

<details>
<summary><b>📊 Their answers at a glance</b></summary>

<br>

| Step | Their decision |
|---|---|
| 1 — Study area | A **5 ha inlet** (50,000 m²), traced roughly from imagery |
| 2 — Stratify | **Two strata** — denser meadow, sparser fringe |
| 3 — Carbon pool | **Sediment**, cored to refusal |
| 4 — Sample size | **≈ 60 cores** needed; **≈ 86** planned to collect after padding |
| 5 — Locations | Allocated proportionally by stratum area, minimum 5 per stratum |

**→ [See how they got there](../Worked_Example/02_Project_Planning.md)**

</details>

---

## ✅ Sampling design complete

Before heading into the field, check you can answer all six:

```
  ☑  Study area boundary defined            → Step 1
  ☑  Strata identified (or ruled out)       → Step 2
  ☑  Carbon pool selected                   → Step 3
  ☑  Sample size calculated and padded      → Step 4
  ☑  Sampling locations generated           → Step 5
  ☑  Data sheets printed and ready          → Section 3
```

If any line is still open, it is cheaper to close it now than after a field season.

**Next: [Section 3 — Field Methods →](../03_Field_Methods/)** — collecting the cores your plan
just specified.

---

## In this section

- [`SampleDesign_SampleAllocationCalculator_WithStrata.xlsx`](SampleDesign_SampleAllocationCalculator_WithStrata.xlsx) — the Cochran's-formula calculator.
- [`Sampling-Design-Eng-2026.pdf`](Sampling-Design-Eng-2026.pdf) — the WWF-Canada sampling-design guide.
- `images/` — screenshots of the calculator and planning materials.

<details>
<summary><b>📋 Slide/screenshot layout template — copy/paste this to add an image</b></summary>

Each image is a two-column block: the image on the left and a description on the right.
To add one, copy the block below and:

1. In GitHub's editor, click inside the left cell (between the blank lines) and **paste
   or drag your image** — or paste the image URL into `src="…"`.
2. Type your description in the right cell (plain text, **markdown**, links, and lists
   all work).

Keep the blank lines inside the cells — they're what let GitHub render the pasted
image and formatted text.

```html
<table>
<tr>
<td width="45%">

<img width="100%" alt="Image description" src="PASTE_IMAGE_URL_HERE">

</td>
<td width="55%">

Paste your description here.

</td>
</tr>
</table>
```

</details>
