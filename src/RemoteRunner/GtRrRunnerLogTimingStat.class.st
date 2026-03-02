Class {
	#name : #GtRrRunnerLogTimingStat,
	#superclass : #Object,
	#instVars : [
		'name',
		'average',
		'standardDeviation',
		'coefficientOfVariation',
		'minimum',
		'maximum',
		'dataPointCount',
		'varianceSum'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #'instance creation' }
GtRrRunnerLogTimingStat class >> named: aString [
	^ self new
		name: aString;
		yourself
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> average [
	^ average
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> average: aNumber [
	average := aNumber
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> averageDuration [

	^ Duration milliSeconds: average
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> coefficientOfVariation [
	<return: #Number>
	^ coefficientOfVariation
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> coefficientOfVariation: aNumber [
	coefficientOfVariation := aNumber
]

{ #category : #statistics }
GtRrRunnerLogTimingStat >> computeFromValues: aCollection [
	"Compute statistics from the given values without storing them."
	| values |
	values := aCollection asOrderedCollection.
	values ifEmpty: [
		dataPointCount := 0.
		average := nil.
		standardDeviation := nil.
		coefficientOfVariation := nil.
		minimum := nil.
		maximum := nil.
		^ self ].
	dataPointCount := values size.
	average := values average.
	standardDeviation := values standardDeviation.
	coefficientOfVariation := average isZero
		ifTrue: [ 0 ]
		ifFalse: [ (standardDeviation / average) * 100 ].
	minimum := values min.
	maximum := values max
]

{ #category : #statistics }
GtRrRunnerLogTimingStat >> computeStatistics [
	"Compute statistics based on existing dataset-backed values."
	^ self
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> dataPointCount [
	"Answer the number of data points recorded"
	^ dataPointCount
]

{ #category : #testing }
GtRrRunnerLogTimingStat >> hasDataPoints [
	"Answer whether any data points have been recorded"
	^ dataPointCount > 0
]

{ #category : #initialization }
GtRrRunnerLogTimingStat >> initialize [
	super initialize.
	dataPointCount := 0
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> maximum [
	<return: #Number>
	^ maximum
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> maximum: aNumber [
	maximum := aNumber
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> minimum [
	^ minimum
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> minimum: aNumber [
	minimum := aNumber
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> name [
	^ name
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> name: aString [
	name := aString
]

{ #category : #printing }
GtRrRunnerLogTimingStat >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: (name ifNil: [ 'unnamed' ]);
		nextPut: $)
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> standardDeviation [
	<return: #Number>
	^ standardDeviation
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> standardDeviation: aNumber [
	standardDeviation := aNumber
]
