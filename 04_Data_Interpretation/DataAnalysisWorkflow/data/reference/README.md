# Reference cores — published *Zostera marina* data

These files are the published eelgrass cores that Option A compares your cores with. The optional
module 4 also uses them to build a prior.

## Source and licence

Janousek, C.N., Krause, J.R., Drexler, J.Z., Buffington, K.J., Poppe, K.L., Peck, E.K., et al.
(2025). *Dataset: Carbon stocks and environmental driver data for blue carbon ecosystems along the
Pacific coast of North America.* Smithsonian Environmental Research Center.
[doi:10.25573/serc.28127486](https://doi.org/10.25573/serc.28127486) (version 1).
Released under **CC BY 4.0** — reuse is permitted with attribution. Cite the dataset above, and the
original study for any core you single out (see `janousek2025_zostera_sources.csv`).

The CSVs were taken from the Coastal Carbon Network data library mirror
(github.com/Smithsonian/CCN-Data-Library, `data/primary_studies/Janousek_et_al_2025/original/`,
commit 5972abd, 2026-02-24). They were reduced by
[`../../data-raw/prepare_reference_data.R`](../../data-raw/prepare_reference_data.R).

## What was changed

Nothing in the values. The script:

1. keeps cores whose vegetation class is *Zostera marina* (`VegGrp == "ZosMar"`) — 240 cores;
2. keeps the columns the workshop uses;
3. splits each depth-interval label ("10-12") into numbers and flags intervals the synthesis marks as
   approximate.

The synthesis marks every slice's bulk density, organic matter and carbon as measured (`M`),
interpolated (`I`), extrapolated (`E`) or modelled (`O`). The workshop uses **measured slices
only**. Rows the synthesis added below the base of short cores are marked `E` and are never used.

## Files

| File | Contents |
|---|---|
| `janousek2025_zostera_cores.csv` | One row per core: study, state/province, estuary, coordinates, core depth, published 0–30 cm stock |
| `janousek2025_zostera_depthseries.csv` | One row per slice: depths, bulk density, % organic matter (LOI), % carbon, and whether each was measured |
| `janousek2025_zostera_sources.csv` | One row per source study: citation, design, coring and carbon methods |
| `study_carbon_basis.csv` | **Workshop file, not part of the dataset.** For each study: whether its elemental carbon is documented as organic, i.e. whether inorganic carbon was removed (`yes` / `unverified` / `loi_only`), with the reason, from the source table |

## Things to know before using the published 0–30 cm stocks (`Stk30`)

The workshop recalculates every reference stock from measured slices. It does not use `Stk30`,
because for cores shorter than 30 cm that value includes the synthesis's own extrapolation. For
loss-on-ignition studies it also rests on the synthesis's conversion from organic matter to carbon,
which may differ from yours.
Of the 79 BC eelgrass cores with a published `Stk30`, 34 are shorter than 30 cm.
