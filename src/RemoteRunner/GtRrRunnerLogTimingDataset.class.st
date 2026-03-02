"
A collection of timing runs that can compute summary statistics.
"
Class {
	#name : #GtRrRunnerLogTimingDataset,
	#superclass : #Object,
	#instVars : [
		'runs'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #accessing }
GtRrRunnerLogTimingDataset >> addRun: aRun [
	runs add: aRun
]

{ #category : #updating }
GtRrRunnerLogTimingDataset >> appendStatsTo: baselineStats [
	runs do: [ :run | baselineStats addRun: run ].
	baselineStats computeAll.
	^ baselineStats
]

{ #category : #statistics }
GtRrRunnerLogTimingDataset >> computeStats [
	^ self computeStatsOn: GtRrRunnerLogTimingStats new
]

{ #category : #statistics }
GtRrRunnerLogTimingDataset >> computeStatsOn: aTimingStats [
	| valuesByName |
	valuesByName := Dictionary new.
	runs do: [ :run |
		run pointsByName keysAndValuesDo: [ :statName :value |
			(valuesByName at: statName ifAbsentPut: [ OrderedCollection new ])
				add: value ] ].
	valuesByName keysAndValuesDo: [ :statName :values |
		| stat |
		stat := aTimingStats statAt: statName.
		stat ifNil: [
			stat := GtRrRunnerLogTimingStat named: statName.
			aTimingStats statAt: statName put: stat ].
		stat computeFromValues: values ].
	^ aTimingStats
]

{ #category : #initialization }
GtRrRunnerLogTimingDataset >> initialize [
	super initialize.
	runs := OrderedCollection new.
]

{ #category : #accessing }
GtRrRunnerLogTimingDataset >> runs [
	^ runs
]

{ #category : #statistics }
GtRrRunnerLogTimingDataset >> statValuesNamed: aStatName [
	^ runs
		select: [ :each | each hasPointNamed: aStatName ]
		thenCollect: [ :each | each pointAt: aStatName ]
]
