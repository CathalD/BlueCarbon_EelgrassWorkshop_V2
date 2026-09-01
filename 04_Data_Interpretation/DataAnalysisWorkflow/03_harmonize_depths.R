# 03_harmonize_depths.R
# Put cores of different lengths and slice thicknesses onto common depth
# intervals, and model the profile below the base of each core.
# Produces `cores_harmonized` — one row per core x depth interval.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM A PACKAGE — mpspline2::mpspline()
#     Mass-preserving (equal-area) quadratic spline, the standard method for
#     harmonising soil and sediment profiles onto common depth supports.
#       Bishop, McBratney & Laslett (1999) Geoderma 91:27-45.
#       Malone, McBratney, Minasny & Laslett (2009) Geoderma 154:138-152.
#       O'Brien (2022) mpspline2.
#   FROM BASE R — stats::nls() with the self-starting SSasymp model, used ONLY
#     below the base of a core where the spline has no data.
#
# ── WHY ASYMPTOTIC, NOT DECAY TO ZERO ────────────────────────────────────────
#   Eelgrass profiles are not a simple decay. Kindeberg et al. (2019, Biol.
#   Lett. 15:20180831) and Janousek et al. describe high labile carbon near the
#   surface, a sharp decline, then a roughly CONSTANT floor of recalcitrant
#   carbon at depth. Decaying to zero understates deep stock; holding the last
#   value constant overstates it. SSasymp fits the observed shape:
#       SOC(d) = Asym + (R0 - Asym) * exp(-exp(lrc) * d)
#   with Asym the recalcitrant floor — fitted, not assumed zero.
#
# ── MEASURED, MODELLED, AND WHY FRACTIONS ────────────────────────────────────
#   A standard interval rarely lines up with where a core ends. Core F reaches
#   26 cm, so the 25-50 cm interval is 4% measured and 96% modelled. Labelling
#   that interval by its MIDPOINT — the obvious shortcut — calls it either
#   entirely measured or entirely modelled, and both are wrong.
#
#   So every interval carries two fractions instead of two flags:
#       frac_primary   how much of it lies above PRIMARY_DEPTH_CM
#       frac_measured  how much of it lies above the core's base
#   Stocks are apportioned by those fractions. This is also what makes
#   PRIMARY_DEPTH_CM safe to change: set it to 40 and the 25-50 interval
#   contributes 60% rather than silently contributing all of itself.
#
# Requires: `cores` from 01_prepare_cores.R

library(dplyr)

source("00_config.R")

if (!exists("cores")) source("01_prepare_cores.R")

if (!requireNamespace("mpspline2", quietly = TRUE))
  stop("Package 'mpspline2' is required. install.packages('mpspline2')")

# ── 1. Clean input ───────────────────────────────────────────────────────────
cores_qa <- cores |>
  filter(!is.na(depth_top_cm), !is.na(depth_bottom_cm),
         !is.na(soc_g_kg), !is.na(bulk_density_g_cm3),
         depth_bottom_cm > depth_top_cm) |>
  arrange(core_id, depth_top_cm)

core_meta <- cores_qa |>
  group_by(core_id) |>
  summarise(stratum = first(stratum), latitude = first(latitude),
            longitude = first(longitude), water_depth_m = first(water_depth_m),
            core_base_cm = max(depth_bottom_cm), n_slices = n(), .groups = "drop")

cat("Harmonizing", nrow(core_meta), "cores /", nrow(cores_qa), "slices\n")

# ── 2. Mass-preserving spline onto the standard intervals ────────────────────
# mpspline() interpolates WITHIN each profile's measured range and returns NA
# below it — the gap the extrapolation model fills.
run_mpspline <- function(df, var) {
  obj <- as.data.frame(df[, c("core_id", "depth_top_cm", "depth_bottom_cm", var)])
  fit <- mpspline2::mpspline(obj, var_name = var, d = DEPTH_BREAKS,
                             vlow = 0, vhigh = max(obj[[var]], na.rm = TRUE) * 2)
  res <- bind_rows(lapply(names(fit), function(id)
    data.frame(core_id = id, depth_cm_midpoint = DEPTH_MIDPOINTS,
               value = as.numeric(fit[[id]]$est_dcm)[seq_along(DEPTH_MIDPOINTS)],
               stringsAsFactors = FALSE)))
  names(res)[names(res) == "value"] <- var
  res
}

harmonized <- run_mpspline(cores_qa, "soc_g_kg") |>
  left_join(run_mpspline(cores_qa, "bulk_density_g_cm3"),
            by = c("core_id", "depth_cm_midpoint")) |>
  left_join(core_meta, by = "core_id") |>
  left_join(DEPTH_INTERVALS |>
              select(depth_cm_midpoint = depth_midpoint,
                     depth_top, depth_bottom, thickness_cm),
            by = "depth_cm_midpoint")

