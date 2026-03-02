Class {
	#name : #GtRrRunnerLogTimingDatasetExamples,
	#superclass : #Object,
	#category : #RemoteRunner
}

{ #category : #examples }
GtRrRunnerLogTimingDatasetExamples >> datasetComputesStatsFromRuns [
	<gtExample>
	| dataset runA runB stats |
	dataset := GtRrRunnerLogTimingDataset new.
	runA := GtRrRunnerLogTimingRun forFile: 'a.log' asFileReference.
	runA addPoint: 10 forStatisticNamed: 'Average task time'.
	runB := GtRrRunnerLogTimingRun forFile: 'b.log' asFileReference.
	runB addPoint: 30 forStatisticNamed: 'Average task time'.
	dataset addRun: runA.
	dataset addRun: runB.
	stats := dataset computeStats.
	self assert: (stats statAt: 'Average task time') dataPointCount equals: 2.
	self assert: (stats statAt: 'Average task time') average equals: 20.
	^ dataset
]
