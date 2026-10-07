# make_workshop_figures.R — composes the workshop's generated figures. Called by
# data-raw/render_screenshots.sh with the folder of raw screenshots as its argument; reads the
# analysis results in outputs/. Every number drawn here comes from those files.
suppressPackageStartupMessages({ library(magick); library(ggplot2) })
shots <- commandArgs(TRUE)[1]
img1 <- "../../01_Background/images"; img2 <- "../../02_Project_Planning/images"; img4 <- "../images"
CHROME <- Sys.getenv("CHROME", "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
INK <- "#1b1f23"; GREY <- "#57606a"; GREEN <- "#1f7a4d"; BLUE <- "#0f4c66"; RED <- "#b5402a"

shot <- function(f) image_trim(image_read(file.path(shots, f)))
strip <- function(text, width, size = 22, col = INK, weight = 700, h = 46, bg = "white")
  image_annotate(image_blank(width, h, bg), text, size = size, color = col, weight = weight,
                 gravity = "west", location = "+12+0", font = "Helvetica")
pad <- function(im, px = 16) image_border(im, "white", sprintf("%dx%d", px, px))
stack <- function(...) image_background(image_append(c(...), stack = TRUE), "white")
side <- function(...) image_background(image_append(c(...)), "white")
save <- function(im, path) { image_write(image_flatten(image_background(im, "white")), path, format = "png"); cat("wrote", path, "\n") }
gg_save <- function(p, path, w, h) { ggsave(path, p, width = w, height = h, dpi = 150, bg = "white"); cat("wrote", path, "\n") }

A <- readRDS("outputs/example/option_A/results.rds")
B <- readRDS("outputs/example/option_B/results.rds")

# ---- Part 4, Step 1.1: the paper sheet, digitized (constructed Tsawwassen core WWF-01-A) ---------
img3 <- "../../03_Field_Methods/images"
paper <- image_append(c(image_read(file.path(img3, "data_sheet_core_notes_section.png")),
                        image_read(file.path(img3, "data_sheet_sample_data_section.png"))), stack = TRUE)
tl <- shot("tsaw_log.png"); ts <- shot("tsaw_smp.png")
W <- max(image_info(tl)$width, image_info(ts)$width, 900) + 24
fig1b <- stack(
  strip("The paper sheet (Part 3) — constructed Tsawwassen teaching example, not real data", W, col = "#8a7a55"),
  pad(image_scale(paper, "820"), 12),
  strip("Typed into the digital data sheet: tab 2, one row per core", W, col = GREEN),
  pad(tl, 12),
  strip("Tab 3, one row per slice. The lab columns stay empty until results come back, so every slice says AWAITING LAB.", W, size = 17, col = GREEN),
  pad(ts, 12))
save(fig1b, file.path(img4, "fig1b_paper_sheet_to_workbook.png"))

# ---- Part 4, figure 2: one lab row becomes one workbook row ------------------------------------
lab <- shot("lab.png"); wb <- shot("wb.png")
W <- max(image_info(lab)$width, image_info(wb)$width) + 24
fig2 <- stack(
  strip("Mock lab results sheet (\"Example Lab\" is not real) — sample COW-S5-01", W),
  pad(lab, 12),
  strip("Below: the same slice in the digital data sheet, tab 3. Sample Data", W, col = GREEN),
  pad(wb, 12),
  strip("1 ID  ·  2 depths, 0–1 cm  ·  3 dry mass, reconstructed from the published bulk density  ·  4 organic carbon, measured (%)  ·  5 so the type is OC",
        W, size = 17, col = GREY, weight = 400))
save(fig2, file.path(img4, "fig2_lab_row_to_workbook_row.png"))

# ---- Part 4, figure 3: a check catches a typo -------------------------------------------------
ok <- shot("check_ok.png"); bad <- shot("check_bad.png")
W <- max(image_info(ok)$width, image_info(bad)$width) + 24
fig3 <- stack(
  strip("1 · As typed: slice 3 starts at 1.5 cm instead of 2.0 cm", W, col = RED),
  pad(bad, 12),
  strip("Slices 2 and 3 now overlap, so both are flagged, and COW-S5 drops out of the totals until it is fixed.", W, size = 17, col = GREY, weight = 400),
  strip("2 · Corrected: 2.0 cm — every slice says OK, and the core is totalled again", W, col = GREEN),
  pad(ok, 12))
save(fig3, file.path(img4, "fig3_check_and_correction.png"))

# ---- Part 4, figure 4: slices -> a depth stock (COW-S5) ---------------------------------------
s <- A$chk$slices[A$chk$slices$core_id == "COW-S5", ]
s$dens <- 1000 * s$stock_g_cm2 / (s$insitu_bottom_cm - s$insitu_top_cm)
cur <- B$curves[B$curves$core_id == "COW-S5" & B$curves$cell_top_cm >= 20 & B$curves$cell_bottom_cm <= 30, ]
est_dens <- 1000 * mean(cur$estimated_g_cm2)
ci <- B$cinc[B$cinc$core_id == "COW-S5", ]
m15 <- ci$measured_Mg_ha[ci$increment == "0–15 cm"]
m30 <- ci$measured_Mg_ha[ci$increment == "15–30 cm"]; e30 <- ci$estimated_Mg_ha[ci$increment == "15–30 cm"]
s$part <- ifelse(s$insitu_bottom_cm <= 15, "0–15 cm, measured", "15–20 cm, measured")
fig4 <- ggplot() +
  geom_rect(data = s, aes(xmin = 0, xmax = dens, ymin = insitu_top_cm, ymax = insitu_bottom_cm, fill = part),
            colour = "white", linewidth = 0.3) +
  geom_rect(aes(xmin = 0, xmax = est_dens, ymin = 20, ymax = 30, fill = "20–30 cm, estimated (scenario)"),
            colour = BLUE, linetype = "22", linewidth = 0.4) +
  geom_hline(yintercept = c(15, 30), colour = GREY, linetype = "dashed", linewidth = 0.4) +
  geom_hline(yintercept = 20, colour = INK, linewidth = 0.6) +
  annotate("text", x = max(s$dens) * 1.04, y = 7.5, hjust = 0, size = 3.6, colour = GREEN,
           label = sprintf("0–15 cm stock\n%.1f Mg C/ha\nall measured", m15)) +
  annotate("text", x = max(s$dens) * 1.04, y = 22.5, hjust = 0, size = 3.6, colour = BLUE,
           label = sprintf("15–30 cm\n%.1f measured + %.1f estimated\n= %.1f Mg C/ha (scenario only)", m30, e30, m30 + e30)) +
  annotate("text", x = 0.3, y = 20, vjust = -0.5, hjust = 0, size = 3.2, label = "base of the core, 20 cm") +
  scale_y_reverse(breaks = c(0, 5, 10, 15, 20, 25, 30), expand = c(0, 0.3)) +
  scale_x_continuous(limits = c(0, max(s$dens) * 1.9), expand = c(0, 0)) +
  scale_fill_manual(values = c("0–15 cm, measured" = "#2E7D32", "15–20 cm, measured" = "#81C784",
                               "20–30 cm, estimated (scenario)" = "#C5CAE9")) +
  labs(x = "Carbon density (mg C/cm³)", y = "Depth below the sediment surface (cm)", fill = NULL,
       title = "From slices to a depth stock — Cowichan core COW-S5",
       subtitle = "Each bar is one measured slice. Published values (Douglas et al. 2022)") +
  theme_bw(base_size = 11) + theme(legend.position = "bottom")
gg_save(fig4, file.path(img4, "fig4_slice_to_depth_stock.png"), 8, 5.6)

# ---- Part 4, figure 5: Option A and Option B outputs ------------------------------------------
file.copy("outputs/example/option_A/comparison.png", file.path(img4, "fig5a_option_A_comparison.png"), overwrite = TRUE)
res <- B$res; sc <- B$scenario$res
card <- ggplot() + xlim(0, 1) + ylim(0, 1) + theme_void() +
  annotate("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1, fill = "#e8f3ec", colour = GREEN) +
  annotate("text", x = 0.05, y = 0.9, hjust = 0, size = 4.2, fontface = "bold", colour = RED,
           label = sprintf("HYPOTHETICAL AREA · %.1f ha", res$area_ha)) +
  annotate("text", x = 0.05, y = 0.76, hjust = 0, size = 3.8, colour = GREY, label = sprintf("Sediment organic carbon, 0–%g cm — measured", B$settings$REPORT_DEPTH_CM)) +
  annotate("text", x = 0.05, y = 0.58, hjust = 0, size = 9, fontface = "bold", colour = INK, label = sprintf("%.1f Mg C/ha", res$mean_Mg_ha)) +
  annotate("text", x = 0.05, y = 0.42, hjust = 0, size = 6, colour = INK, label = sprintf("≈ %s Mg C in total", format(round(res$total_Mg_C), big.mark = ","))) +
  annotate("text", x = 0.05, y = 0.27, hjust = 0, size = 3.6, colour = INK,
           label = "Exploratory design: cores not placed at random,\nso no confidence interval") +
  annotate("text", x = 0.05, y = 0.1, hjust = 0, size = 3.4, colour = BLUE,
           label = sprintf("Deeper scenario, 0–%g cm: %.1f Mg C/ha, %.0f%% estimated", B$settings$SCENARIO_DEPTH_CM, sc$mean_Mg_ha, sc$pct_estimated))
cf <- file.path(shots, "card.png"); gg_save(card, cf, 5.2, 3.2)
map <- image_scale(image_read("outputs/example/option_B/area_map.png"), "x780")
bar <- image_scale(image_read("outputs/example/option_B/measured_estimated_share.png"), "780x")
right <- stack(image_scale(image_read(cf), "780x"), bar)
save(side(pad(map, 8), pad(right, 8)), file.path(img4, "fig5b_option_B_result.png"))

# ---- Part 4, figure 6 and workflow previews: the reports --------------------------------------
rb <- image_read(file.path(shots, "report_B.png")); ra <- image_read(file.path(shots, "report_A.png"))
save(image_border(image_crop(rb, "1000x1500+0+0"), "#d0d7de", "2x2"), file.path(img4, "fig6_report_option_B.png"))
save(image_border(image_scale(image_crop(ra, "1000x1100+0+0"), "640x"), "#d0d7de", "2x2"), file.path(img4, "report_preview_option_A.png"))
save(image_border(image_scale(image_crop(rb, "1000x1100+0+0"), "640x"), "#d0d7de", "2x2"), file.path(img4, "report_preview_option_B.png"))

# ---- landing-page result cards ----------------------------------------------------------------
ref <- A$refs[[1]]; me <- A$cmp[A$cmp$core_id == "COW-S5", ]
pc <- me[[grep("^percentile_", names(me))[1]]]
cardA <- ggplot(ref, aes(x = stock_Mg_ha, y = 0)) +
  geom_point(position = position_jitter(height = 0.25, width = 0, seed = 1), colour = "grey60", size = 1.8, alpha = 0.7) +
  geom_vline(xintercept = me$stock_Mg_ha, colour = RED, linewidth = 1.1) +
  annotate("text", x = me$stock_Mg_ha, y = 0.46, label = "COW-S5", colour = RED, size = 3.4, fontface = "bold") +
  scale_y_continuous(limits = c(-0.5, 0.55), breaks = NULL) +
  labs(x = sprintf("Organic carbon stock, 0–%g cm (Mg C/ha)", A$D), y = NULL,
       title = "A · One core, compared",
       subtitle = sprintf("COW-S5 holds %.1f Mg C/ha in the top %g cm: higher than %g%% of %d published\neelgrass cores from %s (grey). Published data, Cowichan Estuary, BC.",
                          me$stock_Mg_ha, A$D, pc, nrow(ref), A$region)) +
  theme_bw(base_size = 11) + theme(plot.subtitle = element_text(size = 9, colour = GREY))
gg_save(cardA, file.path(img1, "result_card_compare.png"), 5.4, 3.3)
cardB <- card + annotate("text", x = 0.95, y = 0.9, hjust = 1, size = 4.2, fontface = "bold", colour = GREEN, label = "B · An area")
gg_save(cardB, file.path(img1, "result_card_area.png"), 5.4, 3.3)

# ---- Part 2: calculator screenshots ----------------------------------------------------------
save(pad(shot("calc_strat.png"), 10), file.path(img2, "calculator_tsawwassen_stratified.png"))
save(pad(shot("calc_check.png"), 10), file.path(img2, "calculator_precision_check.png"))

# ---- Part 2, Step 1: the boundary and its measured area, from the user's tool screenshot -------
z <- image_read(file.path(img2, "tsawwassen_strata_zones.png"))
left <- image_crop(z, "545x195+0+0"); mapz <- image_crop(z, "626x693+552+0")
left <- image_draw(left); rect(2, 168, 300, 190, border = RED, lwd = 3); dev.off()
save(side(pad(left, 6), pad(mapz, 6)), file.path(img2, "tsawwassen_step1_boundary.png"))

# ---- Workflow README: the few settings a participant changes ----------------------------------
lines <- c('<span class="c">1</span>PROJECT &lt;- list(title = "…", question_A = "…", question_B = "…", …)',
           '<span class="c">2</span>WORKBOOK &lt;- "my_data/my_eelgrass_carbon.xlsx"',
           '<span class="c">3</span>REFERENCE_EXCLUDE_ESTUARIES &lt;- character(0)  <span class="k"># your estuary\'s code, if it is in the reference data</span>',
           '<span class="c">4</span>DESIGN &lt;- "exploratory"        <span class="k"># or "srs", "stratified"</span>',
           '<span class="c">5</span>BOUNDARY_FILE &lt;- "my_data/boundary.csv"   <span class="k"># NULL until you have one</span>',
           '<span class="c">6</span>STRATUM_AREAS_M2 &lt;- NULL        <span class="k"># e.g. c(high = 7138000, low = 3619500)</span>',
           '<span class="c">7</span>REPORT_DEPTH_CM &lt;- NULL         <span class="k"># NULL = deepest depth every core measured</span>')
html <- paste0('<!doctype html><meta charset="utf-8"><style>body{margin:0;padding:16px;background:#fff;font:15px Menlo,monospace;color:#1b1f23}',
  '.t{font:bold 15px Helvetica,Arial,sans-serif;margin-bottom:10px}.k{color:#57606a}',
  '.c{display:inline-block;background:#b5402a;color:#fff;border-radius:50%;width:20px;height:20px;text-align:center;',
  'font:bold 12px/20px Arial,sans-serif;margin-right:10px}pre{margin:0;line-height:1.9}</style>',
  '<div class="t">settings.R — the only file you edit</div><pre>', paste(lines, collapse = "\n"), '</pre>')
hf <- file.path(shots, "settings.html"); writeLines(html, hf)
system2(CHROME, c("--headless=new", "--disable-gpu", "--hide-scrollbars", "--window-size=1100,400",
                  paste0("--screenshot=", file.path(shots, "settings.png")), paste0("file://", hf)), stderr = FALSE)
save(pad(image_trim(image_read(file.path(shots, "settings.png"))), 10), file.path(img4, "settings_preview.png"))
