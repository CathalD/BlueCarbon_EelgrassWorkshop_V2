# 01_prepare_cores.R
# Load the field and lab data, QC it, and correct for corer compaction.
# Produces `cores` — one row per sediment slice, ready to harmonize.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM SCRATCH (base R + dplyr) — the merge, the QC flags and the compaction
#     arithmetic. The compaction maths is identical to what the digital data
#     sheet computes on its "Sample Data" tab, so the two agree cell for cell.
#   FROM A PACKAGE (BlueCarbon) — an optional cross-check only, guarded by
#     USE_BLUECARBON below. The pipeline never depends on it.
#
# ── COMPACTION: WHAT IT DOES AND DOES NOT CHANGE ─────────────────────────────
#   A percussion corer compresses sediment as it is driven in. You recover a
#   50 cm core from a 56 cm hole, so every slice sits shallower in the tube
#   than it did in the ground.
#
#     compaction_factor = outside_depth / inside_depth        (>= 1)
#         outside_depth = how far the corer was driven in
#         inside_depth  = length of core actually recovered
#
#   Decompaction restores the ORIGINAL DEPTHS. It must not change how much
#   carbon is in the core — the tube holds exactly the material that came out
#   of the hole, no more and no less. So the correction has two halves and
#   they cancel:
#
#     depths     x compaction_factor    (the column was taller in the ground)
#     bulk density / compaction_factor  (that mass, spread over more volume)
#
#     carbon = SOC x BD x thickness
#            = SOC x (BD / CF) x (thickness x CF)      <- CF cancels
#
#   Stretching the depths WITHOUT thinning the bulk density inflates every
#   stock by exactly the compaction factor — 8-14% for these cores. The
#   assertion below enforces the invariant so that can never silently return.

library(dplyr)
library(readr)

source("00_config.R")

USE_BLUECARBON <- FALSE   # TRUE also runs the optional BlueCarbon cross-check

# Null-coalescing operator. Defined defensively: `%||%` only entered base R in
# 4.4.0 and this pipeline targets R >= 4.1.
if (!exists("%||%")) `%||%` <- function(a, b) if (is.null(a)) b else a

# ── 1. Load ──────────────────────────────────────────────────────────────────
locations <- read_csv(LOCATIONS_FILE,  show_col_types = FALSE)
samples   <- read_csv(SAMPLES_FILE,    show_col_types = FALSE)
comp_meas <- read_csv(COMPACTION_FILE, show_col_types = FALSE)

cat("Loaded:", nrow(locations), "cores,", nrow(samples), "sediment slices\n")

cores <- samples |>
  left_join(locations, by = "core_id") |>
  mutate(layer_thickness_cm = depth_bottom_cm - depth_top_cm)

# Fill missing bulk density from the stratum defaults, and record where.
cores <- cores |>
  mutate(
    bd_estimated = is.na(bulk_density_g_cm3),
    bulk_density_g_cm3 = if_else(
      bd_estimated,
      sapply(stratum, function(s) BD_DEFAULTS[[s]] %||% NA_real_),
      bulk_density_g_cm3)
  )
if (sum(cores$bd_estimated) > 0)
  cat("Bulk density filled from defaults for", sum(cores$bd_estimated), "slices\n")

# ── 2. QC ────────────────────────────────────────────────────────────────────
cores <- cores |>
  mutate(
    qc_soc_flag = soc_g_kg < QC_SOC_MIN | soc_g_kg > QC_SOC_MAX,
    qc_bd_flag  = bulk_density_g_cm3 < QC_BD_MIN | bulk_density_g_cm3 > QC_BD_MAX)

n_flagged <- sum(cores$qc_soc_flag | cores$qc_bd_flag, na.rm = TRUE)
cat("QC:", n_flagged, "slices outside thresholds",
    if (n_flagged > 0) "(flagged, not removed)" else "", "\n")

# Carbon stock on the MEASURED interval — the quantity decompaction must preserve.
cores <- cores |>
  mutate(carbon_stock_kg_m2 =
           (soc_g_kg * bulk_density_g_cm3 * layer_thickness_cm) / 100)

stock_before <- cores |>
  group_by(core_id) |>
  summarise(total = sum(carbon_stock_kg_m2), .groups = "drop")

# ── 3. Compaction correction ─────────────────────────────────────────────────
comp_meas <- comp_meas |>
  mutate(
    compaction_factor = if_else(
      is.na(compaction_factor) & !is.na(outside_depth_cm) & inside_depth_cm > 0,
      outside_depth_cm / inside_depth_cm, compaction_factor),
    compaction_cm = outside_depth_cm - inside_depth_cm)

cat("\n── Compaction factors ──\n")
print(as.data.frame(comp_meas |>
  select(core_id, outside_depth_cm, inside_depth_cm, compaction_factor) |>
  mutate(compaction_factor = round(compaction_factor, 4))))

