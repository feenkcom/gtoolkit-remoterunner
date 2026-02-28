Class {
	#name : #GtRrRunnerLogTimingComparisonResult,
	#superclass : #Object,
	#instVars : [
		'statisticName',
		'baselineStat',
		'testStat',
		'deviationThreshold',
		'testValue',
		'deviationsFromMean',
		'isOutlier'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> baselineStat [
	^ baselineStat
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> baselineStat: aGtRrTimingStat [
	baselineStat := aGtRrTimingStat
]

{ #category : #computation }
GtRrRunnerLogTimingComparisonResult >> compute [
	"Compute whether the test value is an outlier.
	Handle cases where baseline or test data is missing."
	(baselineStat isNil or: [ testStat isNil ]) ifTrue: [
		isOutlier := false.
		deviationsFromMean := nil.
		^ self ].
	baselineStat hasDataPoints ifFalse: [
		isOutlier := false.
		deviationsFromMean := nil.
		^ self ].
	testStat hasDataPoints ifFalse: [
		isOutlier := false.
		deviationsFromMean := nil.
		^ self ].
	testValue := testStat average.
	baselineStat standardDeviation isZero
		ifTrue: [ 
			"If no variance in baseline, check for exact match"
			deviationsFromMean := (testValue - baselineStat average) abs.
			isOutlier := deviationsFromMean > 0 ]
		ifFalse: [
			deviationsFromMean := (testValue - baselineStat average) abs / baselineStat standardDeviation.
			isOutlier := deviationsFromMean > deviationThreshold ]
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> deviationThreshold [
	^ deviationThreshold
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> deviationThreshold: aNumber [
	deviationThreshold := aNumber
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> deviationsFromMean [
	^ deviationsFromMean
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> isOutlier [
	^ isOutlier
]

{ #category : #reporting }
GtRrRunnerLogTimingComparisonResult >> reportString [
	"Generate a report string for this comparison result"
	^ String streamContents: [ :stream |
		stream
			nextPutAll: statisticName;
			cr;
			nextPutAll: '  Baseline: '.
		baselineStat 
			ifNil: [ stream nextPutAll: 'N/A' ]
			ifNotNil: [
				stream
					nextPutAll: 'avg=';
					print: baselineStat averageDuration;
					nextPutAll: ', stdDev=';
					print: baselineStat standardDeviation ].
		stream cr; nextPutAll: '  Test:     '.
		testStat
			ifNil: [ stream nextPutAll: 'N/A' ]
			ifNotNil: [ stream nextPutAll: 'avg='; print: testStat averageDuration ].
		deviationsFromMean ifNotNil: [
			stream
				cr;
				nextPutAll: '  Deviations from mean: ';
				print: (deviationsFromMean roundTo: 0.01) ].
		stream cr; nextPutAll: '  Status: '.
		isOutlier
			ifTrue: [ stream nextPutAll: '⚠️ OUTLIER' ]
			ifFalse: [ stream nextPutAll: '✓ OK' ] ]
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> statisticName [
	^ statisticName
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> statisticName: aString [
	statisticName := aString
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> testStat [
	^ testStat
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> testStat: aGtRrTimingStat [
	testStat := aGtRrTimingStat
]

{ #category : #accessing }
GtRrRunnerLogTimingComparisonResult >> testValue [
	^ testValue
]
