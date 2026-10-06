# Shared foundation: units, slice stocks, checks, increments, compaction. Synthetic fixtures.

test_that("slice stock has the right units", {
  # 2 cm slice, BD 1.5 g/cm3, OC 1%: 1.5 * 0.01 * 2 = 0.03 g C/cm2 = 0.3 kg C/m2 = 3 Mg C/ha
  chk <- simple_chk(core_row("A"), slice_rows("A", c(0, 2)))
  s <- chk$slices
  expect_equal(s$bd_g_cm3, 1.5)
  expect_equal(s$stock_g_cm2, 0.03)
  expect_equal(s$stock_kg_m2, 0.3)
  inc <- increment_stocks(chk)
  expect_equal(sum(inc$stock_Mg_ha, na.rm = TRUE), 3)
})

test_that("LOI is converted with the stated equation; TC is refused; below-range LOI is flagged, not zero", {
  loi <- c(intercept = -0.2, slope = 0.4)
  s <- rbind(slice_rows("A", c(0, 2), oc = 3, type = "LOI"),
             slice_rows("A", c(2, 4), oc = 0.3, type = "LOI"),
             slice_rows("A", c(4, 6), oc = 1, type = "TC"))
  chk <- simple_chk(core_row("A"), s, loi = loi)
  expect_equal(chk$slices$oc_pct[1], -0.2 + 0.4 * 3)
  expect_true(is.na(chk$slices$oc_pct[2]))                       # -0.2 + 0.12 < 0
  expect_match(chk$slices$check[2], "below the range")
  expect_match(chk$slices$check[3], "TC is not organic carbon")
  expect_false(chk$cores$status == "Complete")
  # without an equation, LOI is never guessed
  chk2 <- simple_chk(core_row("A"), slice_rows("A", c(0, 2), oc = 3, type = "LOI"))
  expect_match(chk2$slices$check, "LOI conversion not set")
})

test_that("missing lab values, gaps, overlaps and duplicates are flagged and never become zero", {
  s <- slice_rows("A", c(0, 2, 4, 6))
  s$dry_g[2] <- NA
  chk <- simple_chk(core_row("A"), s)
  expect_match(chk$slices$check[2], "AWAITING LAB")
  expect_true(is.na(chk$slices$stock_g_cm2[2]))
  expect_equal(nrow(increment_stocks(chk)), 0)                   # incomplete core is not totalled

  gap <- simple_chk(core_row("A"), slice_rows("A", c(0, 2, 4))[c(1), ] |>
                      rbind(slice_rows("A", c(5, 7))))
  expect_match(gap$slices$check[2], "GAP")
  ov <- simple_chk(core_row("A"), rbind(slice_rows("A", c(0, 3)), slice_rows("A", c(2, 4))))
  expect_true(all(grepl("OVERLAP", ov$slices$check)))
  dup <- simple_chk(core_row("A"), rbind(slice_rows("A", c(0, 2)), slice_rows("A", c(0, 2))))
  expect_true(all(grepl("DUPLICATE", dup$slices$check)))
  for (x in list(gap, ov, dup)) expect_false(x$cores$status == "Complete")
})

test_that("core-level checks match the workbook's rules", {
  cores <- rbind(core_row("A", outside_cm = 50, inside_cm = NA, note = "assume none"),  # one depth only
                 core_row("B", outside_cm = 40, inside_cm = 45, note = NA),             # extracted > inserted
                 core_row("C", outside_cm = 60, inside_cm = 30, note = NA),             # 100% compaction
                 core_row("D", note = NA),                                               # nothing recorded
                 core_row("E"), core_row("E"))                                           # duplicate ID
  s <- do.call(rbind, lapply(c("A", "B", "C", "D", "E"), function(id) slice_rows(id, c(0, 2))))
  chk <- simple_chk(cores, s)
  st <- setNames(chk$cores$core_check, chk$cores$core_id)
  expect_equal(st[["A"]], "CHECK: one depth missing")
  expect_equal(st[["B"]], "CHECK: extracted > inserted")
  expect_equal(st[["C"]], "CHECK: >50% compaction")
  expect_equal(st[["D"]], "CHECK: compaction not recorded")
  expect_true(all(st[names(st) == "E"] == "CHECK: duplicate Core ID"))
  expect_false(any(chk$cores$status == "Complete"))
})

