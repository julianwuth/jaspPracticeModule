# ============================================================
# Unit tests for the `summaryStats` analysis
# ============================================================
#
# Pattern shipped with jaspTools (cf. JASP unit-testing slides):
#
#   1. Get the default option list with jaspTools::analysisOptions()
#   2. Mutate the options you want to exercise
#   3. Run the analysis on a dataset (here: "test.csv" — bundled with jaspTools)
#   4. Extract the relevant element from the returned results tree
#   5. Compare it with a snapshot using one of:
#        - jaspTools::expect_equal_tables()   for tables
#        - jaspTools::expect_equal_plots()    for plots
#        - testthat::expect_identical()       for error / status checks
#
# Reference snapshots for tables are generated once with
# jaspTools::makeTestTable(table) and then pasted into the test as a flat
# list(...). Plot snapshots are stored as .svg files under
# tests/testthat/_snaps/ the first time the test is run.
#
# NOTE: The analysis is currently an exercise scaffold (TODOs in R/QML).
#       These tests target the *intended* option API documented in
#       R/summaryStats.R and inst/qml/summaryStats.qml. They will only
#       pass once that exercise is filled in.
# ============================================================


# ── TEST 1 ─ Summary statistics table ────────────────────────────────────────
test_that("Summary statistics table matches snapshot", {

  # Default options come straight from the QML interface. We then override
  # the ones relevant for this test.
  options                    <- jaspTools::analysisOptions("summaryStatsSolution")
  options$variable           <- "contNormal"   # numeric column in test.csv
  options$summaryTable       <- TRUE
  options$histogram          <- FALSE          # disable plot to speed up
  options$confidenceInterval <- FALSE          # keep snapshot minimal

  # Always set a seed: some helpers in jaspGraphs use random jitter.
  set.seed(1)
  results <- jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options)

  # Navigate the results tree to the table's `data` slot.
  # Top-level key matches the jaspResults[["summaryTable"]] name in R.
  table <- results[["results"]][["summaryTable"]][["data"]]

  # Reference list: row-by-row, fields in alphabetical order within each row.
  # Generated once via jaspTools::makeTestTable(table) and pasted here.
  # If the table layout changes intentionally, regenerate and replace this
  # list — never blindly overwrite expectations.
  jaspTools::expect_equal_tables(
    table,
    list("N",      100,
         "Mean",   -0.18874858754,
         "SD",     1.05841360919316,
         "Median", -0.38335354,
         "Min",    -3.023963827,
         "Max",     3.356094448),
    label = "Default summary table on contNormal"
  )
})


# ── TEST 2 ─ Summary table with confidence-interval columns ──────────────────
test_that("Summary table includes CI columns when requested", {

  options                    <- jaspTools::analysisOptions("summaryStatsSolution")
  options$variable           <- "contNormal"
  options$summaryTable       <- TRUE
  options$confidenceInterval <- TRUE
  options$ciLevel            <- 0.95
  options$histogram          <- FALSE

  set.seed(1)
  results <- jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options)

  table <- results[["results"]][["summaryTable"]][["data"]]

  # CI bounds only populate on the "Mean" row; other rows leave them empty.
  # Fields alphabetical per row → (ciHigh, ciLow, statistic, value).
  jaspTools::expect_equal_tables(
    table,
    list("",                  "",                   "N",      100,
         0.0212636349750835,   -0.398760810055083,  "Mean",   -0.18874858754,
         "",                   "",                   "SD",     1.05841360919316,
         "",                   "",                   "Median", -0.38335354,
         "",                   "",                   "Min",    -3.023963827,
         "",                   "",                   "Max",     3.356094448),
    label = "Summary table with 95% CI on the mean"
  )
})


# ── TEST 3 ─ Histogram plot ──────────────────────────────────────────────────
test_that("Histogram plot matches snapshot", {

  options                  <- jaspTools::analysisOptions("summaryStatsSolution")
  options$variable         <- "contNormal"
  options$summaryTable     <- FALSE
  options$histogram        <- TRUE
  options$histogramBins    <- 30

  set.seed(1)
  results <- jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options)

  # Plots are stored in two places in `results`:
  #   results$results$<key>$data   — string key like "plots/1.png"
  #   results$state$figures[[key]] — the actual plot object
  plotKey  <- results[["results"]][["histogram"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotKey]][["obj"]]

  # Snapshot name is just a label; the .svg lives in tests/testthat/_snaps/.
  # On first run a new snapshot is created — inspect it manually before
  # accepting it as the reference.
  jaspTools::expect_equal_plots(testPlot, "histogram-default")
})


