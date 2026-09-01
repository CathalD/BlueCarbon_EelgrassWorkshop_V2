# 05_combine_prior.R
# Combine the prior with your own cores, and say whether the result is
# precise enough to manage by.
#
# Requires: est_primary and design from 04_estimate_stock.R
#           PRIOR_* from 00_config.R (written by 02_derive_prior.R)
#
# ── WHY THIS STEP EXISTS ─────────────────────────────────────────────────────
#   Part 2 collected a prior to size the campaign, then threw it away. That is
#   a waste: the prior is real information about meadows like yours, gathered
#   at real cost, and it is still true after your fieldwork. Combining the two
#   is a weighted average — nothing more exotic — and it produces an estimate
#   at least as precise as either source alone.
#
#   The weighting is the whole idea. Each source contributes in proportion to
#   its PRECISION (1/SD²), so a vague prior barely moves the answer and a
#   sharp one moves it a lot. The weight is reported below, because "how much
#   did the prior actually matter?" is the question a reviewer will ask.
#
# ── PROVENANCE ───────────────────────────────────────────────────────────────
#   FROM A PACKAGE — survey:: supplies the evidence (04). The design-based
#     stratified mean and its SE are what get updated; this script does not
#     re-estimate anything.
#   FROM SCRATCH (base R) — the Normal-Normal update itself. It is three lines
#     of arithmetic (Gelman et al. 2013, Bayesian Data Analysis, section 2.5); a
#     package would hide the one thing the reader most needs to see.
#
# ── ASSUMPTIONS, STATED ──────────────────────────────────────────────────────
#   1. INDEPENDENCE. The prior must not contain your site. 02_derive_prior.R
#      excludes it by estuary — see PRIOR_EXCLUDE_ESTUARY.
#   2. SAME DEPTH BASIS. A 0-1 m prior is about three times a 0-25 cm one.
#      Mixing bases is a large invisible error, so it is checked and refused
#      below rather than warned about.
#   3. The right SD. PRIOR_SD_MEAN (meadow-to-meadow), never PRIOR_SD_PLOT.

library(dplyr)

source("00_config.R")

if (!exists("est_primary")) source("04_estimate_stock.R")

# ── 1. Gate: is the prior usable at all? ─────────────────────────────────────
if (is.na(PRIOR_MEAN) || is.na(PRIOR_SD_MEAN)) {
  stop("No prior available. Run 02_derive_prior.R first.")
}
if (!isTRUE(PRIOR_DEPTH_BASIS == PRIMARY_DEPTH_CM)) {
  stop("Depth-basis mismatch: the prior is on a 0-", PRIOR_DEPTH_BASIS,
       " cm basis but the estimate is 0-", PRIMARY_DEPTH_CM, " cm.\n",
       "  These are not comparable. Re-run 02_derive_prior.R so the prior is\n",
       "  integrated to PRIMARY_DEPTH_CM, or change PRIMARY_DEPTH_CM to match.")
}

# ── 2. The two inputs, both in Mg C/ha ───────────────────────────────────────
# 04 works in kg C/m²; the prior is in Mg C/ha. 1 kg C/m² = 10 Mg C/ha.
evidence_mean <- est_primary$estimate * 10
evidence_sd   <- est_primary$se       * 10   # SE of the mean — not the core SD

cat("\n═══ COMBINING THE PRIOR WITH YOUR CORES ═══\n")
cat(sprintf("\n  Reporting basis: 0-%d cm (both sources)\n", PRIMARY_DEPTH_CM))
cat(sprintf("\n  PRIOR    %6.1f ± %-5.1f Mg C/ha   %s\n",
            PRIOR_MEAN, PRIOR_SD_MEAN, PRIOR_SOURCE))
cat(sprintf("           %d cores from %d estuaries at sites like yours\n",
            PRIOR_N, PRIOR_N_ESTUARIES))
cat(sprintf("  EVIDENCE %6.1f ± %-5.1f Mg C/ha   your %d cores, design-based (04)\n",
            evidence_mean, evidence_sd, nrow(core_totals)))

# ── 3. The update ────────────────────────────────────────────────────────────
# Precision-weighted average. Each source's weight is its precision, 1/SD².
prior_precision    <- 1 / PRIOR_SD_MEAN^2
evidence_precision <- 1 / evidence_sd^2
posterior_precision <- prior_precision + evidence_precision

posterior_mean <- (PRIOR_MEAN * prior_precision +
                   evidence_mean * evidence_precision) / posterior_precision
posterior_sd   <- sqrt(1 / posterior_precision)
prior_weight   <- prior_precision / posterior_precision

cat(sprintf("\n  POSTERIOR %5.1f ± %-5.1f Mg C/ha\n", posterior_mean, posterior_sd))
cat(sprintf("\n  The prior earned %.0f%% of the weight; your cores %.0f%%.\n",
            100 * prior_weight, 100 * (1 - prior_weight)))
cat(sprintf("  Uncertainty fell from ± %.2f to ± %.2f (%.0f%% narrower).\n",
            evidence_sd, posterior_sd, 100 * (1 - posterior_sd / evidence_sd)))
if (prior_weight < 0.05) {
  cat("  ⚠ The prior is doing almost nothing here — your cores dominate.\n")
  cat("    That is a legitimate result, not a failure: it means the campaign\n")
  cat("    was informative enough to stand on its own.\n")
}

