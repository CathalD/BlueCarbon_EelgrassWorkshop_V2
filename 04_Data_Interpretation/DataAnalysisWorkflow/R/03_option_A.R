# 03_option_A.R — Option A: what do our samples tell us, and how do they compare?
# Uses measured slices only. Nothing is interpolated or modelled here.

haversine_m <- function(lat1, lon1, lat2, lon2) {
  r <- 6371000; p <- pi / 180
  a <- sin((lat2 - lat1) * p / 2)^2 + cos(lat1 * p) * cos(lat2 * p) * sin((lon2 - lon1) * p / 2)^2
  2 * r * asin(sqrt(pmin(1, a)))
}

#' The deepest standard depth every complete core fully reached (the default common basis).
common_depth <- function(cum) {
  ok <- cum[cum$status == "complete", ]
  if (!nrow(ok)) return(NA_real_)
  min(tapply(ok$depth_cm, ok$core_id, max))
}

#' Published reference cores, measured to `depth_cm`, on the same carbon definition.
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
#'     "oc_or_loi": also LOI slices, converted with YOUR workbook's LOI equation.
reference_stocks <- function(depth_cm, community_cores, loi, ref_dir = "data/reference",
                             states = NULL, exclude_estuaries = character(0),
                             exclude_within_m = 100, carbon = c("oc_measured", "oc_or_loi")) {
  carbon <- match.arg(carbon)
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
        <= exclude_within_m, na.rm = TRUE), logical(1))
  rc <- rc[!near, ]
  log["after_distance_exclusion"] <- nrow(rc)

  organic <- basis$StudyID[basis$carbon_c_is_organic == "yes"]
  rd <- rd[rd$SampID %in% rc$SampID & rd$BD_type %in% "M" & !rd$depth_approximate &
             !is.na(rd$depth_top_cm) & !is.na(rd$depth_bottom_cm) & !is.na(rd$BD), ]
  rd$oc_pct <- ifelse(rd$C_type %in% "M" & !is.na(rd$PercC) & rd$StudyID %in% organic, rd$PercC, NA_real_)
  if (carbon == "oc_or_loi") {
    li <- is.na(rd$oc_pct) & rd$OM_type %in% "M" & !is.na(rd$PercOM)
    rd$oc_pct[li] <- pmax(0, loi[["intercept"]] + loi[["slope"]] * rd$PercOM[li])
  }
  rd <- rd[!is.na(rd$oc_pct), ]

  rows <- lapply(split(rd, rd$SampID), function(x) {
    x <- x[order(x$depth_top_cm), ]
    reach <- 0
    for (i in seq_len(nrow(x))) if (x$depth_top_cm[i] <= reach + 1e-6) reach <- max(reach, x$depth_bottom_cm[i])
    if (reach < depth_cm - 1e-6) return(NULL)
    g <- sum(x$BD * x$oc_pct / 100 * overlap_cm(x$depth_top_cm, x$depth_bottom_cm, 0, depth_cm))
    data.frame(SampID = x$SampID[1], StudyID = x$StudyID[1], stock_Mg_ha = g * 100)
  })
  out <- do.call(rbind, rows)
  if (is.null(out)) out <- data.frame(SampID = integer(0), StudyID = integer(0), stock_Mg_ha = numeric(0))
  out <- merge(out, rc[, c("SampID", "State", "Estuary", "Lat", "Long")], by = "SampID")
  log["measured_to_depth_same_carbon_basis"] <- nrow(out)
  attr(out, "selection") <- log
  attr(out, "settings") <- list(depth_cm = depth_cm, states = states, exclude_estuaries = exclude_estuaries,
                                exclude_within_m = exclude_within_m, carbon = carbon)
  out
}

