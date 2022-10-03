Class {
	#name : #GtRrTaskResourcesReport,
	#superclass : #GtVmRuntimeStatisticsDiffReport,
	#instVars : [
		'meminfoReport'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #serialization }
GtRrTaskResourcesReport class >> leJsonV4Name [
	^ #gtRrTaskResourcesReport
]

{ #category : #accessing }
GtRrTaskResourcesReport >> meminfoReport [

	^ meminfoReport
]

{ #category : #accessing }
GtRrTaskResourcesReport >> meminfoReport: anObject [

	meminfoReport := anObject
]

{ #category : #profiling }
GtRrTaskResourcesReport >> recordTargetReport [
	super recordTargetReport.
	
	meminfoReport := GtRrMachineMeminfoReport new 
		recordReportStatistics
]
