// ============================================================
// SOLUTION: Summary Statistics — QML Interface
// ============================================================

import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP

Form
{
	info: qsTr("Practice analysis: compute summary statistics and a histogram for a single scale variable.")

	// ── 1. VARIABLE INPUT ──────────────────────────────────────────────────────
	// VariablesForm wraps all variable pickers.
	// AvailableVariablesList shows every column in the loaded dataset.
	// AssignedVariablesList is where the user drops their selection.
	VariablesForm
	{
		AvailableVariablesList
		{
			name: "allVariables"
		}

		AssignedVariablesList
		{
			name:           "variable"
			label:          qsTr("Variable")
			info:           qsTr("Select a single numeric (scale) variable to summarise.")
			allowedColumns: ["scale"]   // restrict the picker to scale variables
			singleVariable: true        // only one variable allowed
		}
	}

	// ── 2. SUMMARY TABLE CHECKBOX ─────────────────────────────────────────────
	// Checked by default so users get output immediately after assigning a variable.
	// Nested controls (CI) are indented and automatically grey out when unchecked.
	CheckBox
	{
		name:    "summaryTable"
		label:   qsTr("Summary Table")
		checked: true
		info:    qsTr("Display a table of descriptive statistics (N, mean, SD, median, min, max).")

		// ── BONUS: CONFIDENCE INTERVAL ────────────────────────────────────────
		// Give the CheckBox an id so the CIField can bind its enabled state to it.
		// CIField is a convenience control for confidence-level percentages (0–100).
		CheckBox
		{
			id:      showCi
			name:    "confidenceInterval"
			label:   qsTr("Confidence interval for the mean")
			info:    qsTr("Add lower and upper bounds of a t-based confidence interval for the mean.")

			CIField
			{
				name:    "ciLevel"
				label:   qsTr("Interval")
				info:    qsTr("Confidence level (e.g. 95 means 95%% CI).")
				enabled: showCi.checked   // grey out when parent box is unchecked
			}
		}
	}

	// ── 3. HISTOGRAM CHECKBOX (with nested bin count) ─────────────────────────
	// The IntegerField for bins is nested inside the CheckBox so it is
	// automatically disabled (and visually greyed) when the histogram is off.
	CheckBox
	{
		name:    "histogram"
		label:   qsTr("Histogram")
		checked: true
		info:    qsTr("Display a histogram of the selected variable.")

		IntegerField
		{
			name:         "histogramBins"
			label:        qsTr("Number of bins")
			defaultValue: 30
			min:          3
			max:          500
			info:         qsTr("Number of bars in the histogram.")
		}
	}

	// ── 4. ADVANCED SECTION ───────────────────────────────────────────────────
	// Section creates a collapsible panel.  Put rarely-used options here
	// to keep the main UI uncluttered.
	Section
	{
		title:   qsTr("Advanced Options")
		columns: 1

		// DropDown with explicit {label, value} pairs.
		// The `value` is what R receives in options[["missingValues"]].
		DropDown
		{
			name:  "missingValues"
			label: qsTr("Missing values")
			info:  qsTr("How to handle missing (NA) values before computing statistics.")
			values:
			[
				{ label: qsTr("Exclude listwise"), value: "listwise" },
				{ label: qsTr("Keep NA"),          value: "keepNA"   }
			]
		}
	}
}