test_that("corer diameter: project value by default, a core's own value overrides, both blank is flagged", {
  cores <- rbind(core_row("A"), core_row("B", diameter_cm = 10))
  s <- rbind(slice_rows("A", c(0, 2), dia = 7), slice_rows("B", c(0, 2), dia = 10))
  chk <- simple_chk(cores, s, dia = 7)
  expect_equal(chk$cores$diameter_used_cm, c(7, 10))
  expect_equal(chk$cores$diameter_source, c("Instructions", "this core"))
  expect_equal(chk$slices$bd_g_cm3, c(1.5, 1.5))
  none <- simple_chk(core_row("A"), slice_rows("A", c(0, 2)), dia = NA)
  expect_equal(none$cores$core_check, "CHECK: corer diameter missing")
  expect_match(none$slices$check, "diameter missing")
})

test_that("a slice deeper than the recorded core length is flagged; a copied slice is a warning only", {
  chk <- simple_chk(core_row("A", outside_cm = 6, inside_cm = 4, note = NA), slice_rows("A", c(0, 2, 4, 6)))
  expect_match(chk$slices$check[3], "deeper than the core length")
  s <- slice_rows("A", c(0, 2, 4, 6), bd = c(1.4, 1.5, 1.5), oc = c(1, 0.8, 0.8))
  w <- simple_chk(core_row("A"), s)
  expect_true(is.na(w$slices$warning[2]))
  expect_match(w$slices$warning[3], "copied row")
  expect_equal(w$cores$status, "Complete")                       # a warning does not block
})

test_that("a slice crossing an increment boundary is split by overlap and carbon is conserved", {
  # Ported from the CommunityCarbonMap prototype's interval test: layers 0-10, 10-20, 20-25 cm
  # with carbon densities 10, 20, 40 mg C/cm3 -> 0-15 cm holds 10*10 + 20*5, 15-30 holds 20*5 + 40*5.
  dens <- c(10, 20, 40) / 1000                                    # g C/cm3
  s <- slice_rows("A", c(0, 10, 20, 25), bd = 1, oc = 100 * dens) # BD 1 so OC% = 100 * density
  chk <- simple_chk(core_row("A"), s)
  inc <- increment_stocks(chk)
  g <- setNames(inc$stock_g_cm2, inc$increment)
  expect_equal(g[["0–15 cm"]], (10 * 10 + 20 * 5) / 1000)
  expect_equal(g[["15–30 cm"]], (20 * 5 + 40 * 5) / 1000)
  expect_equal(inc$status, c("complete", "partial", "not reached", "not reached"))
  expect_silent(check_mass_conservation(chk, inc))
  # cumulative: 0-15 complete, 0-30 partial (no value), never a zero filled in
  cum <- cumulative_stocks(inc)
  expect_equal(cum$status, c("complete", "partial", "not reached", "not reached"))
  expect_true(all(is.na(cum$stock_Mg_ha[-1])))
  # tampering is caught
  bad <- inc; bad$stock_g_cm2[1] <- bad$stock_g_cm2[1] * 1.01
  expect_error(check_mass_conservation(chk, bad), "not conserved")
})

test_that("compaction moves slices to in-situ depth, is applied once, and conserves carbon", {
  s <- slice_rows("A", c(0, 4, 8), bd = 1.5, oc = 1)
  none <- simple_chk(core_row("A"), s)
  comp <- simple_chk(core_row("A", outside_cm = 10, inside_cm = 8, note = NA), s)   # factor 1.25
  expect_equal(comp$cores$compaction_factor, 1.25)
  expect_equal(comp$slices$insitu_bottom_cm, c(5, 10))
  expect_equal(comp$slices$stock_g_cm2, none$slices$stock_g_cm2)  # stock not multiplied by the factor
  inc <- increment_stocks(comp)
  expect_equal(sum(inc$stock_g_cm2, na.rm = TRUE), sum(none$slices$stock_g_cm2))
})

test_that("the Example workbook and R agree", {
  wbf <- file.path(ROOT, "..", "files", "Eelgrass_Carbon_DigitalData_Example.xlsx")
  skip_if_not(file.exists(wbf))
  chk <- check_slices(read_workbook(wbf))
  cc <- cross_check_workbook(chk)
  expect_true(all(cc$max_abs_difference[1:4] <= 1e-6))
  expect_true(all(cc$max_abs_difference[5:7] == 0))
  expect_true(all(chk$cores$status == "Complete"))
})
