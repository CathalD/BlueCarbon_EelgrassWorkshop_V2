# 03_option_A.R — Option A: what do our samples tell us, and how do they compare?
# Uses measured slices only. Nothing is interpolated or modelled here.

haversine_m <- function(lat1, lon1, lat2, lon2) {
  r <- 6371000; p <- pi / 180
  a <- sin((lat2 - lat1) * p / 2)^2 + cos(lat1 * p) * cos(lat2 * p) * sin((lon2 - lon1) * p / 2)^2
  2 * r * asin(sqrt(pmin(1, a)))
}

#' The deepest standard depth every complete core fully reached (the default common basis).
#' Cores that reached no standard depth are named in a message, not dropped silently.
common_depth <- function(cum) {
  if (!nrow(cum)) return(NA_real_)
  ok <- cum[cum$status == "complete", ]
  short <- setdiff(unique(cum$core_id), unique(ok$core_id))
  if (length(short))
    message("Not deep enough for any standard depth (15 cm), so not in the comparison: ",
            paste(short, collapse = ", "))
  if (!nrow(ok)) return(NA_real_)
  min(tapply(ok$depth_cm, ok$core_id, max))
}

#' Published reference cores, measured to `depth_cm`, on one carbon definition.
#'
#' Matching rules (all reported):
#'   * Zostera marina only (the reference files hold nothing else);
#'   * region: State/Province in `states` (NULL = all);
#'   * exclusions: estuaries in `exclude_estuaries`, AND any reference core within
#'     `exclude_within_m` of one of your cores — so a practice core drawn from the
#'     synthesis can never be compared with itself;
#'   * only slices the synthesis marks as measured (not extrapolated, interpolated or
#'     modelled) and with exact depths; the core must be measured continuously to depth_cm;
#'   * carbon = "oc_measured": elemental carbon only from studies documented to remove
#'     inorganic carbon (data/reference/study_carbon_basis.csv);
#'     "oc_or_loi": as above, plus LOI slices converted with YOUR workbook's LOI equation
#'     (a slice whose LOI is below the equation's range is left out, not set to zero).
#' Returns one row per reference core; attr "slices" holds the slices used.
reference_stocks <- function(depth_cm, community_cores, loi, ref_dir = "data/reference",
                             states = NULL, exclude_estuaries = character(0),
                             exclude_within_m = 100, carbon = c("oc_measured", "oc_or_loi")) {
  carbon <- match.arg(carbon)
  if (carbon == "oc_or_loi" && any(is.na(loi)))
    stop("The LOI-converted reference set needs the LOI equation on the workbook's Instructions tab.")
  if (exclude_within_m > 0 && any(is.na(community_cores$latitude) | is.na(community_cores$longitude)))
    stop("Some of your cores have no latitude/longitude (", paste(community_cores$core_id[
      is.na(community_cores$latitude) | is.na(community_cores$longitude)], collapse = ", "),
      "), so the ", exclude_within_m, " m exclusion cannot be checked. Add coordinates on Sheet 2.")
  rc <- utils::read.csv(file.path(ref_dir, "janousek2025_zostera_cores.csv"), stringsAsFactors = FALSE)
  rd <- utils::read.csv(file.path(ref_dir, "janousek2025_zostera_depthseries.csv"), stringsAsFactors = FALSE)
  basis <- utils::read.csv(file.path(ref_dir, "study_carbon_basis.csv"), stringsAsFactors = FALSE)
  log <- c(start = nrow(rc))

  if (!is.null(states)) rc <- rc[rc$State %in% states, ]
  log["in_region"] <- nrow(rc)
  rc <- rc[!rc$Estuary %in% exclude_estuaries, ]
  log["after_estuary_exclusion"] <- nrow(rc)
  near <- vapply(seq_len(nrow(rc)), function(i)
    any(haversine_m(rc$Lat[i], rc$Long[i], community_cores$latitude, community_cores$longitude)
        <= exclude_within_m), logical(1))
  rc <- rc[!near, ]
  log["after_distance_exclusion"] <- nrow(rc)

  organic <- basis$StudyID[basis$carbon_c_is_organic == "yes"]
  rd <- rd[rd$SampID %in% rc$SampID & rd$BD_type %in% "M" & !rd$depth_approximate &
             !is.na(rd$depth_top_cm) & !is.na(rd$depth_bottom_cm) & !is.na(rd$BD), ]
  rd$oc_pct <- ifelse(rd$C_type %in% "M" & !is.na(rd$PercC) & rd$StudyID %in% organic, rd$PercC, NA_real_)
  rd$carbon_basis <- ifelse(is.na(rd$oc_pct), NA_character_, "measured OC")
  below <- 0L
  if (carbon == "oc_or_loi") {
    li <- is.na(rd$oc_pct) & rd$OM_type %in% "M" & !is.na(rd$PercOM)
    conv <- loi_to_oc(rd$PercOM[li], loi)
    below <- sum(conv < 0)
    rd$oc_pct[li] <- ifelse(conv < 0, NA_real_, conv)
    rd$carbon_basis[li] <- ifelse(conv < 0, NA_character_, "converted from LOI")
  }
  rd <- rd[!is.na(rd$oc_pct), ]

  rows <- lapply(split(rd, rd$SampID), function(x) {
    x <- x[order(x$depth_top_cm), ]
    reach <- 0
    for (i in seq_len(nrow(x))) if (x$depth_top_cm[i] <= reach + 1e-6) reach <- max(reach, x$depth_bottom_cm[i])
    if (reach < depth_cm - 1e-6) return(NULL)
    w <- overlap_cm(x$depth_top_cm, x$depth_bottom_cm, 0, depth_cm)
    g <- sum(x$BD * x$oc_pct / 100 * w)
    data.frame(SampID = x$SampID[1], StudyID = x$StudyID[1], stock_Mg_ha = g * 100,
               share_from_LOI = sum(w[x$carbon_basis == "converted from LOI"]) / sum(w))
  })
  out <- do.call(rbind, rows)
  if (is.null(out)) out <- data.frame(SampID = integer(0), StudyID = integer(0), stock_Mg_ha = numeric(0),
                                      share_from_LOI = numeric(0))
  out <- merge(out, rc[, c("SampID", "State", "Estuary", "Lat", "Long")], by = "SampID")
  log["measured_to_depth_same_carbon_basis"] <- nrow(out)
  attr(out, "selection") <- log
  attr(out, "loi_slices_below_equation_range") <- below
  attr(out, "slices") <- rd[rd$SampID %in% out$SampID, c("SampID", "StudyID", "depth_top_cm",
                                                        "depth_bottom_cm", "BD", "oc_pct", "carbon_basis")]
  attr(out, "settings") <- list(depth_cm = depth_cm, states = states, exclude_estuaries = exclude_estuaries,
                                exclude_within_m = exclude_within_m, carbon = carbon)
  out
}

