# Style options — separating implementation, background, and worked example

**This is a scratch file for choosing a house style. Delete it once we've picked one.**

The problem: a reader should be able to tell at a glance whether a block is something they
**must do**, something that **explains why**, or **an example someone else already did**.

GitHub markdown gives us no CSS, so the levers available are: **boxes** (single-cell tables),
**dropdowns** (`<details>`), **coloured alert blocks**, **blockquote bars**, **rules**, and
**type size** (`###### h6` renders small and grey; `<sub>` smaller still).

Each option below is shown with the *same* real content so you can compare like for like.

---
---

# OPTION A — Dropdown (collapsed by default)

Background is folded away. The implementation spine stays unbroken; readers open the theory
only if they want it.

## Step 4: How many samples?

This step answers how many cores you need. You set the margin of error and confidence level,
and the calculator returns *n*.

<details>
<summary><b>Background — why the formula works</b> &nbsp;·&nbsp; <i>optional, skip to keep moving</i></summary>

<br>

Start from what a margin of error *is* — the z-multiplier times the standard error of the mean:

$$E \cdot \bar{x} = z\,\frac{s}{\sqrt{n}}$$

Solve for $n$, writing variability as a coefficient of variation, $CV = s/\bar{x}$:

$$n = \left(\frac{z \cdot CV}{E}\right)^{2}$$

Both $E$ and $CV$ are squared, which is why precision and patchiness dominate the cost.

</details>

Two rules of thumb are worth remembering: halving your margin of error roughly triples *n*,
and a poor CV prior is the biggest planning risk.

---
---

# OPTION B — Boxed (single-cell table)

Background sits inside a visible bordered box. Always visible, clearly walled off.

## Step 4: How many samples?

This step answers how many cores you need. You set the margin of error and confidence level,
and the calculator returns *n*.

<table>
<tr>
<td>

###### BACKGROUND · WHY THIS WORKS · NOT REQUIRED TO RUN A CAMPAIGN

Start from what a margin of error *is* — the z-multiplier times the standard error of the mean:

$$E \cdot \bar{x} = z\,\frac{s}{\sqrt{n}}$$

Solve for $n$, writing variability as a coefficient of variation, $CV = s/\bar{x}$:

$$n = \left(\frac{z \cdot CV}{E}\right)^{2}$$

Both $E$ and $CV$ are squared, which is why precision and patchiness dominate the cost.

</td>
</tr>
</table>

Two rules of thumb are worth remembering: halving your margin of error roughly triples *n*,
and a poor CV prior is the biggest planning risk.

---
---

# OPTION C — Coloured alert block

Uses GitHub's native alert colours. `[!NOTE]` renders **blue**, `[!TIP]` **green**,
`[!IMPORTANT]` **purple**. The only real colour available.

## Step 4: How many samples?

This step answers how many cores you need. You set the margin of error and confidence level,
and the calculator returns *n*.

> [!NOTE]
> **Background — why the formula works.** Not required to run a campaign.
>
> A margin of error is the z-multiplier times the standard error of the mean, so
> $E \cdot \bar{x} = z\,s/\sqrt{n}$. Solving for $n$ and writing variability as
> $CV = s/\bar{x}$ gives $n = (z \cdot CV / E)^{2}$.
>
> Both $E$ and $CV$ are squared, which is why precision and patchiness dominate the cost.

Two rules of thumb are worth remembering: halving your margin of error roughly triples *n*,
and a poor CV prior is the biggest planning risk.

*Caveat: long content with images and wide tables gets cramped inside an alert — it is designed
for short asides, not multi-screen sections.*

---
---

# OPTION D — Label band, no box

No container at all. A small-type label opens and closes the passage, with rules top and
bottom. Lightest touch; keeps full width for images and tables.

## Step 4: How many samples?

This step answers how many cores you need. You set the margin of error and confidence level,
and the calculator returns *n*.

---
###### BACKGROUND — WHY THIS WORKS · *skippable*

Start from what a margin of error *is* — the z-multiplier times the standard error of the mean:

$$E \cdot \bar{x} = z\,\frac{s}{\sqrt{n}}$$

Solve for $n$, writing variability as a coefficient of variation, $CV = s/\bar{x}$:

$$n = \left(\frac{z \cdot CV}{E}\right)^{2}$$

Both $E$ and $CV$ are squared, which is why precision and patchiness dominate the cost.

###### END BACKGROUND
---

Two rules of thumb are worth remembering: halving your margin of error roughly triples *n*,
and a poor CV prior is the biggest planning risk.

---
---

# OPTION E — Box + dropdown combined

Short framing always visible in a box; the heavy maths folded inside it. Best of A and B.

## Step 4: How many samples?

This step answers how many cores you need. You set the margin of error and confidence level,
and the calculator returns *n*.

<table>
<tr>
<td>

###### BACKGROUND · WHY THIS WORKS

The sample-size formula is just a rearrangement of the margin of error: decide how precise you
need to be, describe how variable the meadow is, and solve for the number of cores.

<details>
<summary><i>Show the derivation</i></summary>

<br>

$$E \cdot \bar{x} = z\,\frac{s}{\sqrt{n}} \qquad\Longrightarrow\qquad n = \left(\frac{z \cdot CV}{E}\right)^{2}$$

Both $E$ and $CV$ are squared, which is why precision and patchiness dominate the cost.

</details>

</td>
</tr>
</table>

Two rules of thumb are worth remembering: halving your margin of error roughly triples *n*,
and a poor CV prior is the biggest planning risk.

---
---

# Worked-example treatments

The worked example needs to look different again — clearly *someone else's project*, not your
instructions and not theory.

## W1 — Green alert opener

> [!TIP]
> **Worked example — Tsawwassen Beach, BC.** One team, followed from planning to results.
> Full version in [`Worked_Example/`](Worked_Example/). Follow the shape, not the numbers.

**Step 4 — How many samples.** With a 5 ha inlet, ±10% at 90% confidence and CV 0.5, the
calculator returns **≈ 60 cores**, padded to ~86 for recovery losses.

## W2 — Boxed with a running label

<table>
<tr>
<td>

###### 🔬 WORKED EXAMPLE · TSAWWASSEN BEACH, BC · *one team's answers*

**Step 4 — How many samples.** With a 5 ha inlet, ±10% at 90% confidence and CV 0.5, the
calculator returns **≈ 60 cores**, padded to ~86 for recovery losses.

</td>
</tr>
</table>

## W3 — Indented blockquote bar, no colour

> ###### WORKED EXAMPLE · TSAWWASSEN BEACH, BC
>
> **Step 4 — How many samples.** With a 5 ha inlet, ±10% at 90% confidence and CV 0.5, the
> calculator returns **≈ 60 cores**, padded to ~86 for recovery losses.

---
---

# My recommendation

**Background → Option E (box + dropdown).** The box walls it off visually, the small-type label
says *skippable* without an emoji, and the derivation folds away so the page stays short. It also
handles images and wide tables better than an alert.

**Worked example → W2 (boxed, running label).** Same box shape as background, but a distinct
label line — so the two read as siblings rather than unrelated devices. Consistency of shape,
difference of label.

**Implementation → nothing at all.** No wrapper, no marker. Anything unboxed is what you do.
That makes the spine the default reading path and keeps the page from filling with badges.

One caution on boxes: a single-cell table wrapping content that itself contains the two-column
image tables can nest awkwardly. Where a background passage is mostly images, Option D's label
band is the safer choice.
