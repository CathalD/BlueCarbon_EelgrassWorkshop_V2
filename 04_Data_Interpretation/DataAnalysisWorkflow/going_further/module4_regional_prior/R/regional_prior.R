# regional_prior.R — Going further, module 4: borrow strength from published cores.
#
# The idea, in one line: before you core, published eelgrass cores from other estuaries already
# say roughly what a meadow's average carbon stock is likely to be; your own cores then move
# that expectation towards your meadow. With few cores, the combination is usually closer to
# the truth than your cores alone — and with many cores, your cores dominate.
#
# Model (all on the log scale, where stocks are close to normal):
#   log(stock of core j in estuary e) = mu_e + e_j,    e_j ~ N(0, sigma2)   cores within an estuary
#   mu_e = m0 + a_e,                                    a_e ~ N(0, tau2)     estuaries differ
# m0, tau2 and sigma2 come from the reference cores (method of moments, as in
# advanced/02_derive_prior.R); your estuary's mu_e is then updated exactly with your cores
# (normal–normal; Gelman et al. 2013, Bayesian Data Analysis, §2.5).
# The quantity reported is the ARITHMETIC mean stock of your meadow, exp(mu_e + sigma2/2), so
# it can be compared with Options A and B.
#
# Assumptions, stated: your sampling units behave like a random draw from your meadow; your
# meadow behaves like one more estuary from the reference set; sigma2 and tau2 are taken as
# known (their own uncertainty is not carried). It is a model-based estimate, not a
# design-based one — it is reported alongside Option B, never instead of it.

#' One-way random-effects variance decomposition by method of moments (Searle, Casella &
#' McCulloch 1992, ch. 3). Reused from advanced/02_derive_prior.R, unchanged.
decompose_variance <- function(values, groups) {
  ok <- is.finite(values) & !is.na(groups)
  values <- values[ok]; groups <- as.character(groups[ok])
  k <- length(unique(groups)); N <- length(values)
  if (k < 2) return(NULL)
  n_i <- as.numeric(table(groups))
  gm  <- mean(values); gmi <- tapply(values, groups, mean)
  ms_between <- sum(n_i * (gmi - gm)^2) / (k - 1)
  ms_within  <- sum((values - gmi[groups])^2) / (N - k)
  n0 <- (N - sum(n_i^2) / N) / (k - 1)
  var_between <- max(0, (ms_between - ms_within) / n0)
  list(n_cores = N, n_estuaries = k, grand_mean = gm,
       sd_between = sqrt(var_between), sd_within = sqrt(ms_within),
       sd_total = stats::sd(values), icc = var_between / (var_between + ms_within))
}

#' The regional prior from reference cores (one row per core: stock_Mg_ha, Estuary).
regional_prior <- function(ref, min_estuaries = 3) {
  if (any(ref$stock_Mg_ha <= 0)) stop("Reference stocks must be positive to work on the log scale.")
  y <- log(ref$stock_Mg_ha); g <- ref$Estuary
  k <- length(unique(g))
  if (k < min_estuaries)
    stop(sprintf("Only %d reference estuar%s at this depth; at least %d are needed to say how much estuaries differ. ",
                 k, if (k == 1) "y" else "ies", min_estuaries),
         "Try a shallower depth or a wider region.")
  v <- decompose_variance(y, g)
  if (v$sd_between == 0)
    stop("The reference estuaries do not differ more than their cores do (between-estuary variance estimated as 0), ",
         "so the prior would claim more certainty than it has. Not used.")
  n_i <- as.numeric(table(g))
  est_means <- tapply(y, g, mean)
  m0 <- mean(est_means)                                  # each estuary counts once
  var_m0 <- (v$sd_between^2 + v$sd_within^2 * mean(1 / n_i)) / k
  list(m0 = m0, tau2 = v$sd_between^2, sigma2 = v$sd_within^2, var_m0 = var_m0,
       n_cores = length(y), n_estuaries = k, icc = v$icc,
       estuary_means = data.frame(Estuary = names(est_means), n = as.integer(table(g)[names(est_means)]),
                                  mean_Mg_ha = as.numeric(tapply(ref$stock_Mg_ha, g, mean)[names(est_means)]),
                                  row.names = NULL))
}

