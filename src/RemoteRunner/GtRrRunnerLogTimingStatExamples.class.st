Class {
	#name : #GtRrRunnerLogTimingStatExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-JobStats'
}

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> emptyTimingStat [
	<gtExample>
	| stat |
	stat := GtRrRunnerLogTimingStat named: 'emptyTest'.
	
	self assert: stat name equals: 'emptyTest'.
	self assert: stat hasDataPoints not.
	self assert: stat dataPointCount equals: 0.
	self assert: stat average isNil.
	self assert: stat standardDeviation isNil.
	self assert: stat coefficientOfVariation isNil.
	
	^ stat
]

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> timingStatComputeOnEmpty [
	<gtExample>
	"Computing statistics on empty data should not raise an error"
	| stat |
	stat := self emptyTimingStat.
	stat computeStatistics.
	
	"Statistics should remain nil after computing on empty data"
	self assert: stat average isNil.
	self assert: stat standardDeviation isNil.
	self assert: stat coefficientOfVariation isNil.
	
	^ stat
]

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> timingStatPrintString [
	<gtExample>
	| stat |
	stat := GtRrRunnerLogTimingStat named: 'printTest'.
	
	self assert: (stat printString includesSubstring: 'printTest').
	
	^ stat
]

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> timingStatWithAddAllDataPoints [
	<gtExample>
	| stat |
	stat := GtRrRunnerLogTimingStat named: 'batchTest'.
	stat computeFromValues: #(5 10 15 20 25).
	
	self assert: stat dataPointCount equals: 5.
	
	"Average of 5, 10, 15, 20, 25 is 15"
	self assert: stat average equals: 15.
	
	^ stat
]

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> timingStatWithComputedStatistics [
	<gtExample>
	| stat |
	stat := self timingStatWithDataPoints.
	
	"Average of 10, 20, 30 is 20"
	self assert: stat average equals: 20.
	
	"Standard deviation: sqrt(((10-20)^2 + (20-20)^2 + (30-20)^2) / 3) = sqrt(200/3)"
	self assert: (stat standardDeviation closeTo: (200 / 3) sqrt).
	
	"Coefficient of variation: (stdDev / average) * 100"
	self assert: (stat coefficientOfVariation closeTo: ((200 / 3) sqrt / 20) * 100).
	
	^ stat
]

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> timingStatWithDataPoints [
	<gtExample>
	| stat |
	stat := GtRrRunnerLogTimingStat named: 'taskDuration'.
	stat computeFromValues: #(10 20 30).
	
	self assert: stat name equals: 'taskDuration'.
	self assert: stat hasDataPoints.
	self assert: stat dataPointCount equals: 3.
	
	^ stat
]

{ #category : #examples }
GtRrRunnerLogTimingStatExamples >> timingStatWithUniformValues [
	<gtExample>
	"When all values are the same, standard deviation should be 0"
	| stat |
	stat := GtRrRunnerLogTimingStat named: 'uniformTest'.
	stat computeFromValues: #(50 50 50 50).
	
	self assert: stat average equals: 50.
	self assert: stat standardDeviation equals: 0.
	self assert: stat coefficientOfVariation equals: 0.
	
	^ stat
]
