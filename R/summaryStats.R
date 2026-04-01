# ============================================================
# EXERCISE: Summary Statistics — R Backend
# ============================================================
#
# Your task: fill in every TODO to build a working analysis.
#
# The analysis must:
#   1. Check whether a variable has been assigned (ready check)
#   2. Validate the dataset  (errors / edge cases)
#   3. Build a summary-statistics table   (when checkbox is ticked)
#   4. Build a histogram                  (when checkbox is ticked)
#   5. (Bonus) Add CI columns to the table
#
# Key rules:
#   - Signature is always: AnalysisName <- function(jaspResults, dataset, options)
#   - Access options with options[["name"]] (double brackets, no partial matching)
#   - Wrap all user-visible strings with gettext() / gettextf()
#   - NEVER use library() or require() — use package::function() instead
#   - Always attach an output to jaspResults BEFORE filling it with data
#     (so the empty placeholder is shown even on error)
# ============================================================


summaryStats <- function(jaspResults, dataset, options) {

  # ── 1. READY CHECK ──────────────────────────────────────────────────────────
  # The analysis should only do work once a variable is assigned.
  # options[["variable"]] equals "" when the variable slot is empty.
  #
  # TIP: ready <- options[["variable"]] != ""

  # TODO: Define `ready` as TRUE when a variable has been assigned.
  ready <- ...  # FILL IN


  # ── 2. DATASET VALIDATION ───────────────────────────────────────────────────
  # Validate ONLY the dataset (QML already validates option values).
  # .hasErrors() automatically places the error message on affected outputs
  # and, if exitAnalysisIfErrors = TRUE, stops execution immediately.
  #
  # Common types: "observations", "variance", "infinity", "missingValues"
  # Prefix arguments with the type name, e.g. observations.amount = "< 3"
  #
  # TIP:
  #   .hasErrors(
  #     dataset,
  #     type                 = c("observations", "variance", "infinity"),
  #     all.target           = options[["variable"]],   # which column(s) to check
  #     observations.amount  = "< 3",                   # need at least 3 rows
  #     exitAnalysisIfErrors = TRUE
  #   )

  # TODO: Validate the dataset (only when ready).
  if (ready) {
    # FILL IN
  }


  # ── 3. DISPATCH OUTPUTS ─────────────────────────────────────────────────────
  # Call helper functions to build each output.
  # Guard each call with the corresponding checkbox option.
  #
  # TIP: if (options[["checkboxName"]]) .createOutput(jaspResults, ...)

  # TODO: Call .createSummaryTable() when the "summaryTable" checkbox is ticked.
  # FILL IN

  # TODO: Call .createHistogram() when the "histogram" checkbox is ticked.
  # FILL IN

}


# ── HELPER: Summary Statistics Table ────────────────────────────────────────────