#' Exact normal update of your estuary's log-scale mean with your sampling units' stocks.
update_estuary_mean <- function(prior, stocks) {
  v0 <- prior$tau2 + prior$var_m0                        # prior variance of a new estuary's mean
  y <- log(stocks); n <- length(y)
  prec <- 1 / v0 + n / prior$sigma2
  list(mean_log = (prior$m0 / v0 + sum(y) / prior$sigma2) / prec, var_log = 1 / prec,
       prior_weight = (1 / v0) / prec, n = n)
}

#' Arithmetic mean stock exp(mu + sigma2/2) — point (posterior mean) and interval. The
#' transformation is monotone in mu, so its quantiles are exact; no simulation is needed.
arithmetic_mean <- function(mean_log, var_log, sigma2, conf = 0.90) {
  a <- (1 - conf) / 2
  data.frame(estimate_Mg_ha = exp(mean_log + var_log / 2 + sigma2 / 2),
             low_Mg_ha = exp(stats::qnorm(a, mean_log, sqrt(var_log)) + sigma2 / 2),
             high_Mg_ha = exp(stats::qnorm(1 - a, mean_log, sqrt(var_log)) + sigma2 / 2))
}

#' Your sampling units on their own: mean and t-interval (none with fewer than 2 units).
local_only <- function(stocks, conf = 0.90) {
  n <- length(stocks); m <- mean(stocks)
  if (n < 2) return(data.frame(estimate_Mg_ha = m, low_Mg_ha = NA_real_, high_Mg_ha = NA_real_))
  h <- stats::qt(1 - (1 - conf) / 2, n - 1) * stats::sd(stocks) / sqrt(n)
  data.frame(estimate_Mg_ha = m, low_Mg_ha = m - h, high_Mg_ha = m + h)
}

#' Prior, your cores alone, and the two combined — one row each.
borrow_strength <- function(ref, stocks, conf = 0.90, min_estuaries = 3) {
  pr <- regional_prior(ref, min_estuaries)
  up <- update_estuary_mean(pr, stocks)
  rbind(cbind(source = "Published cores only (before your cores)",
              arithmetic_mean(pr$m0, pr$tau2 + pr$var_m0, pr$sigma2, conf), weight_of_prior = 1),
        cbind(source = "Your cores only", local_only(stocks, conf), weight_of_prior = 0),
        cbind(source = "Combined", arithmetic_mean(up$mean_log, up$var_log, pr$sigma2, conf),
              weight_of_prior = up$prior_weight))
}

#' Leave-one-estuary-out check, on the reference cores only. Each estuary in turn plays "your
#' meadow": the prior is rebuilt WITHOUT it, k of its cores are drawn at random, and the
#' estimate is compared with the mean of that estuary's cores that were not drawn (k = 0: all
#' of them). Repeated `reps` times per estuary and k. This shows whether the prior's intervals
#' are honest and how quickly local cores take over — on real data, not on an assumption.
loeo_check <- function(ref, ks = c(0, 1, 3, 5), reps = 200, conf = 0.90, min_estuaries = 3, seed = 2026) {
  set.seed(seed)
  out <- list()
  for (e in unique(ref$Estuary)) {
    own <- ref$stock_Mg_ha[ref$Estuary == e]
    others <- ref[ref$Estuary != e, ]
    if (length(unique(others$Estuary)) < min_estuaries) next
    pr <- tryCatch(regional_prior(others, min_estuaries), error = function(err) NULL)
    if (is.null(pr)) next
    for (k in ks) {
      if (length(own) < k + 2 && k > 0) next             # need >= 2 unseen cores to compare with
      for (r in seq_len(if (k == 0) 1 else reps)) {
        pick <- if (k == 0) integer(0) else sample.int(length(own), k)
        truth <- mean(if (k == 0) own else own[-pick])
        comb <- if (k == 0) arithmetic_mean(pr$m0, pr$tau2 + pr$var_m0, pr$sigma2, conf) else {
          up <- update_estuary_mean(pr, own[pick]); arithmetic_mean(up$mean_log, up$var_log, pr$sigma2, conf) }
        loc <- if (k == 0) NULL else local_only(own[pick], conf)
        out[[length(out) + 1]] <- data.frame(
          estuary = e, k = k, rep = r, truth = truth,
          comb_error = abs(comb$estimate_Mg_ha - truth),
          comb_covered = truth >= comb$low_Mg_ha & truth <= comb$high_Mg_ha,
          local_error = if (is.null(loc)) NA_real_ else abs(loc$estimate_Mg_ha - truth),
          local_covered = if (is.null(loc) || is.na(loc$low_Mg_ha)) NA else
            truth >= loc$low_Mg_ha & truth <= loc$high_Mg_ha)
      }
    }
  }
  d <- do.call(rbind, out)
  if (is.null(d)) stop("Too few reference estuaries for the leave-one-estuary-out check.")
  attr(d, "conf") <- conf
  d
}

