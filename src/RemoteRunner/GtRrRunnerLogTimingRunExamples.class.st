Class {
	#name : #GtRrRunnerLogTimingRunExamples,
	#superclass : #Object,
	#category : #RemoteRunner
}

{ #category : #examples }
GtRrRunnerLogTimingRunExamples >> runCollectsPoints [
	<gtExample>
	| run |
	run := GtRrRunnerLogTimingRun forFile: 'sample.log' asFileReference.
	run addPoint: 10 forStatisticNamed: 'Average task time'.
	run addPoint: 5 forStatisticNamed: 'Average message queue time'.
	self assert: run sourceFile basename equals: 'sample.log'.
	self assert: run collectedAt notNil.
	self assert: (run pointAt: 'Average task time') equals: 10.
	self assert: (run hasPointNamed: 'Average message queue time').
	^ run
]