# ── 3. Fractions: how much of each interval is measured, how much is primary ─
overlap_frac <- function(top, bottom, limit) {
  pmax(0, pmin(bottom, limit) - top) / (bottom - top)
}
harmonized <- harmonized |>
  mutate(
    frac_primary  = overlap_frac(depth_top, depth_bottom, PRIMARY_DEPTH_CM),
    frac_measured = overlap_frac(depth_top, depth_bottom, core_base_cm),
    needs_model   = frac_measured < 1)

# ── 4. Model the profile below each core's base ──────────────────────────────
fit_asymp <- function(depth, value) {
  if (length(depth) < 3 || length(unique(depth)) < 3) return(NULL)
  tryCatch(nls(value ~ SSasymp(depth, Asym, R0, lrc),
               data = data.frame(depth = depth, value = value)),
           error = function(e) NULL)
}
predict_at <- function(model, depth) {
  if (is.null(model)) return(NA_real_)
  out <- tryCatch(as.numeric(predict(model, newdata = data.frame(depth = depth))),
                  error = function(e) NA_real_)
  if (is.na(out)) NA_real_ else max(0, out)
}

slice_mid <- cores_qa |> mutate(depth_mid = (depth_top_cm + depth_bottom_cm) / 2)

# Stratum-level fits (pooled cores — more points, stabler) and core-level fits
# where a core has enough slices. Core-level is preferred; stratum-level is the
# fallback; carrying the deepest measured value forward is the last resort.
stratum_fits <- list()
for (s in unique(slice_mid$stratum)) {
  d <- slice_mid |> filter(stratum == s)
  stratum_fits[[s]] <- list(soc = fit_asymp(d$depth_mid, d$soc_g_kg),
                            bd  = fit_asymp(d$depth_mid, d$bulk_density_g_cm3))
  cat("  stratum", s, "profile model:",
      if (is.null(stratum_fits[[s]]$soc)) "FAILED (fallback)" else "ok", "\n")
}
core_fits <- list()
for (id in unique(slice_mid$core_id)) {
  d <- slice_mid |> filter(core_id == id)
  core_fits[[id]] <- if (nrow(d) >= EXTRAP_MIN_PTS_CORE)
    list(soc = fit_asymp(d$depth_mid, d$soc_g_kg),
         bd  = fit_asymp(d$depth_mid, d$bulk_density_g_cm3))
  else list(soc = NULL, bd = NULL)
}

harmonized$model_source <- NA_character_
for (i in which(harmonized$needs_model)) {
  id <- harmonized$core_id[i]; s <- harmonized$stratum[i]
  d  <- harmonized$depth_cm_midpoint[i]; base <- harmonized$core_base_cm[i]

  # Never predict absurdly far below the core base.
  if (d > base * EXTRAP_MAX_FACTOR) {
    harmonized$soc_g_kg[i] <- NA_real_
    harmonized$bulk_density_g_cm3[i] <- NA_real_
    harmonized$model_source[i] <- "beyond_limit"
    next
  }
  soc_hat <- predict_at(core_fits[[id]]$soc, d)
  bd_hat  <- predict_at(core_fits[[id]]$bd,  d)
  src     <- "core"
  if (is.na(soc_hat)) {
    soc_hat <- predict_at(stratum_fits[[s]]$soc, d)
    bd_hat  <- predict_at(stratum_fits[[s]]$bd,  d)
    src     <- "stratum"
  }
  if (is.na(soc_hat) || is.na(bd_hat)) {
    deepest <- slice_mid |> filter(core_id == id) |>
      arrange(desc(depth_mid)) |> slice(1)
    if (is.na(soc_hat)) { soc_hat <- deepest$soc_g_kg; src <- "constant" }
    if (is.na(bd_hat))    bd_hat  <- deepest$bulk_density_g_cm3
  }
  # Only the modelled PART of a partly-measured interval is replaced; the
  # spline already got the measured part right. But mpspline returns NA for an
  # interval it could not reach at all — and for a barely-measured interval
  # (core F is 4% into the 25-50 cm bin) that NA would poison the blend and
  # delete the whole interval. Where there is no spline value, the model
  # supplies all of it.
  spl_soc <- harmonized$soc_g_kg[i]
  spl_bd  <- harmonized$bulk_density_g_cm3[i]
  f_soc <- if (is.finite(spl_soc)) harmonized$frac_measured[i] else 0
  f_bd  <- if (is.finite(spl_bd))  harmonized$frac_measured[i] else 0
  harmonized$soc_g_kg[i]           <- f_soc * ifelse(is.finite(spl_soc), spl_soc, 0) +
                                      (1 - f_soc) * soc_hat
  harmonized$bulk_density_g_cm3[i] <- f_bd  * ifelse(is.finite(spl_bd),  spl_bd,  0) +
                                      (1 - f_bd)  * bd_hat
  harmonized$model_source[i] <- src
}