#' Both reference sets, so they can be shown side by side.
reference_sets <- function(depth_cm, community_cores, loi, ...) {
  list(oc_or_loi = reference_stocks(depth_cm, community_cores, loi, carbon = "oc_or_loi", ...),
       oc_measured = reference_stocks(depth_cm, community_cores, loi, carbon = "oc_measured", ...))
}

REFERENCE_LABELS <- c(oc_or_loi   = "Measured OC + LOI converted with your equation",
                      oc_measured = "Measured OC only (studies that removed inorganic carbon)")

#' Where each of your cores sits in the reference distribution. Cores that did not reach the
#' comparison depth are listed with a note rather than left out.
compare_to_reference <- function(cum, ref, depth_cm) {
  ids <- unique(cum$core_id)
  mine <- cum[cum$depth_cm == depth_cm, c("core_id", "stock_Mg_ha", "status")]
  mine <- mine[match(ids, mine$core_id), ]
  mine$core_id <- ids
  mine$note <- ifelse(mine$status %in% "complete", "", sprintf("did not reach %g cm", depth_cm))
  Fn <- if (nrow(ref)) stats::ecdf(ref$stock_Mg_ha) else NULL
  mine$percentile <- if (is.null(Fn)) NA_real_ else
    ifelse(mine$status %in% "complete", round(100 * Fn(mine$stock_Mg_ha)), NA_real_)
  mine$status <- NULL
  rownames(mine) <- NULL
  mine
}

reference_summary <- function(ref) {
  q <- if (nrow(ref)) stats::quantile(ref$stock_Mg_ha, c(0, .25, .5, .75, 1)) else rep(NA, 5)
  data.frame(n_cores = nrow(ref), n_estuaries = length(unique(ref$Estuary)),
             n_studies = length(unique(ref$StudyID)),
             min = q[1], lower_quartile = q[2], median = q[3], upper_quartile = q[4], max = q[5],
             row.names = NULL)
}

# ---------------------------------------------------------------------------- figures
library(ggplot2)

CORE_COLOUR <- "#B2182B"