#' Summary of the check: one row per k. Estuaries count equally (their replicates are averaged first).
summarise_loeo <- function(d) {
  per_est <- stats::aggregate(cbind(comb_error, comb_covered, local_error, local_covered) ~ estuary + k,
                              data = transform(d, comb_covered = as.numeric(comb_covered),
                                               local_covered = as.numeric(local_covered)),
                              FUN = mean, na.action = stats::na.pass)
  do.call(rbind, lapply(split(per_est, per_est$k), function(z) data.frame(
    k = z$k[1], estuaries = nrow(z),
    combined_mean_abs_error = mean(z$comb_error), combined_coverage = mean(z$comb_covered),
    local_mean_abs_error = if (all(is.na(z$local_error))) NA_real_ else mean(z$local_error, na.rm = TRUE),
    local_coverage = if (all(is.na(z$local_covered))) NA_real_ else mean(z$local_covered, na.rm = TRUE))))
}

# ---------------------------------------------------------------------------- figures
plot_borrow <- function(tab, units, depth_cm, conf) {
  tab$source <- factor(tab$source, levels = rev(tab$source))
  ggplot(tab, aes(y = source, x = estimate_Mg_ha)) +
    geom_errorbar(aes(xmin = low_Mg_ha, xmax = high_Mg_ha), width = 0.2, orientation = "y", na.rm = TRUE) +
    geom_point(size = 3) +
    geom_point(data = data.frame(x = units$stock_Mg_ha, source = factor("Your cores only", levels = levels(tab$source))),
               aes(x = x, y = source), colour = "#B2182B", shape = 1, size = 2.5, inherit.aes = FALSE) +
    labs(x = sprintf("Mean organic carbon stock, 0–%g cm (Mg C/ha)", depth_cm), y = NULL,
         title = "What published cores add to your own",
         subtitle = sprintf("Points: estimate; bars: %g%% interval. Open red circles: your sampling units.", 100 * conf)) +
    theme_bw(base_size = 11)
}

plot_prior_estuaries <- function(ref, prior, depth_cm) {
  em <- prior$estuary_means[order(prior$estuary_means$mean_Mg_ha), ]
  ref$Estuary <- factor(ref$Estuary, levels = em$Estuary)
  centre <- exp(prior$m0 + prior$sigma2 / 2)
  ggplot(ref, aes(y = Estuary, x = stock_Mg_ha)) +
    geom_vline(xintercept = centre, colour = "#2E8B57") +
    geom_point(colour = "grey35", alpha = 0.6) +
    stat_summary(fun = mean, geom = "point", colour = "#E76F51", size = 3, shape = 18) +
    labs(x = sprintf("Organic carbon stock, 0–%g cm (Mg C/ha)", depth_cm), y = "Reference estuary",
         title = "The published cores behind the prior",
         subtitle = "Grey: cores. Orange: estuary means — their spread is what makes the prior wide.\nGreen: the prior's centre.") +
    theme_bw(base_size = 11)
}

plot_loeo <- function(summary_tab) {
  d <- rbind(data.frame(k = summary_tab$k, method = "Combined", mae = summary_tab$combined_mean_abs_error),
             data.frame(k = summary_tab$k, method = "Local cores only", mae = summary_tab$local_mean_abs_error))
  d <- d[!is.na(d$mae), ]
  ggplot(d, aes(x = k, y = mae, colour = method)) + geom_line() + geom_point(size = 2) +
    scale_x_continuous(breaks = summary_tab$k) +
    scale_colour_manual(values = c("Combined" = "#2E8B57", "Local cores only" = "#B2182B")) +
    labs(x = "Cores taken in the held-out estuary", y = "Average error (Mg C/ha)", colour = NULL,
         title = "Checked on the reference estuaries themselves",
         subtitle = "Each estuary in turn plays 'your meadow', with the prior rebuilt without it.") +
    theme_bw(base_size = 11)
}
