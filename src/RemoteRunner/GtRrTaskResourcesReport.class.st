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

{ #category : #'memory usage' }
GtRrTaskResourcesReport >> gtSpecificSizeInMemory [
	^ super gtSpecificSizeInMemory 
		+ (meminfoReport
			ifNil: [ 0]
			ifNotNil: [ :aReport | aReport gtSpecificSizeInMemory ])
]

{ #category : #accessing }
GtRrTaskResourcesReport >> machineAvailableMemory [
	^ self meminfoReport ifNotNil: [ :aMemInfoReport |
		aMemInfoReport memAvailable ]
]

{ #category : #accessing }
GtRrTaskResourcesReport >> machineFreeMemory [
	^ self meminfoReport memFree
]

{ #category : #accessing }
GtRrTaskResourcesReport >> machineTotalMemory [
	^ self meminfoReport ifNotNil: [ :aMemInfoReport |
		aMemInfoReport memTotal ]
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
