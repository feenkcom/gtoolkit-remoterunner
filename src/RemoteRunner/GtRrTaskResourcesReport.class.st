Class {
	#name : #GtRrTaskResourcesReport,
	#superclass : #GtVmRuntimeStatisticsDiffReport,
	#instVars : [
		'meminfoReport',
		'externalMemReport'
	],
	#category : 'RemoteRunner-Tasks'
}

{ #category : #serialization }
GtRrTaskResourcesReport class >> leJsonV4Name [
	^ #gtRrTaskResourcesReport
]

{ #category : #accessing }
GtRrTaskResourcesReport >> externalMemReport [
	^ externalMemReport
]

{ #category : #accessing }
GtRrTaskResourcesReport >> externalMemReport: anObject [
	externalMemReport := anObject
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
GtRrTaskResourcesReport >> recordSourceReport [

	super recordSourceReport.
	GtRrExternalMemoryAndFinalizationStats hasUniqueInstance ifTrue:
		[ GtRrExternalMemoryAndFinalizationStats uniqueInstance restart ].
]

{ #category : #profiling }
GtRrTaskResourcesReport >> recordTargetReport [

	super recordTargetReport.

	GtRrExternalMemoryAndFinalizationStats hasUniqueInstance ifTrue:
		[ externalMemReport := GtRrExternalMemoryAndFinalizationStats uniqueInstance copy.
		GtRrExternalMemoryAndFinalizationStats uniqueInstance restart ].

	OSPlatform current isUnix ifFalse: [ ^ self ].
	
	meminfoReport := GtRrMachineMeminfoReport new 
		recordReportStatistics.
]
