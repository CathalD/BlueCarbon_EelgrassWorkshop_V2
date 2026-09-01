# 02_derive_prior.R
# Build the eelgrass carbon prior from cores at sites like yours.
#
# Produces  data/prior_eelgrass_janousek.csv  (read back by 00_config.R)
#      and  data/prior_cores.csv              (every candidate core, for the viewer)
#
# ── WHY ──────────────────────────────────────────────────────────────────────
#   Part 2 needs a prior to size the campaign; Part 4 needs one to update the
#   estimate. There is no published carbon MAP for eelgrass, so the prior comes
#   from a synthesis of real cores instead — Janousek et al. (2025).
#
#   Two filters make it a useful prior rather than a misleading one:
#     1. SPECIES. The synthesis covers all coastal ecosystems. Its overall mean
#        is dominated by marsh and mangrove and is several times too high for
#        eelgrass, so we take Zostera marina only.
#     2. SIMILARITY. A meadow in a Baja lagoon tells you less about a Salish
#        Sea embayment than a meadow next door does. We rank every core by how
#        much its setting resembles yours and build the prior from the closest
#        match that still rests on enough distinct estuaries.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM A DATASET — Janousek et al. (2025), Pacific coast coastal-wetland soil
#     carbon synthesis (figshare 28127486). Tables: cores, depthseries.
#   FROM SCRATCH (base R) — the similarity ladder, the depth integration and
#     the variance decomposition. All three need to stay visible to the reader,
#     and none is complicated enough to justify hiding in a package.
#
# ── THE TWO STANDARD DEVIATIONS ──────────────────────────────────────────────
#   SD_PLOT   core-to-core spread WITHIN a meadow. This is the CV in the
#             sample-size calculator: it answers "how patchy is a meadow?" and
#             decides how many cores you need. It does not belong in a posterior.
#   SD_MEAN   meadow-to-meadow spread. The uncertainty in "what is the mean of
#             a meadow like this one, before we sample it?" This is what
#             weights the prior against your own cores.
#
#   Using SD_PLOT in the update makes the prior inert; using the naive standard
#   error of the synthesis mean lets it steamroll your fieldwork. The
#   between-group SD from the decomposition below is the honest middle.
#
# Requires: 00_config.R

library(dplyr)
library(readr)
library(tidyr)

source("00_config.R")

# ── 1. Load ──────────────────────────────────────────────────────────────────
if (is.null(JANOUSEK_DIR) || !dir.exists(path.expand(JANOUSEK_DIR))) {
  stop("JANOUSEK_DIR is not set or does not exist (see 00_config.R).\n",
       "  Download from https://doi.org/10.25573/serc.28127486")
}
jdir    <- path.expand(JANOUSEK_DIR)
f_cores <- file.path(jdir, "Janousek_et_al_2025_cores.csv")
f_depth <- file.path(jdir, "Janousek_et_al_2025_depthseries.csv")
for (f in c(f_cores, f_depth)) if (!file.exists(f)) stop("Missing: ", f)

cores_all <- read_csv(f_cores, show_col_types = FALSE)
depth_all <- read_csv(f_depth, show_col_types = FALSE)
cat("Janousek synthesis:", nrow(cores_all), "cores,", nrow(depth_all), "layers\n")

# ── 2. Filter to the species ─────────────────────────────────────────────────
cat("\n── Filtering to eelgrass ──\n")
cat(sprintf("  all coastal cores                   %5d\n", nrow(cores_all)))
cat(sprintf("  Ecosystem 'SG' (any seagrass)       %5d\n",
            sum(cores_all$Ecosystem == "SG", na.rm = TRUE)))
cand <- cores_all |> filter(VegGrp == PRIOR_VEG_GROUP)
cat(sprintf("  VegGrp '%s' (target species)   %5d\n", PRIOR_VEG_GROUP, nrow(cand)))

# ── 3. Drop your own site ────────────────────────────────────────────────────
# A prior must be INDEPENDENT of the data it will be combined with. If the
# synthesis already contains cores from your meadow, updating with it counts
# them once as prior and again as evidence, and the posterior looks more
# certain than the evidence warrants.
if (!is.null(PRIOR_EXCLUDE_ESTUARY)) {
  hit <- cand |> filter(Estuary %in% PRIOR_EXCLUDE_ESTUARY)
  if (nrow(hit) > 0) {
    cat(sprintf("\n  ⚠ %d core(s) from estuary '%s' are YOUR site — excluded\n",
                nrow(hit), paste(PRIOR_EXCLUDE_ESTUARY, collapse = ", ")))
    print(as.data.frame(hit |> select(SampID, Estuary, State, Lat, Long, Stk30)))
  }
  cand <- cand |> filter(!Estuary %in% PRIOR_EXCLUDE_ESTUARY)
}

