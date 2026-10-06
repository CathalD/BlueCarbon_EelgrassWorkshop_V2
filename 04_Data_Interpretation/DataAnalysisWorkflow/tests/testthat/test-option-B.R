# Option B: carbon curves, sampling units, designs. Synthetic fixtures.

# nls() cannot fit noise-free data (see ?nls), so the synthetic profiles carry a little
# deterministic scatter, as real cores do.
wiggle <- function(n) 1 + 0.04 * sin(seq_len(n) * 2.3)
decaying_core <- function(id, plot = id, stratum = NA, base = 30, floor = 0.4, excess = 1.2, scale = 8) {
  edges <- c(seq(0, 10, 2), seq(15, base, 5))
  mid <- (head(edges, -1) + edges[-1]) / 2
  list(core = core_row(id, plot_id = plot, stratum = stratum),
       slices = slice_rows(id, edges, bd = 1.4, oc = (floor + excess * exp(-mid / scale)) * wiggle(length(mid))))
}
chk_of <- function(...) {
  x <- list(...)
  simple_chk(do.call(rbind, lapply(x, `[[`, "core")), do.call(rbind, lapply(x, `[[`, "slices")))
}

test_that("step-fill reproduces the measured stock exactly, and estimates are kept separate", {
  chk <- chk_of(decaying_core("A"))
  cur <- carbon_curves(chk)
  expect_equal(sum(cur$measured_g_cm2), sum(chk$slices$stock_g_cm2), tolerance = 1e-12)
  expect_true(all(cur$estimated_g_cm2[cur$cell_bottom_cm <= 30] == 0))
  expect_true(all(cur$measured_g_cm2[cur$cell_top_cm >= 30] == 0))
  expect_equal(attr(cur, "methods")$extrapolation, "this core's decay curve")
})

test_that("per-increment % estimated is reported", {
  chk <- chk_of(decaying_core("A", base = 20))
  inc <- curve_increments(carbon_curves(chk))
  p <- setNames(inc$pct_estimated, inc$increment)
  expect_equal(p[["0–15 cm"]], 0)
  expect_true(p[["15–30 cm"]] > 0 && p[["15–30 cm"]] < 100)
  expect_equal(p[["30–50 cm"]], 100)
  st <- curve_stocks(carbon_curves(chk))
  expect_equal(st$measured_Mg_ha[st$depth_cm == 100], sum(chk$slices$stock_g_cm2) * 100)
})

test_that("a decay curve is accepted only if it decays; otherwise the fallbacks are used and named", {
  d <- seq(1, 29, 2)
  decay <- (0.004 + 0.01 * exp(-d / 8)) * wiggle(length(d))
  expect_s3_class(fit_decay(d, decay, 1), "nls")
  expect_equal(fit_decay(d[1:3], decay[1:3], 1), "too few slices")
  rising <- (0.012 - 0.008 * exp(-d / 8)) * wiggle(length(d))
  expect_false(is_fit(fit_decay(d, rising, 1)))
  expect_equal(fit_decay(d, decay, max_allowed = 0.001), "floor above the highest measured value")
  # a flat core falls back to the constant, and says so
  flat <- list(core = core_row("F"), slices = slice_rows("F", seq(0, 20, 2), oc = 0.6))
  m <- attr(carbon_curves(chk_of(flat)), "methods")
  expect_match(m$extrapolation, "constant")
  expect_true(nzchar(m$why_not_core_curve))
})

test_that("cores sharing a plot are averaged into one unit; mixed strata in a plot are an error", {
  st <- data.frame(core_id = c("A1", "A2", "B"), plot_id = c("A", "A", "B"), stratum = "s", depth_cm = 30,
                   measured_Mg_ha = c(10, 20, 40), estimated_Mg_ha = 0, stock_Mg_ha = c(10, 20, 40))
  u <- unit_values(st, 30)
  expect_equal(u$stock_Mg_ha, c(15, 40))
  expect_equal(u$n_cores, c(2L, 1L))
  st$stratum[2] <- "t"
  expect_error(unit_values(st, 30), "different")
  st$stratum[2] <- NA
  expect_error(unit_values(st, 30), "different")
})

