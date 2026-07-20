"
Represents the timing data extracted from a single remote runner log file.
It stores one timestamp and source file per run, and a dictionary of statistic points keyed by name.
"
Class {
	#name : #GtRrRunnerLogTimingRun,
	#superclass : #Object,
	#instVars : [
		'sourceFile',
		'collectedAt',
		'pointsByName'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #'instance creation' }
GtRrRunnerLogTimingRun class >> forFile: aFileReference [
	^ self new
		sourceFile: aFileReference;
		collectedAt: DateAndTime now;
		yourself
]

{ #category : #statistics }
GtRrRunnerLogTimingRun >> addPoint: aNumber forStatisticNamed: aName [
	pointsByName at: aName put: aNumber
]

{ #category : #accessing }
GtRrRunnerLogTimingRun >> collectedAt [
	^ collectedAt
]

{ #category : #accessing }
GtRrRunnerLogTimingRun >> collectedAt: aDateAndTime [
	collectedAt := aDateAndTime
]

{ #category : #statistics }
GtRrRunnerLogTimingRun >> hasPointNamed: aName [
	^ pointsByName includesKey: aName
]

{ #category : #initialization }
GtRrRunnerLogTimingRun >> initialize [
	super initialize.
	pointsByName := Dictionary new.
]

{ #category : #statistics }
GtRrRunnerLogTimingRun >> pointAt: aName [
	^ pointsByName at: aName ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrRunnerLogTimingRun >> pointsByName [
	^ pointsByName
]

{ #category : #accessing }
GtRrRunnerLogTimingRun >> sourceFile [
	^ sourceFile
]

{ #category : #accessing }
GtRrRunnerLogTimingRun >> sourceFile: aFileReference [
	sourceFile := aFileReference
]