# ── 4. Is it good enough to manage by? ───────────────────────────────────────
# The question is never "is the model right?" but "does the estimate meet the
# precision target set before sampling?" Both halves of that target are the
# project's own choice (TARGET_MARGIN, TARGET_CONFIDENCE in 00_config.R).
# Use the DESIGN degrees of freedom, not a normal quantile. With 6 cores in 2
# strata there are 4 df, so the multiplier is t(4) = 2.13, not z = 1.64 — a 30%
# wider interval. Using z here would report a different precision than 04 does
# for the same estimate, and the optimistic one at that.
df_design <- degf(design)
z <- qt(1 - (1 - TARGET_CONFIDENCE) / 2, df = df_design)
check_target <- function(mean, sd, label) {
  rel <- z * sd / mean
  pass <- rel <= TARGET_MARGIN
  cat(sprintf("  %-28s ±%5.1f%%   %s\n", label, 100 * rel,
              if (pass) "PASS" else "FAIL"))
  invisible(list(rel = rel, pass = pass))
}
cat(sprintf("\n── Precision target: ±%.0f%% at %.0f%% confidence (t, %d design df) ──\n",
            100 * TARGET_MARGIN, 100 * TARGET_CONFIDENCE, df_design))
r_ev   <- check_target(evidence_mean,  evidence_sd,  "your cores alone")
r_post <- check_target(posterior_mean, posterior_sd, "with the prior")

# ── 5. If it failed, how many more cores? ────────────────────────────────────
# Planning next season. Uses the CORE-TO-CORE spread (PRIOR_SD_PLOT), because
# that is what adding cores averages down — not the SE, which is already the
# result of averaging.
if (!r_post$pass) {
  se_target <- TARGET_MARGIN * posterior_mean / z
  # The spread that adding cores averages down. PLANNING_CV is the dial; it
  # falls back to the within-meadow CV derived from the synthesis.
  cv_plan   <- if (is.na(PLANNING_CV)) PRIOR_CV_PLOT else PLANNING_CV
  sd_plan   <- cv_plan * posterior_mean
  n_alone   <- ceiling((sd_plan / se_target)^2)
  need      <- 1 / se_target^2 - 1 / PRIOR_SD_MEAN^2
  n_prior   <- if (need <= 0) 0L else ceiling(sd_plan^2 * need)

  cat(sprintf("\n── Missed the target. What would reach it? ──\n"))
  cat(sprintf("  planning CV                  %.2f%s\n", cv_plan,
              if (is.na(PLANNING_CV)) " (derived, within-meadow)" else " (PLANNING_CV)"))
  cat(sprintf("  target SE                    %.2f Mg C/ha\n", se_target))
  cat(sprintf("  cores needed, no prior       %3d\n", n_alone))
  cat(sprintf("  cores needed, prior helping  %3d   (saves %d)\n",
              n_prior, n_alone - n_prior))
  cat(sprintf("  you have                     %3d\n", nrow(core_totals)))
  cat("\n  Before adding cores, work down the ladder in Part 2 Step 4:\n")
  cat("  a looser margin, or a tighter prior, is cheaper than a field season.\n")
} else {
  cat("\n  Target met — no further cores needed for this question.\n")
}

# ── 6. The picture ───────────────────────────────────────────────────────────
library(ggplot2)

curves <- data.frame(
  what = factor(c("1. Prior (sites like yours)", "2. Evidence (your cores)",
                  "3. Posterior (combined)"),
                levels = c("1. Prior (sites like yours)", "2. Evidence (your cores)",
                           "3. Posterior (combined)")),
  mean = c(PRIOR_MEAN, evidence_mean, posterior_mean),
  sd   = c(PRIOR_SD_MEAN, evidence_sd, posterior_sd))

xs <- seq(max(0, min(curves$mean - 3.5 * curves$sd)),
          max(curves$mean + 3.5 * curves$sd), length.out = 400)
dens <- do.call(rbind, lapply(seq_len(nrow(curves)), function(i)
  data.frame(what = curves$what[i], x = xs,
             y = dnorm(xs, curves$mean[i], curves$sd[i]))))
band <- posterior_mean * c(1 - TARGET_MARGIN, 1 + TARGET_MARGIN)

p_update <- ggplot(dens, aes(x, y, colour = what, fill = what)) +
  annotate("rect", xmin = band[1], xmax = band[2], ymin = 0, ymax = Inf,
           fill = "#4daf4a", alpha = 0.12) +
  geom_area(alpha = 0.15, position = "identity") +
  geom_line(aes(linetype = what), linewidth = 1) +
  scale_colour_manual(values = c("#999999", "#377eb8", "#4daf4a")) +
  scale_fill_manual(values   = c("#999999", "#377eb8", "#4daf4a")) +
  scale_linetype_manual(values = c("solid", "solid", "22"), guide = "none") +
  # the curves are the SD-based shape; the target band and the PASS/FAIL above
  # use the t multiplier, which is why a curve can look inside the band and
  # still fail

  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_blank(), legend.position = "top",
        legend.title = element_blank()) +
  labs(
    title = "What your cores did to the estimate",
    subtitle = sprintf(
      paste0("prior %.1f ± %.1f   evidence %.1f ± %.1f (n = %d)   posterior %.1f ± %.1f\n",
             "prior weight %.0f%%   ·   green band = your ±%.0f%% target"),
      PRIOR_MEAN, PRIOR_SD_MEAN, evidence_mean, evidence_sd, nrow(core_totals),
      posterior_mean, posterior_sd, 100 * prior_weight, 100 * TARGET_MARGIN),
    x = sprintf("carbon stock 0-%d cm (Mg C/ha)", PRIMARY_DEPTH_CM), y = NULL)

dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(OUTPUT_DIR, "prior_to_posterior.png"), p_update,
       width = 8, height = 5, dpi = 150)
cat("\nsaved", file.path(OUTPUT_DIR, "prior_to_posterior.png"), "\n")
print(p_update)

posterior <- list(mean = posterior_mean, sd = posterior_sd,
                  prior_weight = prior_weight, passes = r_post$pass)
