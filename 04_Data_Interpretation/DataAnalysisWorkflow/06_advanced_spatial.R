# 06_advanced_spatial.R
# ─────────────────────────────────────────────────────────────────────────────
#   PLACEHOLDER — NOT PART OF THE WORKFLOW YET. Nothing below runs by default.
# ─────────────────────────────────────────────────────────────────────────────
#
# Everything up to step 05 answers "how much carbon is here, and how sure are
# we?" That is one number for the meadow, with an interval. This step is about
# a different question:
#
#       WHERE is the carbon, and can we predict it somewhere we did not core?
#
# That is a map, and a map needs far more than six cores. The material below is
# kept because it works and because the teaching point is good — but it is
# parked until the workflow is ready to support it honestly.
#
# ── WHAT GOES HERE, LATER ────────────────────────────────────────────────────
#
#   1. KRIGING (the code below, ready to use)
#      Ordinary kriging uses only WHERE a core is. Regression kriging also uses
#      WHAT THE PLACE IS LIKE — water depth, distance to shore, eelgrass
#      density. The teaching point is that the model only knows what you give
#      it: an informative covariate sharpens the map, an uninformative one does
#      nothing.
#
#   2. RANDOM FOREST ON REMOTE-SENSING PRODUCTS
#      Sentinel-2 bands and indices, bathymetry, a mapped eelgrass extent
#      layer — extracted at the core locations with terra::extract(), fitted
#      with ranger or randomForest, predicted across the meadow. This is the
#      route to a real map, and it is how the Community Carbon Map workflow
#      builds one.
#
# ── WHY IT IS PARKED, AND WHAT HAS TO BE TRUE FIRST ──────────────────────────
#
#   Three things have to be fixed before any map here should be shown to
#   anyone. They are all visible in the worked example:
#
#   a) ENOUGH CORES. An empirical variogram is not identifiable below roughly
#      30 point-pairs. At n = 6 the range, sill and nugget are not estimated
#      so much as invented.
#
#   b) COVARIATES THAT ARE NOT JUST THE STRATUM RELABELLED. In the worked
#      example all three salt-marsh cores sit at 0.40-0.50 m water depth and
#      all three eelgrass cores at 1.6-2.2 m, so every covariate separates the
#      strata perfectly. `stratum` alone explains R² = 0.958 of core stock;
#      the three-covariate trend model reaches R² = 0.993 on 2 residual
#      degrees of freedom. That is not a model, it is a restatement.
#
#   c) A NEGATIVE CONTROL. The lesson "an uninformative covariate cannot help"
#      needs a covariate that genuinely carries no information, so the reader
#      can see it fail. Every covariate currently offered is informative, so
#      the lesson has nothing to land on.
#
#   Until (a)-(c) hold, step 04 is the deliverable: an area-weighted estimate
#   with an honest interval, which six cores CAN support.
#
# ── TO PICK THIS UP ──────────────────────────────────────────────────────────
#   The previous working kriging implementation is preserved intact at
#   draft/kriging_reference.R. It needs sf, gstat and sp — and terra plus
#   ranger for the random-forest route.
#
#   RK_COVARIATES in 00_config.R still lists the covariates it expects.

stop("06_advanced_spatial.R is a placeholder and is not ready to run. ",
     "See the notes at the top of the file.")