# ── TEST 4 ─ Error handling ──────────────────────────────────────────────────
# Mirrors the pattern from the slide on testing error handling: feed the
# analysis a problematic option/data combination and assert that
# results$status takes the expected non-"complete" value.
test_that("Analysis handles missing variable assignment gracefully", {

  options          <- jaspTools::analysisOptions("summaryStatsSolution")
  options$variable <- ""        # nothing assigned in the GUI
  options$summaryTable <- TRUE

  set.seed(1)
  results <- jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options)

  # With no variable, the analysis should still finish cleanly (empty table
  # is shown), NOT fail with a fatal/validation error.
  expect_identical(
    results[["status"]],
    "complete",
    label = "No variable assigned should not crash the analysis"
  )
})

test_that("Analysis flags infinity in the chosen variable", {

  options              <- jaspTools::analysisOptions("summaryStatsSolution")
  options$variable     <- "debInf"   # column with Inf values in test.csv
  options$summaryTable <- TRUE
  options$histogram    <- FALSE

  set.seed(1)
  results <- jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options)

  # .hasErrors(..., type = "infinity", exitAnalysisIfErrors = TRUE) trips
  # JASP's validation pipeline, which sets status = "validationError".
  expect_identical(
    results[["status"]],
    "validationError",
    label = "Infinity check on `debInf` should raise a validation error"
  )
})


# ============================================================
# APPENDIX A — Generating a single table snapshot
# ============================================================
#
# `expect_equal_tables()` compares the table to a flat reference list with
# fields in alphabetical order within each row. Don't write that list by
# hand — let jaspTools::makeTestTable() print it for you, then paste it in.
#
# Run this once in the R session, then copy the printed list(...) into the
# `expect_equal_tables()` call above.
#
#   options                    <- jaspTools::analysisOptions("summaryStatsSolution")
#   options$variable           <- "contNormal"
#   options$summaryTable       <- TRUE
#   options$histogram          <- FALSE
#   options$confidenceInterval <- FALSE
#   set.seed(1)
#   results <- jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options)
#   table   <- results[["results"]][["summaryTable"]][["data"]]
#   jaspTools::makeTestTable(table)
#
# Output (paste as the `ref` argument of expect_equal_tables):
#
#   list("N", 100, "Mean", -0.18874858754, "SD", 1.05841360919316, "Median",
#        -0.38335354, "Min", -3.023963827, "Max", 3.356094448)


# ============================================================
# APPENDIX B — Auto-generating an entire test_that() block
# ============================================================
#
# runAnalysis(..., makeTests = TRUE) prints ready-made `test_that()` blocks
# for every table and plot the run produced. Useful for bootstrapping a new
# test file or expanding coverage after adding outputs.
#
# Run once in the R session and copy what gets printed into this file
# (above the appendices). Inspect new plot snapshots manually before
# treating them as references.
#
#   options                    <- jaspTools::analysisOptions("summaryStatsSolution")
#   options$variable           <- "contNormal"
#   options$summaryTable       <- TRUE
#   options$histogram          <- TRUE
#   options$histogramBins      <- 30
#   options$confidenceInterval <- TRUE
#   options$ciLevel            <- 0.95
#   set.seed(1)
#   jaspTools::runAnalysis("summaryStatsSolution", "test.csv", options, makeTests = TRUE)
#
# Output:
#
#   options <- analysisOptions("summaryStatsSolution")
#   options$variable <- "contNormal"
#   options$confidenceInterval <- TRUE
#   set.seed(1)
#   results <- runAnalysis("summaryStatsSolution", "test.csv", options)
#
#   test_that("Histogram plot matches", {
#     plotName <- results[["results"]][["histogram"]][["data"]]
#     testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
#     jaspTools::expect_equal_plots(testPlot, "histogram")
#   })
#
#   test_that("Summary Statistics table results match", {
#     table <- results[["results"]][["summaryTable"]][["data"]]
#     jaspTools::expect_equal_tables(table,
#       list("", "", "N", 100, 0.0212636349750835, -0.398760810055083, "Mean",
#            -0.18874858754, "", "", "SD", 1.05841360919316, "", "", "Median",
#            -0.38335354, "", "", "Min", -3.023963827, "", "", "Max", 3.356094448
#         ))
#   })


# ============================================================
# APPENDIX C — Auto-generating tests from .jasp files
# ============================================================

# jaspTools::makeTestsFromExamples()
