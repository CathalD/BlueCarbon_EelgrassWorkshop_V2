# 04_estimate_stock.R
# Design-based carbon stock estimation for a STRATIFIED sample.
# Produces `core_totals`, `est_primary`, `est_deep`, `design`.
#
# This mirrors the sampling design taught in 02_Project_Planning: the area is
# divided into strata, cores are allocated across them, and each stratum's mean
# is weighted by its AREA — not by how many cores happened to land in it.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM A PACKAGE — survey::svydesign(), svymean(), svyby(), svyttest()
#     The standard R implementation of design-based (Horvitz-Thompson)
#     estimation for stratified samples. The stratified mean, its standard
#     error, the finite population correction and the degrees of freedom all
#     come from a peer-reviewed, widely-audited implementation.
#       Lumley (2004) J. Stat. Software 9(1):1-19; Lumley (2010) Complex Surveys.
#       Underlying estimator: Cochran (1977) Sampling Techniques, 3rd ed.
#
# ── WHY NOT A SIMPLE MEAN ACROSS ALL CORES ───────────────────────────────────
#   Pooling strata that differ several-fold would produce a mean describing no
#   real place, and inflate the variance with the between-stratum contrast the
#   design deliberately removed. The stratified estimator is
#       mean_st = sum_h ( W_h * mean_h ),      W_h = area_h / area_total
#       Var     = sum_h ( W_h^2 * s_h^2 / n_h )
#   which is what survey:: computes from the design object below.
#
# Requires: `cores_harmonized` and DEEP_DEPTH_CM from 03_harmonize_depths.R

library(dplyr)

source("00_config.R")

if (!exists("cores_harmonized")) source("03_harmonize_depths.R")

if (!requireNamespace("survey", quietly = TRUE))
  stop("Package 'survey' is required. install.packages('survey')")
suppressPackageStartupMessages(library(survey))

# ── 1. One row per core ──────────────────────────────────────────────────────
# The sampling unit is the CORE, not the slice. Slices within a core are not
# independent observations, so all inference runs on per-core totals.
# Each interval contributes the FRACTION of itself that falls in the window —
# see the note on fractions in 03.
core_totals <- cores_harmonized |>
  group_by(core_id, stratum, latitude, longitude, water_depth_m) |>
  summarise(
    stock_primary  = sum(carbon_stock_kg_m2 * frac_primary),
    stock_deep     = sum(carbon_stock_kg_m2 * frac_deep),
    stock_measured = sum(carbon_stock_kg_m2 * pmin(frac_measured, frac_deep)),
    .groups = "drop") |>
  mutate(pct_modelled = 100 * (1 - stock_measured / stock_deep))

# ── 2. Design information ────────────────────────────────────────────────────
# N_h = number of possible plot locations in stratum h = stratum area / plot
# area. Each core represents a PLOT_AREA_M2 plot, not the corer's own
# cross-section, so N_h counts the plots the stratum could hold.
strata_df <- data.frame(stratum = names(STRATUM_AREAS_M2),
                        area_m2 = as.numeric(STRATUM_AREAS_M2),
                        stringsAsFactors = FALSE) |>
  mutate(N_h = area_m2 / PLOT_AREA_M2, W_h = area_m2 / sum(area_m2))

core_totals <- core_totals |> left_join(strata_df, by = "stratum")
strata_df   <- strata_df |>
  left_join(count(core_totals, stratum, name = "n_h"), by = "stratum")

cat("\n── Design ──\n")
print(as.data.frame(strata_df |> select(stratum, area_m2, W_h, n_h, N_h) |>
                      mutate(W_h = round(W_h, 3), N_h = round(N_h))))

if (any(strata_df$n_h < 2))
  warning("A stratum has < 2 cores — its variance cannot be estimated.")

# ── 3. Survey design object ──────────────────────────────────────────────────
# ids = ~1   cores sampled directly, no clustering
# strata     the design strata
# fpc = ~N_h finite population correction; survey derives the weights N_h/n_h
design <- svydesign(ids = ~1, strata = ~stratum, fpc = ~N_h, data = core_totals)
cat("\nDesign degrees of freedom:", degf(design), " (n cores - n strata)\n")

# ── 4. Estimates ─────────────────────────────────────────────────────────────
report_estimate <- function(formula, label) {
  est <- svymean(formula, design)
  ci  <- confint(est, level = CONF_LEVEL, df = degf(design))
  cat(sprintf("\n%s\n", label))
  cat(sprintf("  Mean:   %.2f kg C/m²   (%.1f Mg C/ha)\n",
              coef(est)[1], coef(est)[1] * 10))
  cat(sprintf("  SE:     %.2f\n", SE(est)[1]))
  cat(sprintf("  %.0f%% CI: [%.2f, %.2f] kg C/m²\n",
              CONF_LEVEL * 100, ci[1, 1], ci[1, 2]))
  cat(sprintf("  Relative margin of error: %.1f%%\n",
              100 * (ci[1, 2] - coef(est)[1]) / coef(est)[1]))
  invisible(list(estimate = coef(est)[1], se = SE(est)[1], ci = ci))
}