.createSummaryTable <- function(jaspResults, dataset, options, ready) {

  # JASP calls R repeatedly; this guard prevents redundant work.
  if (!is.null(jaspResults[["summaryTable"]]))
    return()


  # ── TABLE: CREATE ────────────────────────────────────────────────────────────
  # TIP: createJaspTable(gettext("Title")) returns a jaspTable object.
  #
  # TODO: Create a table with the title "Summary Statistics".
  summaryTable <- ...  # FILL IN

  summaryTable$position <- 1


  # ── TABLE: DEPENDENCIES ──────────────────────────────────────────────────────
  # $dependOn() tells JASP which options can invalidate this output.
  # When any listed option changes, the table is dropped and recreated.
  #
  # TIP: summaryTable$dependOn(c("option1", "option2"))
  #
  # TODO: Declare dependencies on "variable", "summaryTable",
  #       "confidenceInterval", and "ciLevel".
  summaryTable$dependOn(...)  # FILL IN


  # Attach to jaspResults NOW — before data checks — so that if we return
  # early the empty table (rather than nothing) is displayed.
  jaspResults[["summaryTable"]] <- summaryTable


  # ── TABLE: DEFINE COLUMNS ────────────────────────────────────────────────────
  # Column types: "string", "number", "integer", "pvalue"
  # Use gettext() for column titles so they are translatable.
  #
  # TIP: summaryTable$addColumnInfo(name = "colId", type = "string", title = gettext("Header"))
  #
  # TODO: Add a "statistic" column (string, title "Statistic").
  # TODO: Add a "value"     column (number, title "Value").
  summaryTable$addColumnInfo(...)  # FILL IN
  summaryTable$addColumnInfo(...)  # FILL IN

  # ── TABLE: BONUS — CI COLUMNS ────────────────────────────────────────────────
  # When the confidence-interval checkbox is ticked, add two more columns.
  # Use `overtitle` to group columns under a shared header.
  #
  # TIP:
  #   table$addColumnInfo(name = "ciLow", type = "number",
  #                       title = gettext("Lower"),
  #                       overtitle = gettextf("%i%% Confidence Interval", 100 * options[["ciLevel"]]))
  #
  # TODO (bonus): Conditionally add "ciLow" and "ciHigh" columns when
  #               options[["confidenceInterval"]] is TRUE.
  # FILL IN


  # ── TABLE: EARLY RETURN ───────────────────────────────────────────────────────
  # Nothing to fill yet — variable not yet assigned.
  if (!ready)
    return()


  # ── TABLE: COMPUTE & FILL ─────────────────────────────────────────────────────
  x <- dataset[[options[["variable"]]]]

  # TODO: Build a data.frame with one row per statistic.
  #       Rows: N, Mean, SD, Median, Min, Max.
  #       Each row needs at least: statistic (string), value (numeric).
  #
  # TIP:
  #   rows <- data.frame(
  #     statistic = c(gettext("N"), gettext("Mean"), ...),
  #     value     = c(length(x),   mean(x),          ...)
  #   )
  rows <- data.frame(
    statistic = c(gettext("N"), gettext("Mean"), gettext("SD"),
                  gettext("Median"), gettext("Min"), gettext("Max")),
    value     = c(...)  # FILL IN
  )

  # ── TABLE: BONUS — FILL CI COLUMNS ──────────────────────────────────────────
  # Compute a t-interval for the mean and fill the ciLow/ciHigh columns
  # for the Mean row only (leave others as NA).
  #
  # TIP: Use stats::t.test(x, conf.level = options[["ciLevel"]])$conf.int
  #      NA fills naturally when the column exists but no value is set.
  #
  # TODO (bonus): When options[["confidenceInterval"]] is TRUE,
  #               add columns ciLow and ciHigh to `rows` (empty string "" except Mean row).
  # FILL IN


  # ── TABLE: FOOTNOTE ──────────────────────────────────────────────────────────
  # Footnotes appear below the table.  Use them for method notes.
  #
  # TIP: summaryTable$addFootnote(gettext("Note text here."))
  #
  # TODO: Add a footnote noting that SD uses N-1 in the denominator.
  # FILL IN

  summaryTable$setData(rows)
}


# ── HELPER: Histogram ─────────────────────────────────────────────────────────────

.createHistogram <- function(jaspResults, dataset, options, ready) {

  # Idempotency guard
  if (!is.null(jaspResults[["histogram"]]))
    return()


  # ── PLOT: CREATE ──────────────────────────────────────────────────────────────
  # TIP: createJaspPlot(title = gettext("..."), width = 400, height = 320)
  #
  # TODO: Create a plot titled "Histogram", width 400, height 320.
  histogram <- ...  # FILL IN

  histogram$position <- 2


  # ── PLOT: DEPENDENCIES ────────────────────────────────────────────────────────
  # TODO: Declare dependencies on "variable", "histogram", "histogramBins".
  histogram$dependOn(...)  # FILL IN

  jaspResults[["histogram"]] <- histogram

  if (!ready)
    return()


  # ── PLOT: BUILD ───────────────────────────────────────────────────────────────
  # Use jaspGraphs::jaspHistogram() — it handles binning, styling, and the JASP
  # theme automatically.  No manual ggplot2 boilerplate needed.
  #
  # Key arguments:
  #   x             — numeric vector
  #   xName         — x-axis label string
  #   binWidthType  — "manual" lets you set an exact bin count
  #   numberOfBins  — used when binWidthType = "manual"
  #
  # TIP: Wrap in try() and call histogram$setError() on failure so the user
  #      sees a readable message instead of a crash.
  #
  # TODO: Extract x and bins from dataset/options, then call jaspHistogram()
  #       and assign the result to histogram$plotObject.
  #
  # HINT (skeleton):
  #   x    <- dataset[[options[["variable"]]]]
  #   bins <- options[["histogramBins"]]
  #   plotObj <- try(jaspGraphs::jaspHistogram(x, xName = options[["variable"]],
  #                                            binWidthType = "manual",
  #                                            numberOfBins = bins))
  #   if (isTryError(plotObj)) { histogram$setError(...); return() }
  #   histogram$plotObject <- plotObj
  # FILL IN

}