# ── 5. Carbon stock per harmonized interval ──────────────────────────────────
cores_harmonized <- harmonized |>
  rename(soc_harmonized = soc_g_kg, bd_harmonized = bulk_density_g_cm3) |>
  filter(!is.na(soc_harmonized), !is.na(bd_harmonized)) |>
  mutate(soc_harmonized = pmax(0, soc_harmonized),
         bd_harmonized  = pmax(0, bd_harmonized),
         carbon_stock_kg_m2 = (soc_harmonized * bd_harmonized * thickness_cm) / 100)

# ── 6. The deepest depth EVERY core can support ──────────────────────────────
# Cores stop at different depths, and EXTRAP_MAX_FACTOR stops the model
# following them much further. Reporting a "full profile" number that averages
# a 0-100 cm core with a 0-50 cm one would be averaging two different
# quantities, so the deep figure is cut to the deepest boundary every core
# reaches. Cores that go deeper are simply not credited for it.
core_reach <- cores_harmonized |>
  group_by(core_id) |>
  summarise(reach = max(depth_bottom), .groups = "drop")
DEEP_DEPTH_CM <- min(core_reach$reach)

cores_harmonized <- cores_harmonized |>
  mutate(frac_deep = overlap_frac(depth_top, depth_bottom, DEEP_DEPTH_CM))

cat(sprintf("\nCommon deep basis: 0-%.0f cm (shallowest core reaches %.0f cm)\n",
            DEEP_DEPTH_CM, DEEP_DEPTH_CM))
if (any(core_reach$reach > DEEP_DEPTH_CM))
  cat("  ", sum(core_reach$reach > DEEP_DEPTH_CM),
      " core(s) reach deeper and are not credited for it — that is the price\n",
      "  of one comparable number.\n", sep = "")

# ── 7. Profile-shape flag (flag only, never filters) ─────────────────────────
# Kindeberg et al. (2019) find eelgrass profiles that increase, decrease, or
# show no pattern. A non-monotonic profile is a depositional signal — a buried
# organic layer — not a data error, so it is recorded and never used to drop
# a core.
shape_flag <- cores_harmonized |>
  group_by(core_id) |>
  summarise(profile_shape = {
    r <- suppressWarnings(cor(depth_cm_midpoint, soc_harmonized,
                              use = "complete.obs", method = "spearman"))
    if (is.na(r)) "undetermined" else if (r < -0.3) "declining"
    else if (r > 0.3) "increasing" else "no clear trend"
  }, .groups = "drop")

cores_harmonized <- cores_harmonized |> left_join(shape_flag, by = "core_id")

# ── 8. Report ────────────────────────────────────────────────────────────────
cat("\nHarmonization complete. Cores:", n_distinct(cores_harmonized$core_id),
    " Rows:", nrow(cores_harmonized), "\n")

cat("\n── Modelled share of stock, by stratum (apportioned by overlap) ──\n")
print(as.data.frame(cores_harmonized |>
  group_by(stratum) |>
  summarise(stock_deep     = sum(carbon_stock_kg_m2 * frac_deep),
            stock_measured = sum(carbon_stock_kg_m2 * pmin(frac_measured, frac_deep)),
            pct_modelled   = round(100 * (1 - stock_measured / stock_deep), 1),
            .groups = "drop")))

cat("\n── Profile shapes (flag only, nothing filtered) ──\n")
print(as.data.frame(shape_flag))

# ── 9. Visual check ──────────────────────────────────────────────────────────
library(ggplot2)

p_harmonized <- ggplot(cores_harmonized,
    aes(x = carbon_stock_kg_m2, y = depth_cm_midpoint,
        group = core_id, colour = stratum)) +
  geom_path(linewidth = 0.6) +
  geom_point(aes(alpha = frac_measured), size = 2) +
  scale_y_reverse(name = "Depth midpoint (cm)") +
  scale_colour_manual(values = STRATUM_COLORS, labels = STRATUM_LABELS) +
  scale_alpha_continuous(range = c(0.2, 1), name = "Fraction\nmeasured",
                         breaks = c(0, 0.5, 1)) +
  geom_hline(yintercept = PRIMARY_DEPTH_CM, linetype = "dashed", colour = "grey40") +
  theme_bw(base_size = 12) +
  labs(title = "Harmonized carbon stock by depth",
       subtitle = sprintf(paste0("Mass-preserving spline (mpspline2). Faded points ",
                                 "are mostly modelled.\nDashed line = %d cm, the ",
                                 "depth every core reached."), PRIMARY_DEPTH_CM),
       x = expression("Carbon stock (kg C m"^{-2}*")"), colour = "Stratum")

print(p_harmonized)
