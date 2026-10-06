# Reference selection (Option A) and module 4. Uses the real open reference files, plus synthetic values.

REF_DIR <- file.path(ROOT, "data", "reference")
loi <- c(intercept = -0.197, slope = 0.320)

test_that("a practice core taken from the reference set is never compared with itself", {
  rc <- read.csv(file.path(REF_DIR, "janousek2025_zostera_cores.csv"))
  base <- reference_stocks(15, data.frame(core_id = "far", latitude = 0, longitude = 0), loi, REF_DIR,
                           carbon = "oc_or_loi")
  target <- base[1, ]
  me <- data.frame(core_id = "practice", latitude = target$Lat, longitude = target$Long)
  r <- reference_stocks(15, me, loi, REF_DIR, carbon = "oc_or_loi")          # no estuary exclusion
  expect_false(target$SampID %in% r$SampID)                                   # 100 m rule removes it
  r2 <- reference_stocks(15, me, loi, REF_DIR, exclude_estuaries = target$Estuary, exclude_within_m = 0,
                         carbon = "oc_or_loi")
  expect_false(any(r2$Estuary == target$Estuary))
  expect_error(reference_stocks(15, data.frame(core_id = "x", latitude = NA, longitude = 1), loi, REF_DIR),
               "no latitude/longitude")
})

test_that("reference stocks use measured slices only, and LOI below the equation's range is left out", {
  far <- data.frame(core_id = "far", latitude = 0, longitude = 0)
  strict <- reference_stocks(15, far, loi, REF_DIR, carbon = "oc_measured")
  conv <- reference_stocks(15, far, loi, REF_DIR, carbon = "oc_or_loi")
  expect_true(nrow(conv) > nrow(strict))
  expect_true(all(strict$share_from_LOI == 0))
  expect_true(all(conv$stock_Mg_ha > 0))
  sl <- attr(conv, "slices")
  expect_false(any(is.na(sl$oc_pct)))
  harsh <- reference_stocks(15, far, c(intercept = -2, slope = 0.3), REF_DIR, carbon = "oc_or_loi")
  expect_true(attr(harsh, "loi_slices_below_equation_range") > 0)
  expect_true(all(attr(harsh, "slices")$oc_pct >= 0))
})

test_that("without an LOI equation, Option A still compares on measured organic carbon", {
  far <- data.frame(core_id = "far", latitude = 0, longitude = 0)
  expect_message(refs <- reference_sets(15, far, c(intercept = NA, slope = NA), ref_dir = REF_DIR),
                 "only the measured")
  expect_equal(names(refs), "oc_measured")
  expect_true(nrow(refs$oc_measured) > 0)
  expect_message(h <- headline_first(refs, "oc_or_loi"), "not available")
  expect_equal(names(h)[1], "oc_measured")
  both <- reference_sets(15, far, loi, ref_dir = REF_DIR)
  expect_equal(names(headline_first(both, "oc_measured")), c("oc_measured", "oc_or_loi"))
})

# ---- module 4 ----------------------------------------------------------------
syn_ref <- function() {
  set.seed(1)
  mu <- c(A = 2, B = 2.5, C = 1.8, D = 2.3)
  do.call(rbind, lapply(names(mu), function(e)
    data.frame(Estuary = e, stock_Mg_ha = exp(rnorm(6, mu[[e]], 0.3)))))
}

test_that("the normal update matches a hand calculation", {
  pr <- list(m0 = 2, tau2 = 0.25, sigma2 = 0.09, var_m0 = 0.01)
  y <- c(12, 15, 9)
  up <- update_estuary_mean(pr, y)
  v0 <- 0.26; prec <- 1 / v0 + 3 / 0.09
  expect_equal(up$var_log, 1 / prec)
  expect_equal(up$mean_log, (2 / v0 + sum(log(y)) / 0.09) / prec)
  expect_equal(up$prior_weight, (1 / v0) / prec)
  am <- arithmetic_mean(up$mean_log, up$var_log, pr$sigma2, 0.9)
  expect_equal(am$low_Mg_ha, exp(qnorm(0.05, up$mean_log, sqrt(up$var_log)) + 0.045))
})

test_that("the prior needs enough estuaries, and leave-one-estuary-out never uses the held-out estuary", {
  ref <- syn_ref()
  expect_error(regional_prior(ref[ref$Estuary %in% c("A", "B"), ]), "at least 3")
  d <- loeo_check(ref, ks = c(0, 3), reps = 5)
  k0 <- d[d$k == 0 & d$estuary == "B", ]
  expect_equal(k0$truth, mean(ref$stock_Mg_ha[ref$Estuary == "B"]))
  pr <- regional_prior(ref[ref$Estuary != "B", ])
  expected <- arithmetic_mean(pr$m0, pr$tau2 + pr$var_m0, pr$sigma2, 0.9)$estimate_Mg_ha
  expect_equal(k0$comb_error, abs(expected - k0$truth))
  # if B were (wrongly) left in its own prior, the answer would differ
  pr_leaky <- regional_prior(ref)
  expect_false(isTRUE(all.equal(pr_leaky$m0, pr$m0)))
})

test_that("decompose_variance recovers a simple between/within split", {
  v <- decompose_variance(c(1, 1, 3, 3), c("a", "a", "b", "b"))
  expect_equal(v$sd_within, 0)
  expect_equal(v$icc, 1)
})
