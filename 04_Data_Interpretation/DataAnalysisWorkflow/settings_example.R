# settings_example.R — the Cowichan Estuary worked example. Start_Here.R runs it first to check
# that everything works on your computer, and Part 4 shows its results. You do not need to edit
# this file: your own project's settings are in settings.R.

# ── 1. Your project (these words go straight into the report) ───────────────────
PROJECT <- list(
  title        = "Cowichan Estuary eelgrass — worked example",
  question_A   = "What do three eelgrass cores tell us about sediment organic carbon at Cowichan, and how do they compare with other eelgrass meadows?",
  question_B   = "What might the three cores imply for sediment organic carbon across an eelgrass area at Cowichan? (Teaching example: the boundary is hypothetical.)",
  area_habitat = "Cowichan Estuary, British Columbia — eelgrass (Zostera marina) sediment",
  survey_dates = "Not given in the compiled dataset (see Douglas et al. 2022)",
  design       = "Three stations chosen by the original study to be representative of the meadow (not randomly placed)",
  methods      = "Push cores (7.6 cm acrylic tubes), 1–2 cm slices; organic carbon by elemental analyser after acid fumigation on some slices, loss on ignition (550 °C) on the rest, converted with a local calibration",
  data_source  = "Douglas, Schuerholz & Juniper (2022), Frontiers in Marine Science 9:857586, as compiled in Janousek et al. (2025), doi:10.25573/serc.28127486",
  prepared_by  = "Blue Carbon Eelgrass Workshop"
)

# ── 2. Your data ───────────────────────────────────────────────────────────────
# The completed digital data sheet (.xlsx). No export needed — it is read directly.
WORKBOOK <- "workbooks/Eelgrass_Carbon_DigitalData_Example.xlsx"

# Where results are written: <OUTPUT_DIR>/checks, /option_A, /option_B, /module4.
OUTPUT_DIR <- "outputs/example"

# ── 3. Option A — comparing your cores ─────────────────────────────────────────
# Depth for the comparison (cm). NULL = the deepest standard depth (15, 30, 50, 100)
# that every one of your complete cores reached.
COMPARE_DEPTH_CM <- NULL

# Which published cores count as "comparable". Janousek et al. (2025) Zostera marina cores
# from these provinces/states. NULL = the whole Pacific coast dataset.
REFERENCE_STATES <- c("BC", "WA")

# Exclude your own estuary from the reference set, and any reference core within this
# distance of one of your cores. This stops a core being compared with itself.
REFERENCE_EXCLUDE_ESTUARIES <- c("COW")
REFERENCE_EXCLUDE_WITHIN_M  <- 100

# Both reference sets are always shown. Which one leads the report:
# "oc_or_loi":   elemental organic carbon, plus loss-on-ignition values converted with YOUR
#                workbook's LOI equation — the same conversion your own LOI slices get.
# "oc_measured": only elemental organic carbon from studies that removed inorganic carbon.
REFERENCE_HEADLINE <- "oc_or_loi"

# ── 4. Option B — estimating across an area ────────────────────────────────────
# "exploratory" = cores were not placed with a random design (no interval is reported)
# "srs"         = simple random (or random-start systematic) sampling of the whole area
# "stratified"  = random sampling within strata (needs STRATUM_AREAS_M2)
DESIGN <- "exploratory"

# The reporting boundary: a CSV of longitude, latitude vertices (decimal degrees).
# The worked example's boundary is HYPOTHETICAL — drawn for teaching, not a mapped meadow.
BOUNDARY_FILE <- "data/example_area/cowichan_HYPOTHETICAL_boundary.csv"
BOUNDARY_IS_HYPOTHETICAL <- TRUE

# For a stratified design: area of each stratum in m², named by the stratum codes in the
# Core Log, e.g. c(SG_dense = 32000, SG_sparse = 18000). Strata with no cores are reported
# as excluded, never filled in.
STRATUM_AREAS_M2 <- NULL

# Optional: stratum outlines for the map — a CSV with columns stratum, longitude, latitude
# (vertices in order, one block of rows per stratum). NULL = no stratum outlines drawn.
STRATA_FILE <- NULL

# What one sampling unit represents, and what counts as one.
PLOT_AREA_M2  <- 100      # 10 x 10 m plot: the area one sampling unit represents
SAMPLING_UNIT <- "plot"   # cores sharing a Plot ID are averaged before estimating

# Reporting depth for the headline (cm): 15, 30, 50 or 100. Every supported depth is also tabulated.
# NULL = the deepest standard depth (15, 30, 50, 100) that every core MEASURED — the headline.
REPORT_DEPTH_CM <- NULL
# A deeper depth shown as a clearly labelled scenario, partly estimated below the cores. It is only
# reported if every core is long enough (Janousek et al. 2025: 20 cm for 30, 35 for 50, 75 for 100).
SCENARIO_DEPTH_CM <- 30

# Were the sampling units drawn from a defined set of plots (e.g. the sampling tool's grid of
# possible core positions)? TRUE applies the finite-population correction; FALSE treats the area as
# continuous. With hundreds of possible plots per core the two give practically the same interval.
PLOTS_ARE_SAMPLING_FRAME <- FALSE

# Precision you set at the planning stage (Part 2). Used only for random designs.
CONF_LEVEL    <- 0.90
TARGET_MARGIN <- 0.20

# Below the base of a core, a decay curve is fitted when the core has at least this many slices
# (4 is the minimum: the curve has 3 parameters).
EXTRAP_MIN_SLICES <- 4

# ── 5. Going further (optional) — module 4: borrow from published cores ───────
# Depth for module 4 (cm). NULL = the deepest standard depth all your complete cores measured,
# so your side of the comparison is measured, not extrapolated.
MODULE4_DEPTH_CM <- NULL
# The prior needs at least this many reference estuaries to say how much estuaries differ.
MODULE4_MIN_ESTUARIES <- 3