#' Measured profiles: organic carbon, bulk density and carbon density against in-situ depth.
#' With `ref_slices`, the reference cores' median, 25–75% and 10–90% ranges are drawn behind
#' your cores, in 5 cm depth bins (bins with fewer than 5 reference cores are left out).
plot_profiles <- function(chk, ref_slices = NULL, bin_cm = 5) {
  s <- chk$slices[chk$slices$check == "OK", ]
  vars <- c("Organic carbon (%)", "Dry bulk density (g/cm³)", "Carbon density (mg C/cm³)")
  long <- rbind(
    data.frame(s[, c("core_id", "insitu_top_cm", "insitu_bottom_cm", "carbon_type")],
               variable = vars[1], value = s$oc_pct),
    data.frame(s[, c("core_id", "insitu_top_cm", "insitu_bottom_cm", "carbon_type")],
               variable = vars[2], value = s$bd_g_cm3),
    data.frame(s[, c("core_id", "insitu_top_cm", "insitu_bottom_cm", "carbon_type")],
               variable = vars[3], value = 1000 * s$stock_g_cm2 /
                 (s$insitu_bottom_cm - s$insitu_top_cm)))
  long$variable <- factor(long$variable, levels = vars)
  long$basis <- ifelse(long$carbon_type == "LOI", "from LOI (converted)", "measured OC")
  p <- ggplot(long)
  if (!is.null(ref_slices) && nrow(ref_slices)) {
    bottom <- bin_cm * ceiling(max(long$insitu_bottom_cm, na.rm = TRUE) / bin_cm)
    r <- ref_slices
    r$mid <- (r$depth_top_cm + r$depth_bottom_cm) / 2
    r <- r[r$mid < bottom, ]
    r$bin <- floor(r$mid / bin_cm) * bin_cm + bin_cm / 2
    rl <- rbind(data.frame(SampID = r$SampID, bin = r$bin, variable = vars[1], value = r$oc_pct),
                data.frame(SampID = r$SampID, bin = r$bin, variable = vars[2], value = r$BD),
                data.frame(SampID = r$SampID, bin = r$bin, variable = vars[3], value = 10 * r$BD * r$oc_pct))
    q <- do.call(rbind, lapply(split(rl, list(rl$variable, rl$bin), drop = TRUE), function(z)
      data.frame(variable = z$variable[1], bin = z$bin[1], n = length(unique(z$SampID)),
                 q10 = stats::quantile(z$value, .1), q25 = stats::quantile(z$value, .25),
                 q50 = stats::median(z$value), q75 = stats::quantile(z$value, .75),
                 q90 = stats::quantile(z$value, .9))))
    q <- q[q$n >= 5, ]
    q$variable <- factor(q$variable, levels = vars)
    q <- q[order(q$variable, q$bin), ]
    p <- p +
      geom_ribbon(data = q, aes(y = bin, xmin = q10, xmax = q90), fill = "grey90", orientation = "y") +
      geom_ribbon(data = q, aes(y = bin, xmin = q25, xmax = q75), fill = "grey75", orientation = "y") +
      geom_path(data = q, aes(x = q50, y = bin), colour = "grey35")
  }
  p + geom_segment(aes(x = value, xend = value, y = insitu_top_cm, yend = insitu_bottom_cm,
                       colour = core_id), linewidth = 1.1) +
    geom_point(data = long[long$variable == vars[1], ],
               aes(x = value, y = (insitu_top_cm + insitu_bottom_cm) / 2, colour = core_id, shape = basis),
               size = 1.8) +
    scale_y_reverse() + scale_shape_manual(values = c("measured OC" = 16, "from LOI (converted)" = 1)) +
    facet_wrap(~variable, scales = "free_x") +
    labs(x = NULL, y = "Depth below sediment surface, in situ (cm)", colour = "Core", shape = "Carbon",
         title = "Measured profiles",
         subtitle = paste0("Each bar is one slice. Measured values only.",
                           if (!is.null(ref_slices)) " Grey: reference cores' median, 25–75% and 10–90%." else ""),
         caption = if (!is.null(ref_slices)) "Reference cores: Janousek et al. (2025), same selection as the comparison." else NULL) +
    theme_bw(base_size = 11)
}

#' Stock in each standard increment, per core (complete increments only).
plot_increments <- function(inc) {
  d <- inc[inc$status == "complete", ]
  ggplot(d, aes(x = increment, y = stock_Mg_ha, fill = core_id)) +
    geom_col(position = position_dodge(width = 0.8), width = 0.7) +
    labs(x = "Depth increment", y = "Organic carbon stock (Mg C/ha)", fill = "Core",
         title = "Stock by depth increment",
         subtitle = "Only increments the core fully reached. Partial increments are not shown.") +
    theme_bw(base_size = 11)
}

