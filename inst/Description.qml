import QtQuick
import JASP.Module

Description
{
	name		: "jaspPracticeModule"
	title		: qsTr("Jasp Practice Module")
	description	: qsTr("Examples for module builders")
	version		: "0.1"
	author		: "JASP Team"
	maintainer	: "JASP Team <info@jasp-stats.org>"
	website		: "https://jasp-stats.org"
	license		: "GPL (>= 2)"
	icon        : "exampleIcon.png" // Located in /inst/icons/
	preloadData: true
	requiresData: true


	Analysis
	{
		title: qsTr("Summary statistics") // Title for window
		func: "summaryStats"           // Function to be called
		qml: "summaryStats.qml"               // Design input window
		requiresData: true                // Allow to run even without data
	}

}
