// ============================================================
// EXERCISE: Summary Statistics — QML Interface
// ============================================================
//
// Your task: fill in every TODO to build a working JASP interface
// that lets users:
//   1. Assign a single scale variable
//   2. Toggle a summary-statistics table
//   3. Toggle a histogram (with configurable bins)
//   4. (Bonus) Toggle a confidence interval shown in the table
//
// Key rules:
//   - Wrap ALL user-visible strings in qsTr("...")
//   - Use camelCase for `name:` values (they map to options[["name"]] in R)
//   - Nest subordinate controls INSIDE the CheckBox that enables them
//   - Every `name:` is the "API" between QML and R — never rename one
//     without also updating the R code.
// ============================================================

import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP

Form
{
	// The `info:` property populates the (i) tooltip for the whole analysis.
	info: qsTr("Practice analysis: compute summary statistics and a histogram for a single scale variable.")

	// ── 1. VARIABLE INPUT ──────────────────────────────────────────────────────
	// A VariablesForm contains an AvailableVariablesList (all columns in the
	// dataset) and one or more AssignedVariablesLists (the user's selections).
	//
	// TIP: Use allowedColumns: ["scale"] to restrict to numeric variables.
	// TIP: Use singleVariable: true when only one variable is needed.

	VariablesForm
	{
		AvailableVariablesList
		{
			name: "allVariables"
		}

		// TODO: Add an AssignedVariablesList named "variable",
		//       labelled "Variable", restricted to scale columns, single variable.
		// FILL IN

	}

	// ── 2. SUMMARY TABLE CHECKBOX ─────────────────────────────────────────────
	// A CheckBox enables/disables an output.  Nest dependent controls inside it
	// so they are automatically greyed out when the box is unchecked.
	//
	// TIP:
	//   CheckBox
	//   {
	//     name:    "myOption"
	//     label:   qsTr("My Label")
	//     checked: true          // default state
	//   }

	// TODO: Add a CheckBox named "summaryTable", labelled "Summary Table",
	//       checked by default.
	// FILL IN


	// ── 3. HISTOGRAM CHECKBOX (with nested bin control) ───────────────────────
	// Nest an IntegerField *inside* the CheckBox so the bin count is only
	// editable while the histogram is enabled.
	//
	// TIP: IntegerField properties: name, label, defaultValue, min, max.

	// TODO: Add a CheckBox named "histogram", labelled "Histogram",
	//       checked by default.
	//       Inside it, add an IntegerField named "histogramBins",
	//       labelled "Number of bins", defaultValue 30, min 3, max 500.
	// FILL IN


	// ── 4. BONUS: CONFIDENCE INTERVAL (nested inside Summary Table) ───────────
	// Move the CI checkbox so it only appears when summaryTable is checked.
	// A CIField is a ready-made percent field for confidence levels.
	//
	// TIP: Give the CheckBox an `id:` so the CIField can bind to it:
	//   CheckBox { id: showCi; name: "confidenceInterval"; ... }
	//   CIField  { name: "ciLevel"; enabled: showCi.checked }

	// TODO (bonus): Add a CheckBox named "confidenceInterval",
	//               labelled "Confidence interval for the mean".
	//               Nest a CIField named "ciLevel" inside it.
	// FILL IN


	// ── 5. ADVANCED SECTION ───────────────────────────────────────────────────
	// Wrap rarely-used options in a collapsible Section.
	//
	// TIP:
	//   Section
	//   {
	//     title:   qsTr("Advanced Options")
	//     columns: 1
	//     // controls go here
	//   }

	// TODO: Add a Section titled "Advanced Options" containing a
	//       DropDown named "missingValues" labelled "Missing values" with
	//       two choices: { label: qsTr("Exclude listwise"), value: "listwise" }
	//       and          { label: qsTr("Keep NA"),          value: "keepNA"   }.
	// FILL IN

}