# ── 4. How like your site is each core? ──────────────────────────────────────
# Four plain indicators, all recorded for every core in the synthesis:
#   distance      how far away it is
#   estuary type  embayment / tide-dominated / river-dominated / lagoon
#   ecoregion     EPA/CEC level-1 ecoregion
#   climate       Koppen-Geiger zone
# Your site's own setting is read off the nearest synthesis cores, so this
# works anywhere on the coast without you having to look codes up.
haversine_km <- function(lat, lon, lat0, lon0) {
  r <- pi / 180
  6371 * acos(pmin(1, sin(lat0 * r) * sin(lat * r) +
                     cos(lat0 * r) * cos(lat * r) * cos((lon - lon0) * r)))
}

cand <- cand |> mutate(dist_km = haversine_km(Lat, Long, SITE_LAT, SITE_LON))

# Site context = the majority setting of the nearest handful of eelgrass cores.
near <- cores_all |>
  filter(VegGrp == PRIOR_VEG_GROUP) |>
  mutate(dist_km = haversine_km(Lat, Long, SITE_LAT, SITE_LON)) |>
  arrange(dist_km) |>
  slice_head(n = 5)
mode1 <- function(x) { x <- x[!is.na(x)]; names(sort(table(x), decreasing = TRUE))[1] }
SITE_ESTTYPE <- mode1(near$EstType)
SITE_ECOREG  <- mode1(near$Lvl1EcoReg)
SITE_CLIMATE <- mode1(near$KGzone)

cat(sprintf("\n── Your site's setting (from the %d nearest eelgrass cores) ──\n", nrow(near)))
cat(sprintf("  estuary type %s | ecoregion %s | climate %s | nearest core %.0f km\n",
            SITE_ESTTYPE, SITE_ECOREG, SITE_CLIMATE, min(near$dist_km)))

cand <- cand |>
  mutate(
    match_esttype = EstType            == SITE_ESTTYPE,
    match_ecoreg  = as.character(Lvl1EcoReg) == SITE_ECOREG,
    match_climate = KGzone             == SITE_CLIMATE,
    n_match       = rowSums(cbind(match_esttype, match_ecoreg, match_climate),
                            na.rm = TRUE)
  )

# ── 5. Integrate every candidate to YOUR reporting depth ─────────────────────
# The synthesis publishes stocks at 30, 50 and 100 cm. None is necessarily
# PRIMARY_DEPTH_CM, and a prior on one depth basis cannot be compared with a
# result on another — a 0-1 m prior is roughly three times a 0-25 cm one, so
# mixing them silently would be a large invisible error. Integrating the layer
# data directly avoids rescaling with a borrowed depth curve.
#   carbon density (g/cm3) x thickness (cm) x 100 = Mg C/ha
cat(sprintf("\n── Integrating each core to %d cm ──\n", PRIMARY_DEPTH_CM))

layers <- depth_all |>
  filter(SampID %in% cand$SampID) |>
  mutate(carbon_density = coalesce(Calc_CD_C, Calc_CD_OM)) |>
  separate(ExtrapInterval, into = c("layer_top", "layer_bottom"),
           sep = "-", convert = TRUE, fill = "right") |>
  filter(is.finite(layer_top), is.finite(layer_bottom),
         layer_bottom > layer_top, is.finite(carbon_density))

deep_enough <- layers |>
  group_by(SampID) |>
  summarise(deepest = max(layer_bottom), .groups = "drop") |>
  filter(deepest >= PRIMARY_DEPTH_CM)

stock_by_core <- layers |>
  filter(SampID %in% deep_enough$SampID) |>
  mutate(overlap_cm = pmax(0, pmin(layer_bottom, PRIMARY_DEPTH_CM) - layer_top)) |>
  group_by(SampID) |>
  summarise(stock_MgC_ha = sum(carbon_density * overlap_cm) * 100, .groups = "drop")

cand <- cand |>
  inner_join(stock_by_core, by = "SampID") |>
  filter(is.finite(stock_MgC_ha), stock_MgC_ha > 0)

cat(sprintf("  cores reaching %d cm: %d across %d estuaries\n",
            PRIMARY_DEPTH_CM, nrow(cand), n_distinct(cand$Estuary)))
chk <- cand |> filter(is.finite(Stk30))
if (nrow(chk) > 0)
  cat(sprintf("  cross-check: mean %d cm = %.2f vs published 30 cm = %.2f (ratio %.3f)\n",
              PRIMARY_DEPTH_CM, mean(chk$stock_MgC_ha), mean(chk$Stk30),
              mean(chk$stock_MgC_ha) / mean(chk$Stk30)))

