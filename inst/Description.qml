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
	icon        : "exampleIcon.png"
	preloadData: true
	requiresData: true


	Analysis
	{
		title: qsTr("Summary statistics")
		func: "summaryStatsSolution"
		qml: "summaryStatsSolution.qml"
		requiresData: true
	}

}
