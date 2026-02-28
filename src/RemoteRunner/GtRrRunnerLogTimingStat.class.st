Class {
	#name : #GtRrRunnerLogTimingStat,
	#superclass : #Object,
	#instVars : [
		'name',
		'dataPoints',
		'average',
		'standardDeviation',
		'coefficientOfVariation',
		'minimum',
		'maximum'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #'instance creation' }
GtRrRunnerLogTimingStat class >> named: aString [
	^ self new
		name: aString;
		yourself
]

{ #category : #adding }
GtRrRunnerLogTimingStat >> addAllDataPoints: aCollection [
	"Add multiple data points to the collection"
	dataPoints addAll: aCollection
]

{ #category : #adding }
GtRrRunnerLogTimingStat >> addDataPoint: aNumber [
	"Add a data point to the collection"
	dataPoints add: aNumber
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

{ #category : #computing }
GtRrRunnerLogTimingStat >> computeStatistics [
	"Compute average, standard deviation, coefficient of variation, minimum, and maximum from the data points"
	dataPoints ifEmpty: [ ^ self ].
	average := dataPoints average.
	standardDeviation := dataPoints standardDeviation.
	coefficientOfVariation := average isZero
		ifTrue: [ 0 ]
		ifFalse: [ (standardDeviation / average) * 100 ].
	minimum := dataPoints min.
	maximum := dataPoints max
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> dataPointCount [
	"Answer the number of data points recorded"
	^ dataPoints size
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> dataPoints [
	^ dataPoints
]

{ #category : #accessing }
GtRrRunnerLogTimingStat >> dataPoints: aCollection [
	dataPoints := aCollection
]

{ #category : #testing }
GtRrRunnerLogTimingStat >> hasDataPoints [
	"Answer whether any data points have been recorded"
	^ dataPoints notEmpty
]

{ #category : #initialization }
GtRrRunnerLogTimingStat >> initialize [
	super initialize.
	dataPoints := OrderedCollection new
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