# ── 6. Variance decomposition ────────────────────────────────────────────────
# One-way random effects with ESTUARY as the group, by method of moments
# (Searle, Casella & McCulloch 1992, ch. 3):
#     stock_ij = mu + a_i + e_ij     a_i ~ (0, sd_between²)   estuary
#                                    e_ij ~ (0, sd_within²)   core in estuary
decompose_variance <- function(values, groups) {
  ok <- is.finite(values) & !is.na(groups)
  values <- values[ok]; groups <- as.character(groups[ok])
  k <- length(unique(groups)); N <- length(values)
  if (k < 2) return(NULL)
  n_i <- as.numeric(table(groups))
  gm  <- mean(values); gmi <- tapply(values, groups, mean)
  ms_between <- sum(n_i * (gmi - gm)^2) / (k - 1)
  ms_within  <- sum((values - gmi[groups])^2) / (N - k)
  n0 <- (N - sum(n_i^2) / N) / (k - 1)
  var_between <- max(0, (ms_between - ms_within) / n0)
  list(n_cores = N, n_estuaries = k, grand_mean = gm,
       sd_between = sqrt(var_between), sd_within = sqrt(ms_within),
       sd_total = sd(values), icc = var_between / (var_between + ms_within))
}

# ── 7. The similarity ladder ─────────────────────────────────────────────────
# Each rung is more like your site than the one above and rests on fewer
# estuaries. Narrowing is not free: the bottom rung often collapses onto a
# single bay, which looks precise because it IS one place, not because it
# describes yours well. We take the most specific rung that still has
# PRIOR_MIN_ESTUARIES distinct estuaries behind it.
rungs <- list(
  list(label = "all eelgrass cores",     data = cand),
  list(label = "+ same climate zone",    data = cand |> filter(match_climate)),
  list(label = "+ same ecoregion",       data = cand |> filter(match_climate, match_ecoreg)),
  list(label = "+ same estuary type",    data = cand |> filter(match_climate, match_ecoreg, match_esttype))
)

cat("\n── Similarity ladder ──\n")
cat(sprintf("  %-22s %5s %5s %8s %7s %7s %9s\n",
            "prior set", "cores", "est.", "mean", "SD_mean", "SD_plot", "med. dist"))
ladder <- list()
for (i in seq_along(rungs)) {
  d <- rungs[[i]]$data
  v <- if (nrow(d) >= 2) decompose_variance(d$stock_MgC_ha, d$Estuary) else NULL
  ok <- !is.null(v) && v$n_estuaries >= PRIOR_MIN_ESTUARIES
  ladder[[i]] <- list(label = rungs[[i]]$label, data = d, v = v, ok = ok)
  if (is.null(v)) {
    cat(sprintf("  %-22s %5d %5s %8s %7s %7s %9s   too few\n",
                rungs[[i]]$label, nrow(d), "-", "-", "-", "-", "-"))
  } else {
    cat(sprintf("  %-22s %5d %5d %8.1f %7.1f %7.1f %8.0f km%s\n",
                rungs[[i]]$label, v$n_cores, v$n_estuaries, v$grand_mean,
                v$sd_between, v$sd_within, median(d$dist_km),
                if (!ok) "   ← too few estuaries" else ""))
  }
}

usable <- Filter(function(x) isTRUE(x$ok), ladder)
if (!length(usable)) {
  stop("No rung has at least ", PRIOR_MIN_ESTUARIES, " estuaries. ",
       "Lower PRIOR_MIN_ESTUARIES or widen the species filter.")
}
chosen <- usable[[length(usable)]]        # most specific rung that passed
prior_cores <- chosen$data
v <- chosen$v

cat(sprintf("\n  → using '%s': %d cores, %d estuaries\n",
            chosen$label, v$n_cores, v$n_estuaries))
dropped <- setdiff(seq_along(ladder), which(vapply(ladder, function(x) isTRUE(x$ok), logical(1))))
if (length(dropped))
  cat(sprintf("    (rungs below it rest on fewer than %d estuaries — a prior from\n",
              PRIOR_MIN_ESTUARIES),
      "     one or two bays is specific to those bays, not to yours)\n", sep = "")

cat("\n── Variance decomposition (grouping = estuary) ──\n")
cat(sprintf("  grand mean                            %6.2f Mg C/ha\n", v$grand_mean))
cat(sprintf("  SD between estuaries -> PRIOR_SD_MEAN %6.2f   (weights the prior)\n", v$sd_between))
cat(sprintf("  SD between cores     -> PRIOR_SD_PLOT %6.2f   (drives sample size)\n", v$sd_within))
cat(sprintf("  total SD %6.2f   CV = %.2f   ICC = %.3f\n",
            v$sd_total, v$sd_total / v$grand_mean, v$icc))
cat(sprintf("  naive SE of the mean %6.2f  ← NOT the prior's SD: it assumes every\n",
            v$sd_total / sqrt(v$n_cores)))