cores <- cores |>
  left_join(select(comp_meas, core_id, compaction_factor), by = "core_id") |>
  mutate(
    compaction_factor  = coalesce(compaction_factor, 1),
    # the two halves that cancel — see the header
    depth_top_cm       = depth_top_cm    * compaction_factor,
    depth_bottom_cm    = depth_bottom_cm * compaction_factor,
    bulk_density_g_cm3 = bulk_density_g_cm3 / compaction_factor,
    layer_thickness_cm = depth_bottom_cm - depth_top_cm,
    depth_cm           = (depth_top_cm + depth_bottom_cm) / 2,
    carbon_stock_kg_m2 = (soc_g_kg * bulk_density_g_cm3 * layer_thickness_cm) / 100)

# ── 4. Enforce the invariant ─────────────────────────────────────────────────
# Decompaction changes where the carbon is, never how much. If this fails, the
# depth stretch and the density thinning have come apart.
stock_after <- cores |>
  group_by(core_id) |>
  summarise(total = sum(carbon_stock_kg_m2), .groups = "drop")

check <- stock_before |>
  rename(before = total) |>
  left_join(rename(stock_after, after = total), by = "core_id") |>
  mutate(diff = abs(after - before))

if (any(check$diff > 1e-9)) {
  print(as.data.frame(check))
  stop("Decompaction changed the carbon stock. Depths and bulk density must be ",
       "corrected by the same factor in opposite directions.")
}
cat("\n✓ Carbon stock unchanged by decompaction (max drift ",
    format(max(check$diff), scientific = TRUE, digits = 2), ")\n", sep = "")
cat("  Cores:", n_distinct(cores$core_id), " Slices:", nrow(cores), "\n")

# ── 5. Optional cross-check against the BlueCarbon package ───────────────────
# BlueCarbon::decompact() parameterises compaction as (1 - inside/outside).
if (USE_BLUECARBON && requireNamespace("BlueCarbon", quietly = TRUE)) {
  cat("\n── BlueCarbon cross-check ──\n")
  bc_in <- samples |>
    left_join(select(comp_meas, core_id, compaction_factor), by = "core_id") |>
    mutate(compaction = coalesce(1 - 1 / compaction_factor, 0))
  names(bc_in)[names(bc_in) == "depth_top_cm"]       <- "mind"
  names(bc_in)[names(bc_in) == "depth_bottom_cm"]    <- "maxd"
  names(bc_in)[names(bc_in) == "bulk_density_g_cm3"] <- "dbd"
  bc <- BlueCarbon::decompact(bc_in, core = "core_id", compaction = "compaction",
                              mind = "mind", maxd = "maxd", dbd = "dbd")
  print(bc |> group_by(core_id) |>
          summarise(bc_max_depth = max(maxd_corrected), .groups = "drop"))
} else if (USE_BLUECARBON) {
  message("BlueCarbon not installed — skipping cross-check.")
}

# ── 6. Look at the raw profiles ──────────────────────────────────────────────
# Always look before you model. A profile that jumps around is a depositional
# signal or a lab error, and you want to know which before it reaches a mean.
library(ggplot2)

p_soc <- ggplot(cores |> arrange(core_id, depth_cm),
                aes(x = soc_g_kg, y = depth_cm, colour = stratum, group = core_id)) +
  geom_path(linewidth = 0.6) + geom_point(size = 1.5) +
  scale_y_reverse(name = "In-situ depth (cm)") +
  scale_colour_manual(values = STRATUM_COLORS, labels = STRATUM_LABELS) +
  theme_bw(base_size = 12) +
  labs(title = "Measured SOC profiles", subtitle = SITE_NAME,
       x = "SOC (g/kg)", colour = "Stratum")

p_bd <- ggplot(cores |> arrange(core_id, depth_cm),
               aes(x = bulk_density_g_cm3, y = depth_cm,
                   colour = stratum, group = core_id)) +
  geom_path(linewidth = 0.6) + geom_point(size = 1.5) +
  scale_y_reverse(name = "In-situ depth (cm)") +
  scale_colour_manual(values = STRATUM_COLORS, labels = STRATUM_LABELS) +
  theme_bw(base_size = 12) +
  labs(title = "Bulk density profiles (decompacted)",
       subtitle = "Divided by the compaction factor — same mass, more volume",
       x = expression("Bulk density (g cm"^{-3}*")"), colour = "Stratum")

p_totals <- cores |>
  group_by(core_id, stratum) |>
  summarise(total = sum(carbon_stock_kg_m2), base = max(depth_bottom_cm),
            .groups = "drop") |>
  ggplot(aes(x = reorder(core_id, total), y = total, fill = stratum)) +
  geom_col(alpha = 0.85) +
  geom_text(aes(label = sprintf("to %.0f cm", base)), hjust = -0.1, size = 3) +
  coord_flip() + expand_limits(y = 0) +
  scale_fill_manual(values = STRATUM_COLORS, labels = STRATUM_LABELS) +
  theme_bw(base_size = 12) +
  labs(title = "Measured carbon stock per core",
       subtitle = "Whole core, before harmonization — cores reach different depths",
       x = NULL, y = expression("Carbon stock (kg C m"^{-2}*")"), fill = "Stratum")

print(p_soc); print(p_bd); print(p_totals)