units_of <- function(v, strata = NA) data.frame(unit_id = seq_along(v), stratum = strata,
                                                n_cores = 1L, measured_Mg_ha = v, estimated_Mg_ha = 0,
                                                stock_Mg_ha = v)

test_that("exploratory designs give no interval", {
  r <- estimate_area(units_of(c(20, 30, 40)), "exploratory", area_m2 = 50000)
  expect_null(r$ci_Mg_ha)
  expect_equal(r$mean_Mg_ha, 30); expect_equal(r$total_Mg_C, 30 * 5)
  expect_match(r$notes, "Exploratory")
})

test_that("simple random sampling uses a t-interval with the finite-population correction", {
  v <- c(20, 30, 40, 25)
  r <- estimate_area(units_of(v), "srs", area_m2 = 2000, plot_area_m2 = 100, conf = 0.90)
  N <- 20; n <- 4
  se <- sqrt((1 - n / N) * var(v) / n)
  expect_equal(r$se_Mg_ha, se)
  expect_equal(r$ci_Mg_ha, mean(v) + c(-1, 1) * qt(0.95, 3) * se)
  expect_error(estimate_area(units_of(v), "srs", area_m2 = 300, plot_area_m2 = 100), "cannot fit")
})

test_that("stratified estimate weights strata by area (hand calculation and survey agree)", {
  u <- units_of(c(10, 14, 12, 40, 50, 46), strata = rep(c("small", "big"), each = 3))
  areas <- c(small = 1000, big = 9000)
  r <- estimate_area(u, "stratified", strata_areas_m2 = areas, plot_area_m2 = 100)
  W <- c(0.1, 0.9); m <- c(mean(c(10, 14, 12)), mean(c(40, 50, 46)))
  expect_equal(r$mean_Mg_ha, sum(W * m))                       # not the plain mean of 6 units
  expect_false(isTRUE(all.equal(r$mean_Mg_ha, mean(u$stock_Mg_ha))))
  Nh <- c(10, 90); s2 <- c(var(c(10, 14, 12)), var(c(40, 50, 46)))
  expect_equal(r$se_Mg_ha, sqrt(sum(W^2 * (1 - 3 / Nh) * s2 / 3)))
  expect_equal(r$total_Mg_C, r$mean_Mg_ha * 1)
})

test_that("an unsampled stratum is excluded and reported; a one-unit stratum gives a point estimate only", {
  u <- units_of(c(10, 14, 40, 50), strata = c("a", "a", "b", "b"))
  r <- estimate_area(u, "stratified", strata_areas_m2 = c(a = 5000, b = 5000, c = 2000))
  expect_equal(r$area_ha, 1); expect_equal(r$excluded_area_ha, 0.2)
  expect_true(any(grepl("Unsampled strata excluded: c", r$notes)))
  one <- estimate_area(units_of(c(10, 14, 40), strata = c("a", "a", "b")), "stratified",
                       strata_areas_m2 = c(a = 5000, b = 5000))
  expect_null(one$ci_Mg_ha)
  expect_true(any(grepl("only one sampling unit", one$notes)))
  expect_error(estimate_area(units_of(c(1, 2), strata = c("a", "z")), "stratified",
                             strata_areas_m2 = c(a = 5000)), "not listed")
})

test_that("boundary helpers", {
  sq <- data.frame(longitude = c(0, 0.001, 0.001, 0), latitude = c(0, 0, 0.001, 0.001))
  expect_equal(polygon_area_m2(sq$longitude, sq$latitude), (0.001 * pi / 180 * 6371008.8)^2, tolerance = 1e-6)
  expect_equal(point_in_polygon(c(0.0005, 0.002), c(0.0005, 0.0005), sq$longitude, sq$latitude), c(TRUE, FALSE))
})
