# make_datasheet_figures.R — the field data sheet figures: the Part 3 section crops, the blank and
# filled pages, and Part 4 figure 1. Everything is cut from the two PDFs in
# 03_Field_Methods/datasheets/, which are exported from the workshop's Google Doc; nothing is typed
# in here except the drawn bag label, which copies row 1 of the filled sheet. Called by
# data-raw/render_screenshots.sh; needs pdftoppm (poppler) and R magick. Run from DataAnalysisWorkflow/.
suppressPackageStartupMessages(library(magick))
ds <- "../../03_Field_Methods/datasheets"; img3 <- "../../03_Field_Methods/images"; img4 <- "../images"
INK <- "#1b1f23"; GREY <- "#57606a"; BLUE <- "#0f4c66"; RED <- "#b5402a"; SAND <- "#8a7a55"
save <- function(im, path) { image_write(image_flatten(image_background(im, "white")), path, format = "png"); cat("wrote", path, "\n") }
strip <- function(text, width, size = 22, col = INK, weight = 700, h = 46, bg = "white")
  image_annotate(image_blank(width, h, bg), text, size = size, color = col, weight = weight,
                 gravity = "west", location = "+12+0", font = "Helvetica")
stack <- function(...) image_background(image_append(c(...), stack = TRUE), "white")
side <- function(...) image_background(image_append(c(...)), "white")

tmp <- tempfile(); dir.create(tmp)
page1 <- function(pdf, stem) {
  system2("pdftoppm", c("-r", "200", "-png", "-f", "1", "-l", "1", shQuote(pdf), file.path(tmp, stem)))
  image_read(Sys.glob(file.path(tmp, paste0(stem, "-*.png")))[1])
}
blank <- page1(file.path(ds, "Eelgrass_Carbon_Datasheet_v2.pdf"), "blank")
ex <- page1(file.path(ds, "Eelgrass_Carbon_Datasheet_Example.pdf"), "example")

# Table borders on page 1 at 200 dpi (US letter, 1700 x 2200 px), measured from the export:
# title 141-216, Step 1 268-718, Step 2 768-1080, Step 3 1130-2002 (slice rows start at 1260,
# row 1 ends at 1363, row 6 at 1875); the tables span x 102-1608. Re-measure if the Doc's layout changes.
X0 <- 88; WD <- 1534
cut <- function(im, y0, y1) image_crop(im, sprintf("%dx%d+%d+%d", WD, y1 - y0, X0, y0))
box <- function(im, x0, y0, x1, y1) { im <- image_draw(im); rect(x0, y0, x1, y1, border = RED, lwd = 6); dev.off(); im }
small <- function(im, w = 1100) image_scale(im, as.character(w))

# ---- Part 3: one crop per "Record it on the data sheet" box -----------------------------------
plot_notes <- cut(ex, 128, 732)
core_notes <- box(cut(ex, 754, 1094), 14, 70, 1520, 223)        # Core ID, diameter, latitude, longitude
compaction <- box(cut(ex, 754, 1094), 14, 223, 1520, 326)       # depth inserted, length extracted
samples <- cut(ex, 1116, 1875)
save(small(plot_notes), file.path(img3, "data_sheet_plot_notes_section.png"))
save(small(core_notes), file.path(img3, "data_sheet_core_notes_section.png"))
save(small(compaction), file.path(img3, "data_sheet_compaction_measurement_fields.png"))
save(small(samples), file.path(img3, "data_sheet_sample_data_section.png"))
whole <- function(im) image_border(image_scale(image_crop(im, "1534x1890+88+120"), "1000"), "#d0d7de", "2x2")
save(whole(blank), file.path(img3, "blank_field_data_sheet.png"))
save(whole(ex), file.path(img3, "filled_in_field_data_sheet_from_the_project_planning_example.png"))

# ---- Part 4, figure 1: what arrives from the field --------------------------------------------
sheet <- box(cut(ex, 754, 1875), 14, 1260 - 754, 1520, 1363 - 754)   # Step 2 + Step 3, slice 1 boxed
sheet <- image_scale(sheet, "900")
H <- image_info(sheet)$height
bag <- image_draw(image_blank(440, H, "white"))
polygon(c(40, 400, 400, 40), c(70, 70, H - 40, H - 40), col = "#f4f7f9", border = "#8c959f", lwd = 3)
segments(40, 112, 400, 112, col = "#4a90c2", lwd = 5); segments(40, 124, 400, 124, col = "#4a90c2", lwd = 3)
rect(80, 190, 360, 470, col = "white", border = RED, lwd = 5)
dev.off()
lab <- c("WWF-01-A" = 46, "Sample 1" = 36, "0–5 cm" = 36, "2026-06-16" = 30)
y <- 210
for (t in names(lab)) {
  bag <- image_annotate(bag, t, size = lab[[t]], color = INK, weight = if (t == "WWF-01-A") 700 else 400,
                        font = "Helvetica", gravity = "northwest", location = sprintf("+%d+%d", 100, y))
  y <- y + lab[[t]] + 26
}
bag <- image_annotate(bag, "Drawn label (illustration)", size = 20, color = GREY, font = "Helvetica",
                      gravity = "northwest", location = sprintf("+%d+%d", 100, 485))
bag <- image_annotate(bag, "Same Core ID, Sample ID", size = 20, color = RED, weight = 700, font = "Helvetica",
                      gravity = "northwest", location = sprintf("+%d+%d", 60, H - 120))
bag <- image_annotate(bag, "and depths as the boxed row", size = 20, color = RED, weight = 700, font = "Helvetica",
                      gravity = "northwest", location = sprintf("+%d+%d", 60, H - 92))
W <- 900 + 440
fig1 <- stack(
  strip("What arrives from the field: a paper sheet and a cooler of labelled bags", W),
  strip("Constructed Tsawwassen teaching example from Parts 2 and 3. Not real data.", W, size = 19, col = SAND, weight = 400, h = 34),
  side(sheet, bag),
  image_blank(W, 14, "white"),
  strip("From Step 2 the analysis switches to three published Cowichan cores (Douglas et al. 2022).", W, size = 19, col = BLUE, h = 34),
  strip("They have no paper sheet of their own and did not come from this core.", W, size = 19, col = BLUE, weight = 400, h = 34))
save(image_border(fig1, "white", "12x12"), file.path(img4, "fig1_what_arrives.png"))
unlink(tmp, recursive = TRUE)