#' Your cores against the reference distributions at the common depth (one panel per carbon basis).
plot_reference <- function(refs, cmp, depth_cm, region_label) {
  lab <- vapply(names(refs), function(k) sprintf("%s — %d cores, %d estuaries", REFERENCE_LABELS[[k]],
                nrow(refs[[k]]), length(unique(refs[[k]]$Estuary))), "")
  d <- do.call(rbind, lapply(names(refs), function(k)
    if (nrow(refs[[k]])) data.frame(set = lab[[k]], stock_Mg_ha = refs[[k]]$stock_Mg_ha) else NULL))
  d$set <- factor(d$set, levels = lab)
  mine <- cmp[!is.na(cmp$stock_Mg_ha) & cmp$note == "", ]
  ggplot() +
    geom_boxplot(data = d, aes(x = stock_Mg_ha, y = 0), width = 0.5, outlier.shape = NA, colour = "grey45") +
    geom_jitter(data = d, aes(x = stock_Mg_ha, y = 0), height = 0.15, width = 0,
                colour = "grey55", alpha = 0.6, size = 1.4) +
    geom_vline(data = mine, aes(xintercept = stock_Mg_ha, colour = core_id), linewidth = 0.9) +
    facet_wrap(~set, ncol = 1) +
    scale_y_continuous(breaks = NULL, limits = c(-0.45, 0.45)) +
    labs(x = sprintf("Organic carbon stock, 0–%g cm (Mg C/ha)", depth_cm), y = NULL, colour = "Your cores",
         title = sprintf("How your cores compare — 0–%g cm", depth_cm),
         subtitle = sprintf("Grey: Zostera marina cores from %s (Janousek et al. 2025). Coloured lines: your cores.",
                            region_label)) +
    theme_bw(base_size = 11) + theme(strip.text = element_text(hjust = 0))
}

#' Bulk density against organic carbon: your slices over the reference slices. A slice far from
#' the cloud is worth re-checking — a wrong corer diameter or a subsample mass against a
#' whole-slice volume both show up here first.
plot_bd_vs_oc <- function(chk, ref_slices) {
  s <- chk$slices[chk$slices$check == "OK" & chk$slices$oc_pct > 0, ]
  ref_slices <- ref_slices[ref_slices$oc_pct > 0, ]   # a log scale cannot show zero
  ggplot() +
    geom_point(data = ref_slices, aes(x = oc_pct, y = BD), colour = "grey65", size = 0.8, alpha = 0.5) +
    geom_point(data = s, aes(x = oc_pct, y = bd_g_cm3, colour = core_id), size = 2) +
    scale_x_log10() +
    labs(x = "Organic carbon (% of dry mass, log scale)", y = "Dry bulk density (g/cm³)", colour = "Core",
         title = "A quick check: bulk density against organic carbon",
         subtitle = "Grey: reference slices. Your slices should sit in or near the grey cloud.") +
    theme_bw(base_size = 11)
}

#' Where the measurements came from. A location map only — no values are mapped between points.
plot_locations <- function(chk, boundary = NULL) {
  cores <- chk$cores
  p <- ggplot()
  if (!is.null(boundary))
    p <- p + geom_polygon(data = boundary, aes(x = longitude, y = latitude, group = 1),
                          fill = NA, colour = "grey30", linetype = "dashed")
  p + geom_point(data = cores, aes(x = longitude, y = latitude), colour = CORE_COLOUR, size = 2.5) +
    geom_text(data = cores, aes(x = longitude, y = latitude, label = core_id), vjust = -1, size = 3) +
    coord_quickmap() + labs(x = "Longitude", y = "Latitude", title = "Core locations") +
    theme_bw(base_size = 11)
}

#' Where the reference cores came from, relative to yours (one point per core).
plot_reference_map <- function(chk, ref) {
  ggplot() +
    geom_point(data = ref, aes(x = Long, y = Lat, colour = Estuary), size = 1.6, alpha = 0.8) +
    geom_point(data = chk$cores, aes(x = longitude, y = latitude), shape = 4, size = 3, stroke = 1.2,
               colour = CORE_COLOUR) +
    coord_quickmap() +
    labs(x = "Longitude", y = "Latitude", colour = "Reference estuary",
         title = "Where the reference cores come from", subtitle = "Red cross: your cores.") +
    theme_bw(base_size = 11)
}
