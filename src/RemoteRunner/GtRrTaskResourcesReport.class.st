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
GtRrTaskResourcesReport >> machineAvailableMemory [
	^ self meminfoReport memAvailable
]

{ #category : #accessing }
GtRrTaskResourcesReport >> machineFreeMemory [
	^ self meminfoReport memFree
]

{ #category : #accessing }
GtRrTaskResourcesReport >> machineTotalMemory [
	^ self meminfoReport memTotal
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
	
	OSPlatform current isUnix ifFalse: [ ^ self ].
	
	meminfoReport := GtRrMachineMeminfoReport new 
		recordReportStatistics
]
