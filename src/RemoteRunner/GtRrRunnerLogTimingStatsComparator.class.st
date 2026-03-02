Class {
	#name : #GtRrRunnerLogTimingStatsComparator,
	#superclass : #Object,
	#instVars : [
		'baselineStats',
		'testLogFile',
		'comparisonResults',
		'analyzer'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #'instance creation' }
GtRrRunnerLogTimingStatsComparator class >> baseline: aGtRrTimingStats testLogFile: aFileReference [
	"Create a comparator with baseline stats and a test log file"
	^ self new
		baselineStats: aGtRrTimingStats;
		testLogFile: aFileReference;
		yourself
]

{ #category : #accessing }
GtRrRunnerLogTimingStatsComparator >> baselineStats [
	^ baselineStats
]

{ #category : #accessing }
GtRrRunnerLogTimingStatsComparator >> baselineStats: aGtRrTimingStats [
	baselineStats := aGtRrTimingStats
]

{ #category : #api }
GtRrRunnerLogTimingStatsComparator >> compare [
	"Load the test log file, analyze it, and compare against baseline.
	Answer self with populated comparisonResults."

	analyzer := GtRrRunnerLogTimingAnalyzer forFile: testLogFile.
	self testStats computeAll.
	comparisonResults := OrderedCollection new.
	self statisticNames do: [ :statName |
		self compareStatisticNamed: statName ].
	^ self
]

{ #category : #api }
GtRrRunnerLogTimingStatsComparator >> compareStatisticNamed: aStatName [
	"Compare a single statistic and add result to comparisonResults"
	| baselineStat testStat result |
	baselineStat := baselineStats statAt: aStatName.
	testStat := self testStats statAt: aStatName.
	result := GtRrRunnerLogTimingComparisonResult new
		statisticName: aStatName;
		baselineStat: baselineStat;
		testStat: testStat;
		deviationThreshold: self deviationThreshold;
		compute.
	comparisonResults add: result
]

{ #category : #accessing }
GtRrRunnerLogTimingStatsComparator >> comparisonResults [
	^ comparisonResults
]

{ #category : #'private - constants' }
GtRrRunnerLogTimingStatsComparator >> deviationThreshold [
	"Answer the number of standard deviations considered acceptable"
	^ 2
]

{ #category : #'gt-views' }
GtRrRunnerLogTimingStatsComparator >> gtViewReportOn: aView [
	<gtView>
	^ aView textEditor
		title: 'Report';
		priority: 10;
		text: [ self report ]
]

{ #category : #querying }
GtRrRunnerLogTimingStatsComparator >> hasOutliers [
	"Answer whether any statistics fall outside the acceptable range"
	^ self outliers notEmpty
]

{ #category : #initialization }
GtRrRunnerLogTimingStatsComparator >> initialize [
	super initialize.
	comparisonResults := OrderedCollection new
]

{ #category : #querying }
GtRrRunnerLogTimingStatsComparator >> outliers [
	"Answer the comparison results that fall outside the acceptable deviation threshold"
	^ comparisonResults select: [ :each | each isOutlier ]
]

{ #category : #reporting }
GtRrRunnerLogTimingStatsComparator >> report [
	"Generate a report string comparing baseline and test statistics"
	<return: #String>
	
	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Timing Statistics Comparison Report';
			cr;
			nextPutAll: '====================================';
			cr; cr;
			nextPutAll: 'Test Log File: ';
			nextPutAll: testLogFile basename;
			cr;
			nextPutAll: 'Deviation Threshold: ';
			print: self deviationThreshold;
			nextPutAll: ' standard deviations';
			cr; cr.
		comparisonResults do: [ :result |
			stream nextPutAll: result reportString; cr; cr ].
		self hasOutliers
			ifTrue: [ 
				stream
					nextPutAll: 'WARNING: ';
					print: self outliers size;
					nextPutAll: ' statistic(s) outside acceptable range!';
					cr ]
			ifFalse: [
				stream
					nextPutAll: 'All statistics within acceptable range.';
					cr ] ]
]

{ #category : #'private - constants' }
GtRrRunnerLogTimingStatsComparator >> statisticNames [
	"Answer the names of statistics to compare"
	^ #('First task queued time' 'Average message queue time' 'Average task time')
]

{ #category : #accessing }
GtRrRunnerLogTimingStatsComparator >> testLogFile [
	^ testLogFile
]

{ #category : #accessing }
GtRrRunnerLogTimingStatsComparator >> testLogFile: aFileReference [
	testLogFile := aFileReference
]

{ #category : #accessing }
GtRrRunnerLogTimingStatsComparator >> testStats [

	^ analyzer timingStats
]
