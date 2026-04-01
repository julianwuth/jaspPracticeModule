# ============================================================
# SOLUTION: Summary Statistics — R Backend
# ============================================================
#
# Demonstrates:
#   - ready check & early-return pattern
#   - .hasErrors() dataset validation
#   - createJaspTable: columns, footnotes, setData
#   - conditional CI columns with overtitle
#   - createJaspPlot with ggplot2 + jaspGraphs theme
#   - $dependOn() on every output element
#   - gettext() / gettextf() for i18n
#   - try() error handling on the plot
# ============================================================


# ── MAIN ENTRY POINT ────────────────────────────────────────────────────────────
# JASP always calls the function whose name matches the `function` field in
# Description.qml.  The three arguments are fixed: never rename them.

SummaryStats <- function(jaspResults, dataset, options) {

  # ── 1. READY CHECK ──────────────────────────────────────────────────────────
  # options[["variable"]] is "" when the user has not yet assigned a variable.
  # All helpers receive `ready` so they can show empty placeholders immediately.
  ready <- options[["variable"]] != ""


  # ── 2. DATASET VALIDATION ───────────────────────────────────────────────────
  # Validate the dataset only — QML already validates option values.
  # .hasErrors() attaches the error to the affected output and, with
  # exitAnalysisIfErrors = TRUE, stops execution so nothing else runs.
  if (ready) {
    .hasErrors(
      dataset,
      type                 = c("observations", "variance", "infinity"),
      all.target           = options[["variable"]],
      observations.amount  = "< 3",          # need at least 3 obs for SD / CI
      exitAnalysisIfErrors = TRUE
    )
  }


  # ── 3. DISPATCH OUTPUTS ─────────────────────────────────────────────────────
  # Each output is created only if the user has ticked its checkbox.
  # The helper functions handle idempotency (skip if already built).
  if (options[["summaryTable"]])
    .createSummaryTable(jaspResults, dataset, options, ready)

  if (options[["histogram"]])
    .createHistogram(jaspResults, dataset, options, ready)

}


# ── HELPER: Summary Statistics Table ────────────────────────────────────────────

.createSummaryTable <- function(jaspResults, dataset, options, ready) {

  # Idempotency guard — JASP calls R on every option change; this prevents
  # rebuilding an output that is already up-to-date.
  if (!is.null(jaspResults[["summaryTable"]]))
    return()


  # ── TABLE: CREATE & ATTACH ───────────────────────────────────────────────────
  # Attach to jaspResults BEFORE any data checks.  That way, if we return
  # early (e.g. data not ready) the user still sees an empty placeholder
  # rather than a blank panel.
  summaryTable          <- createJaspTable(gettext("Summary Statistics"))
  summaryTable$position <- 1

  # $dependOn() lists every option that can invalidate this table.
  # When any listed option changes, JASP drops this element and we recreate it.
  summaryTable$dependOn(c("variable", "summaryTable", "confidenceInterval", "ciLevel",
                          "missingValues"))

  jaspResults[["summaryTable"]] <- summaryTable


  # ── TABLE: DEFINE COLUMNS ────────────────────────────────────────────────────
  # Column types: "string", "number", "integer", "pvalue"
  # gettext() makes the title translatable via the Weblate workflow.
  summaryTable$addColumnInfo(name = "statistic", type = "string", title = gettext("Statistic"))
  summaryTable$addColumnInfo(name = "value",     type = "number", title = gettext("Value"))

  # Bonus: CI columns — only add them when the checkbox is ticked.
  # overtitle groups "Lower" and "Upper" under a shared header.
  if (options[["confidenceInterval"]]) {
    ciPct <- gettextf("%s%%", round(100 * options[["ciLevel"]]))  # e.g. "95%"
    summaryTable$addColumnInfo(name = "ciLow",  type = "number",
                               title = gettext("Lower"), overtitle = ciPct)
    summaryTable$addColumnInfo(name = "ciHigh", type = "number",
                               title = gettext("Upper"), overtitle = ciPct)
  }


  # ── TABLE: EARLY RETURN ───────────────────────────────────────────────────────
  if (!ready)
    return()


  # ── TABLE: COMPUTE ────────────────────────────────────────────────────────────
  x <- dataset[[options[["variable"]]]]

  # Handle missing values according to the Advanced Option
  if (options[["missingValues"]] == "listwise")
    x <- x[!is.na(x)]

  rows <- data.frame(
    statistic = c(gettext("N"), gettext("Mean"), gettext("SD"),
                  gettext("Median"), gettext("Min"), gettext("Max")),
    value     = c(length(x), mean(x), stats::sd(x),
                  stats::median(x), min(x), max(x))
  )

  # Bonus: fill CI columns for the Mean row only; leave other rows as NA
  if (options[["confidenceInterval"]]) {
    ci         <- stats::t.test(x, conf.level = options[["ciLevel"]])$conf.int
    rows$ciLow  <- NA_real_
    rows$ciHigh <- NA_real_
    meanRow          <- rows$statistic == gettext("Mean")
    rows$ciLow[meanRow]  <- ci[1]
    rows$ciHigh[meanRow] <- ci[2]
  }


  # ── TABLE: FOOTNOTE ───────────────────────────────────────────────────────────
  # Footnotes appear beneath the table.  Use them for methodological notes.
  summaryTable$addFootnote(gettext("SD computed with N\u22121 denominator (Bessel\u2019s correction)."))

  summaryTable$setData(rows)
}


# ── HELPER: Histogram ─────────────────────────────────────────────────────────────

.createHistogram <- function(jaspResults, dataset, options, ready) {

  # Idempotency guard
  if (!is.null(jaspResults[["histogram"]]))
    return()


  # ── PLOT: CREATE & ATTACH ─────────────────────────────────────────────────────
  histogram          <- createJaspPlot(title = gettext("Histogram"), width = 400, height = 320)
  histogram$position <- 2
  histogram$dependOn(c("variable", "histogram", "histogramBins", "missingValues"))

  jaspResults[["histogram"]] <- histogram

  if (!ready)
    return()


  # ── PLOT: BUILD ───────────────────────────────────────────────────────────────
  # jaspGraphs::jaspHistogram() handles binning, axis styling, and the JASP
  # theme — no manual ggplot2 boilerplate needed.
  # binWidthType = "manual" enables the numberOfBins argument.
  # Wrap in try() so a plotting error shows on the plot element, not a crash.
  x    <- dataset[[options[["variable"]]]]
  bins <- options[["histogramBins"]]

  if (options[["missingValues"]] == "listwise")
    x <- x[!is.na(x)]

  plotObj <- try(jaspGraphs::jaspHistogram(
    x            = x,
    xName        = options[["variable"]],
    binWidthType = "manual",
    numberOfBins = bins
  ))

  if (inherits(plotObj, "try-error")) {
    histogram$setError(as.character(plotObj))
    return()
  }

  histogram$plotObject <- plotObj
}
