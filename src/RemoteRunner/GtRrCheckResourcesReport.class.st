Class {
	#name : #GtRrCheckResourcesReport,
	#superclass : #Object,
	#instVars : [
		'totalGcTime',
		'initialGcDuration'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #serialization }
GtRrCheckResourcesReport class >> leJsonV4AttributeMapping [ 

	^ { 
		#totalGcTime -> #totalGcTime.
	}
]

{ #category : #serialization }
GtRrCheckResourcesReport class >> leJsonV4Name [
	^ #gtRrCheckResourcesReport
]

{ #category : #accessing }
GtRrCheckResourcesReport >> currentTotalGcTime [
	| vm |
	vm := SmalltalkImage current vm.
	^ vm totalFullGCTime + vm totalIncrementalGCTime
]

{ #category : #'gt - extensions' }
GtRrCheckResourcesReport >> gtViewTextualStatisticsFor: aView [
	<gtView>
	
	^ aView textEditor
		title: 'Statistics (textual)';
		text: [ self textualStatistics ]
]

{ #category : #profiling }
GtRrCheckResourcesReport >> recordSourceReport [
	initialGcDuration := self currentTotalGcTime
]

{ #category : #profiling }
GtRrCheckResourcesReport >> recordTargetReport [
	totalGcTime :=  self currentTotalGcTime - initialGcDuration
]

{ #category : #accessing }
GtRrCheckResourcesReport >> textualStatistics [
	^ String streamContents: [ :aStream  |
		aStream >> 'Total GC Time: '.
		totalGcTime printWithCommasOn: aStream ]
]

{ #category : #accessing }
GtRrCheckResourcesReport >> totalGcTimeDiff [
	^ totalGcTime
]