cat("     meadow on the coast has the same true mean, and would let the\n")
cat("     synthesis outvote your own fieldwork.\n")

# ── 8. Write ─────────────────────────────────────────────────────────────────
prior_eelgrass <- data.frame(
  prior_mean_MgC_ha = round(v$grand_mean, 3),
  prior_sd_mean     = round(v$sd_between, 3),
  prior_sd_plot     = round(v$sd_within,  3),
  prior_cv_plot     = round(v$sd_within / v$grand_mean, 3),
  depth_basis_cm    = PRIMARY_DEPTH_CM,
  n_cores           = v$n_cores,
  n_estuaries       = v$n_estuaries,
  icc               = round(v$icc, 3),
  prior_set         = chosen$label,
  veg_group         = PRIOR_VEG_GROUP,
  site_esttype      = SITE_ESTTYPE,
  site_ecoregion    = SITE_ECOREG,
  site_climate      = SITE_CLIMATE,
  excluded_estuary  = if (is.null(PRIOR_EXCLUDE_ESTUARY)) NA_character_
                      else paste(PRIOR_EXCLUDE_ESTUARY, collapse = "+"),
  source            = "Janousek et al. (2025) figshare 28127486",
  derived_on        = format(Sys.Date()),
  stringsAsFactors  = FALSE
)

if (!dir.exists(DATA_DIR)) dir.create(DATA_DIR, recursive = TRUE)
write_csv(prior_eelgrass, file.path(DATA_DIR, "prior_eelgrass_janousek.csv"))

# Every candidate core, flagged for whether it made the prior set — this is
# what view_prior.R maps.
write_csv(
  cand |>
    mutate(in_prior_set = SampID %in% prior_cores$SampID) |>
    select(SampID, Estuary, State, Lat, Long, EstType, Lvl1EcoReg, KGzone,
           dist_km, match_esttype, match_ecoreg, match_climate, n_match,
           stock_MgC_ha, in_prior_set),
  file.path(DATA_DIR, "prior_cores.csv"))

cat("\n── Written ──\n")
cat("  ", file.path(DATA_DIR, "prior_eelgrass_janousek.csv"), "\n")
cat("  ", file.path(DATA_DIR, "prior_cores.csv"), " (", nrow(cand), " candidate cores)\n", sep = "")

cat(sprintf("\nIn one line: eelgrass carbon to %d cm at sites like yours is about\n",
            PRIMARY_DEPTH_CM))
cat(sprintf("  %.1f Mg C/ha; meadows differ from each other by +/- %.1f (this weights\n",
            v$grand_mean, v$sd_between))
cat(sprintf("  the prior) and cores differ within a meadow by +/- %.1f (this sets n).\n",
            v$sd_within))

# ── 9. The picture: why PRIOR_SD_MEAN is what it is ──────────────────────────
# Each grey dot is one core; each orange diamond an estuary mean. The scatter
# of the DIAMONDS is the meadow-to-meadow SD that weights the prior — not the
# scatter of the dots, which is the within-meadow patchiness that sets n.
library(ggplot2)

est_order <- prior_cores |>
  group_by(Estuary) |>
  summarise(m = mean(stock_MgC_ha), .groups = "drop") |>
  arrange(m)

p_prior <- prior_cores |>
  mutate(Estuary = factor(Estuary, levels = est_order$Estuary)) |>
  ggplot(aes(x = Estuary, y = stock_MgC_ha)) +
  geom_hline(yintercept = v$grand_mean, colour = "#2E8B57", linewidth = 0.7) +
  geom_hline(yintercept = v$grand_mean + c(-1, 1) * v$sd_between,
             colour = "#2E8B57", linetype = "dashed", linewidth = 0.5) +
  geom_point(alpha = 0.55, size = 1.8, colour = "grey30") +
  stat_summary(fun = mean, geom = "point", colour = "#e76f51",
               size = 2.8, shape = 18) +
  coord_flip() +
  theme_bw(base_size = 11) +
  labs(
    title = sprintf("Prior: %s to %d cm — %s",
                    PRIOR_VEG_GROUP, PRIMARY_DEPTH_CM, chosen$label),
    subtitle = sprintf(paste0("Janousek et al. (2025): %d cores, %d estuaries. ",
                              "Green = mean; dashed = +/- meadow-to-meadow SD (%.1f).\n",
                              "Orange diamonds are estuary means — their scatter IS the prior's SD."),
                       v$n_cores, v$n_estuaries, v$sd_between),
    x = NULL, y = expression("Carbon stock (Mg C ha"^{-1}*")"))

dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(OUTPUT_DIR, "prior_eelgrass_janousek.png"), p_prior,
       width = 8, height = 6, dpi = 150)
cat("  ", file.path(OUTPUT_DIR, "prior_eelgrass_janousek.png"), "\n")
print(p_prior)
