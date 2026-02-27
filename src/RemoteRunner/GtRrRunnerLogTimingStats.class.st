"
GtRrTimingStats is a container for collecting and persisting timing-related statistical information gathered from multiple test suite executions.

Instance Variables:
	stats <Dictionary>
		A dictionary mapping statistic names (typically Strings or Symbols) to GtRrTimingStat instances.
		Each GtRrTimingStat holds data points and computed statistics (average, standard deviation, etc.) for a particular timing measurement.

Usage:
	1. Create a new instance:
		| timingStats |
		timingStats := GtRrTimingStats new.
		
	2. Add or retrieve statistics:
		timingStats statAt: 'testSuiteExecution' put: aGtRrTimingStat.
		timingStats statAt: 'testSuiteExecution'.
		
	3. Persist to file:
		timingStats saveToFile: '/path/to/stats.ston' asFileReference.
		
	4. Load from file:
		timingStats := GtRrTimingStats loadFromFile: '/path/to/stats.ston' asFileReference.

Extending this class:
	- Add methods to filter or query statistics by criteria (e.g., by name pattern, by coefficient of variation threshold).
	- Add visualization methods to display charts or tables of the collected timing data.
	- Consider adding timestamps or metadata about when statistics were collected.

"
Class {
	#name : #GtRrRunnerLogTimingStats,
	#superclass : #Object,
	#instVars : [
		'stats'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #persistence }
GtRrRunnerLogTimingStats class >> loadFromFile: aFileReference [
	"Load an instance from the given STON file."
	^ aFileReference asFileReference readStreamDo: [ :stream |
		STON fromStream: stream ]
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogTimingStats >> computeAll [
	"Force recalculation of all stats"

	stats do: [ :stat |
		stat computeStatistics ].
]

{ #category : #'gt-extensions' }
GtRrRunnerLogTimingStats >> gtViewStatsOn: aView [
	<gtView>
	^ aView columnedList
		title: 'Stats';
		priority: 10;
		items: [ self stats values sorted: [ :a :b | a name < b name ] ];
		column: 'Name' text: [ :aStat | aStat name ];
		column: 'Average' text: [ :aStat | aStat average printShowingDecimalPlaces: 1 ];
		column: 'Minimum' text: [ :aStat | aStat minimum printShowingDecimalPlaces: 1 ];
		column: 'Maximum' text: [ :aStat | aStat maximum printShowingDecimalPlaces: 1 ];
		column: 'Standard Deviation' text: [ :aStat | aStat standardDeviation printShowingDecimalPlaces: 1 ];
		column: 'Number of data points' text: [ :aStat | aStat dataPointCount ]
]

{ #category : #initialization }
GtRrRunnerLogTimingStats >> initialize [
	super initialize.
	stats := Dictionary new
]

{ #category : #persistence }
GtRrRunnerLogTimingStats >> saveToFile: aFileReference [
	"Save the receiver to the given file in STON format."
	aFileReference asFileReference writeStreamDo: [ :stream |
		STON put: self onStreamPretty: stream ]
]

{ #category : #accessing }
GtRrRunnerLogTimingStats >> statAt: aName [
	"Answer the timing stat for the given name, or nil if not present."
	^ stats at: aName ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrRunnerLogTimingStats >> statAt: aName put: aGtRrTimingStat [
	"Store the given timing stat under the given name."
	stats at: aName put: aGtRrTimingStat
]

{ #category : #accessing }
GtRrRunnerLogTimingStats >> stats [
	"Answer the dictionary of timing statistics keyed by name."
	^ stats
]

{ #category : #accessing }
GtRrRunnerLogTimingStats >> stats: aDictionary [
	"Set the dictionary of timing statistics."
	stats := aDictionary
]
