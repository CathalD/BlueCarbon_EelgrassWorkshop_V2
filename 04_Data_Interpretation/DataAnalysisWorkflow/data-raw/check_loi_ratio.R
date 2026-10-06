# check_loi_ratio.R — maintainer check, quoted in Part 4 and the Going further README.
# How does "organic carbon = organic matter (LOI) x 0.5" compare with measured organic carbon in
# eelgrass sediments? Uses only slices in the reference files where BOTH were measured, from
# studies documented to remove inorganic carbon (data/reference/study_carbon_basis.csv).
#   Rscript data-raw/check_loi_ratio.R      (from DataAnalysisWorkflow/)

d <- utils::read.csv("data/reference/janousek2025_zostera_depthseries.csv")
b <- utils::read.csv("data/reference/study_carbon_basis.csv")
p <- d[d$OM_type %in% "M" & d$C_type %in% "M" & !is.na(d$PercOM) & !is.na(d$PercC) & d$PercOM > 0 &
         d$StudyID %in% b$StudyID[b$carbon_c_is_organic == "yes"], ]
ratio <- p$PercC / p$PercOM
cat(sprintf("Paired slices: %d, from %d cores in %d studies\n", nrow(p), length(unique(p$SampID)),
            length(unique(p$StudyID))))
cat(sprintf("Measured OC / LOI: median %.2f (middle half %.2f–%.2f)\n",
            stats::median(ratio), stats::quantile(ratio, .25), stats::quantile(ratio, .75)))
cat(sprintf("LOI x 0.5 is, at the median, %.1f times the measured organic carbon\n",
            stats::median(0.5 / ratio)))
fit <- stats::lm(PercC ~ PercOM, data = p)
cat(sprintf("Linear fit across these studies: OC%% = %.3f + %.3f x LOI%% (r2 = %.2f)\n",
            stats::coef(fit)[1], stats::coef(fit)[2], summary(fit)$r.squared))
print(table(Study = p$StudyID))