#' Where each of your cores sits in the reference distribution.
compare_to_reference <- function(cum, ref, depth_cm) {
  mine <- cum[cum$depth_cm == depth_cm & cum$status == "complete", c("core_id", "stock_Mg_ha")]
  if (!nrow(ref)) { mine$percentile <- NA_real_; return(mine) }
  Fn <- stats::ecdf(ref$stock_Mg_ha)
  mine$percentile <- round(100 * Fn(mine$stock_Mg_ha))
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

#' Measured profiles: organic carbon, bulk density and carbon density against in-situ depth.
plot_profiles <- function(chk) {
  s <- chk$slices[chk$slices$check == "OK", ]
  long <- rbind(
    data.frame(s[, c("core_id", "insitu_top_cm", "insitu_bottom_cm", "carbon_type")],
               variable = "Organic carbon (%)", value = s$oc_pct),
    data.frame(s[, c("core_id", "insitu_top_cm", "insitu_bottom_cm", "carbon_type")],
               variable = "Dry bulk density (g/cm³)", value = s$bd_g_cm3),
    data.frame(s[, c("core_id", "insitu_top_cm", "insitu_bottom_cm", "carbon_type")],
               variable = "Carbon density (mg C/cm³)", value = 1000 * s$stock_g_cm2 /
                 (s$insitu_bottom_cm - s$insitu_top_cm)))
  long$variable <- factor(long$variable, levels = unique(long$variable))
  long$basis <- ifelse(long$carbon_type == "LOI", "from LOI (converted)", "measured OC")
  ggplot(long) +
    geom_segment(aes(x = value, xend = value, y = insitu_top_cm, yend = insitu_bottom_cm,
                     colour = core_id), linewidth = 1.1) +
    geom_point(data = long[long$variable == "Organic carbon (%)", ],
               aes(x = value, y = (insitu_top_cm + insitu_bottom_cm) / 2, colour = core_id, shape = basis),
               size = 1.8) +
    scale_y_reverse() + scale_shape_manual(values = c("measured OC" = 16, "from LOI (converted)" = 1)) +
    facet_wrap(~variable, scales = "free_x") +
    labs(x = NULL, y = "Depth below sediment surface, in situ (cm)", colour = "Core", shape = "Carbon",
         title = "Measured profiles", subtitle = "Each bar is one slice. Measured values only.") +
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

#' Your cores against the reference distribution at the common depth.
plot_reference <- function(ref, cmp, depth_cm, region_label) {
  sel <- attr(ref, "selection")
  ggplot() +
    geom_boxplot(data = ref, aes(x = stock_Mg_ha, y = "Reference cores"), width = 0.4,
                 outlier.shape = NA, colour = "grey45") +
    geom_jitter(data = ref, aes(x = stock_Mg_ha, y = "Reference cores"), height = 0.12,
                width = 0, colour = "grey55", alpha = 0.7, size = 1.6) +
    geom_point(data = cmp, aes(x = stock_Mg_ha, y = "Your cores"), colour = "#B2182B", size = 3) +
    geom_text(data = cmp, aes(x = stock_Mg_ha, y = "Your cores", label = core_id),
              vjust = -1.1, size = 3.2) +
    labs(x = sprintf("Organic carbon stock, 0–%g cm (Mg C/ha)", depth_cm), y = NULL,
         title = sprintf("How your cores compare — 0–%g cm", depth_cm),
         subtitle = sprintf("Reference: %d Zostera marina cores from %d estuaries (%s), Janousek et al. (2025)",
                            nrow(ref), length(unique(ref$Estuary)), region_label)) +
    theme_bw(base_size = 11)
}

#' Where the measurements came from. A location map only — no values are mapped between points.
plot_locations <- function(chk, ref = NULL, boundary = NULL) {
  cores <- chk$cores
  p <- ggplot()
  if (!is.null(boundary))
    p <- p + geom_polygon(data = boundary, aes(x = longitude, y = latitude, group = 1),
                          fill = NA, colour = "grey30", linetype = "dashed")
  if (!is.null(ref) && nrow(ref))
    p <- p + geom_point(data = ref, aes(x = Long, y = Lat), colour = "grey60", size = 1.2)
  p + geom_point(data = cores, aes(x = longitude, y = latitude), colour = "#B2182B", size = 2.5) +
    geom_text(data = cores, aes(x = longitude, y = latitude, label = core_id), vjust = -1, size = 3) +
    coord_quickmap() + labs(x = "Longitude", y = "Latitude", title = "Core locations") +
    theme_bw(base_size = 11)
}