cat("\n═══ AREA-WEIGHTED STRATIFIED ESTIMATES ═══")

est_primary <- report_estimate(~stock_primary, sprintf(
  "── Stock to %d cm — every core measured this far; comparable to published values ──",
  PRIMARY_DEPTH_CM))

est_deep <- report_estimate(~stock_deep, sprintf(
  "── Stock to %.0f cm — the deepest common basis; partly modelled ──",
  DEEP_DEPTH_CM))

cat("\n── Per-stratum means ──\n")
by_stratum <- svyby(~stock_primary + stock_deep, ~stratum, design, svymean)
print(as.data.frame(by_stratum))

cat(sprintf("\n── Modelled share of the 0-%.0f cm stock, per core ──\n", DEEP_DEPTH_CM))
print(as.data.frame(core_totals |>
  select(core_id, stratum, stock_measured, stock_deep, pct_modelled) |>
  mutate(across(where(is.numeric), \(x) round(x, 2)))))

# ── 5. Site-wide total ───────────────────────────────────────────────────────
total_area_m2 <- sum(strata_df$area_m2)
cat(sprintf("\n── Site total (%.2f ha, areas from 00_config.R) ──\n",
            total_area_m2 / 10000))
for (nm in c("primary", "deep")) {
  e <- if (nm == "primary") est_primary else est_deep
  cat(sprintf("  %-8s %.1f Mg C  (SE %.1f)\n", nm,
              e$estimate * total_area_m2 / 1000, e$se * total_area_m2 / 1000))
}
if (!is.null(AOI_FILE) && file.exists(AOI_FILE))
  cat("\nAOI_FILE is set — replace STRATUM_AREAS_M2 with the areas it reports.\n")

# ── 6. Comparing strata ──────────────────────────────────────────────────────
# Part 2 asks two things: estimate the mean, AND compare between areas.
# svyttest() uses the same weights and degrees of freedom as the estimates
# above, so the test is consistent with the design rather than ad hoc.
if (n_distinct(core_totals$stratum) == 2) {
  cat("\n── Comparing strata (design-based t-test) ──\n")
  tt <- tryCatch(svyttest(stock_primary ~ stratum, design), error = function(e) NULL)
  if (!is.null(tt)) {
    cat(sprintf("  Difference in mean stock to %d cm: %.2f kg C/m²\n",
                PRIMARY_DEPTH_CM, as.numeric(tt$estimate)))
    cat(sprintf("  t = %.2f, df = %d, p = %.4f\n", as.numeric(tt$statistic),
                as.integer(tt$parameter), tt$p.value))
    cat(sprintf("  %.0f%% CI on the difference: [%.2f, %.2f]\n", CONF_LEVEL * 100,
                confint(tt, level = CONF_LEVEL)[1], confint(tt, level = CONF_LEVEL)[2]))
    if (min(strata_df$n_h) < 5)
      cat("  ⚠ With fewer than 5 cores in a stratum this test has very low power —\n",
          "    a non-significant result is not evidence the strata are equal.\n", sep = "")
  }
}

# ── 7. Plot ──────────────────────────────────────────────────────────────────
library(ggplot2)

plot_df <- as.data.frame(by_stratum) |>
  mutate(lwr = stock_primary - qt(1 - (1 - CONF_LEVEL)/2, degf(design)) * se.stock_primary,
         upr = stock_primary + qt(1 - (1 - CONF_LEVEL)/2, degf(design)) * se.stock_primary)

p_stratified <- ggplot(plot_df, aes(x = stratum, y = stock_primary, fill = stratum)) +
  geom_col(alpha = 0.85, width = 0.6) +
  geom_errorbar(aes(ymin = pmax(0, lwr), ymax = upr), width = 0.15) +
  scale_fill_manual(values = STRATUM_COLORS, labels = STRATUM_LABELS, guide = "none") +
  scale_x_discrete(labels = STRATUM_LABELS) +
  theme_bw(base_size = 12) +
  labs(title = sprintf("Carbon stock to %d cm by stratum", PRIMARY_DEPTH_CM),
       subtitle = sprintf("%s — %.0f%% CI, %d design df", SITE_NAME,
                          CONF_LEVEL * 100, degf(design)),
       x = NULL, y = expression("Carbon stock (kg C m"^{-2}*")"))

print(p_stratified)
