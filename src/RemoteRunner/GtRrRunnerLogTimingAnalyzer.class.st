Class {
	#name : #GtRrRunnerLogTimingAnalyzer,
	#superclass : #Object,
	#instVars : [
		'filename',
		'signals',
		'timingStats',
		'currentRun'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #api }
GtRrRunnerLogTimingAnalyzer class >> analyzeFiles: aCollection [
	"Create a new instance and analyze the supplied log files"
	| analyzer |
	analyzer := self new.
	aCollection do: [ :rrLog |
		analyzer
			filename: rrLog;
			analyze ].
	analyzer timingStats computeAll.
	^ analyzer
]

{ #category : #'instance creation' }
GtRrRunnerLogTimingAnalyzer class >> forFile: aFileReference [
	"Create an analyzer for the given log file"
	^ self new
		filename: aFileReference;
		yourself
]

{ #category : #api }
GtRrRunnerLogTimingAnalyzer >> analyze [
	"Run all timing analysis and update the timing dataset.
	Answer the timing stats."
	self currentRun: (GtRrRunnerLogTimingRun forFile: self filename).
	self updateFirstTaskQueuedTimeStat.
	self updateAverageMessageQueueTimeStat.
	self updateAverageTaskTimeStat.
	self updateFirstWorkerRegistrationTimeStat.
	self currentRun collectedAt: self firstJobStartupSignal timestamp.
	self timingStats addRun: self currentRun.
	self timingStats computeAll.
	^ self timingStats
]

{ #category : #updating }
GtRrRunnerLogTimingAnalyzer >> appendStatsTo: baselineStats [
	"Append all data points from the receiver's timing dataset to the supplied baseline stats.
	For each stat in the receiver, add its data points to the corresponding stat in baselineStats.
	If a stat doesn't exist in baselineStats, create it.
	Finally, recalculate all statistics in the baseline.
	Answer the baselineStats."
	self timingStats appendStatsTo: baselineStats.
	^ baselineStats
]

{ #category : #calculating }
GtRrRunnerLogTimingAnalyzer >> calculateAverageMessageQueueTime [
	"Calculate the average message queue time.
	This is the time from first task queued signal until last task queued signal,
	divided by the number of messages queued.
	Answer the duration in milliseconds, or nil if signals not found."
	| firstSignal lastSignal messageCount totalDuration |
	firstSignal := self firstTaskQueuedSignal.
	lastSignal := self lastTaskQueuedSignal.
	messageCount := self numberOfQueuedMessages.
	(firstSignal isNil or: [ lastSignal isNil or: [ messageCount = 0 ] ]) 
		ifTrue: [ ^ nil ].
	totalDuration := (lastSignal timestamp - firstSignal timestamp) asNanoSeconds / 1000000.0.
	^ totalDuration / messageCount
]

{ #category : #calculating }
GtRrRunnerLogTimingAnalyzer >> calculateAverageTaskTime [
	"Calculate the average task time.
	This is the time from first task started signal until last task completed signal,
	divided by the number of tasks completed.
	Answer the duration, or nil if signals not found."
	| firstSignal lastSignal taskCount totalDuration |
	firstSignal := self firstTaskStartedSignal.
	lastSignal := self lastTaskCompletedSignal.
	taskCount := self numberOfCompletedTasks.
	(firstSignal isNil or: [ lastSignal isNil or: [ taskCount = 0 ] ]) 
		ifTrue: [ ^ nil ].
	totalDuration := (lastSignal timestamp - firstSignal timestamp) asNanoSeconds / 1000000.0.
	^ totalDuration / taskCount
]

{ #category : #'private - statistics' }
GtRrRunnerLogTimingAnalyzer >> calculateFirstTaskQueuedTime [
	"Calculate the time from job startup to first task queued.
	Answer the duration in milliseconds, or nil if signals not found."
	| startSignal queuedSignal duration |
	startSignal := self firstJobStartupSignal.
	queuedSignal := self firstTaskQueuedSignal.
	(startSignal isNil or: [ queuedSignal isNil ]) ifTrue: [ ^ nil ].
	duration := (queuedSignal timestamp - startSignal timestamp) asNanoSeconds / 1000000.0.
	^ duration
]

{ #category : #'private - statistics' }
GtRrRunnerLogTimingAnalyzer >> calculateFirstWorkerRegistrationTime [
	"Calculate the time from job startup to first non-local worker registration.
	Answer the duration in milliseconds, or nil if signals not found."
	| startSignal registrationSignal duration |
	startSignal := self firstJobStartupSignal.
	registrationSignal := self firstWorkerRegistrationSignal.
	(startSignal isNil or: [ registrationSignal isNil ]) ifTrue: [ ^ nil ].
	duration := (registrationSignal timestamp - startSignal timestamp) asNanoSeconds / 1000000.0.
	^ duration
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> currentRun [
	^ currentRun
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> currentRun: aRun [
	currentRun := aRun
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> filename [
	^ filename
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> filename: aFileReference [
	filename := aFileReference.
	signals := nil "Reset cached signals when filename changes"
]

{ #category : #'private - signals' }
GtRrRunnerLogTimingAnalyzer >> firstJobStartupSignal [
	"Find the first job startup signal in the log"
	^ self signals 
		detect: [ :each | each isKindOf: GtRrJobStartupSignal ]
		ifNone: [ nil ]
]

{ #category : #'private - signals' }
GtRrRunnerLogTimingAnalyzer >> firstTaskQueuedSignal [
	"Find the first task queued signal in the log"
	^ self signals 
		detect: [ :each | each isKindOf: GtRrMqQueueTaskStartingSignal ]
		ifNone: [ nil ]
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> firstTaskStartedSignal [
	"Find the first task started signal in the log"
	^ self signals 
		detect: [ :each | 
			{ GtRrTaskStartedAnnouncement. GtRrNextTaskStartingSignal } anySatisfy: [ :signalClass |
			each isKindOf: signalClass ] ]
		ifNone: [ nil ]
]

{ #category : #'private - signals' }
GtRrRunnerLogTimingAnalyzer >> firstWorkerRegistrationSignal [
	"Find the first worker registration signal in the log."

	^ self signals 
		detect: [ :each | each isKindOf: GtRrWorkerRegisteredAnnouncement ]
		ifNone: [ nil ]
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> lastTaskCompletedSignal [
	"Find the last task completed signal in the log"
	^ self signals 
		reverseDo: [ :each | 
			({ GtRrTaskCompletedAnnouncement. GtRrNextTaskCompletedSignal } anySatisfy: [ :signalClass |
			each isKindOf: signalClass ])
				ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> lastTaskQueuedSignal [
	"Find the last task queued signal in the log"
	^ self signals 
		reverseDo: [ :each | 
			((each isKindOf: GtRrMqQueueTaskCompletedSignal) and:
			[ each isRetry not ])
				ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> numberOfCompletedTasks [
	"Count the number of completed tasks (task completed signals)"
	^ self signals count: [ :each | 
		{ GtRrTaskCompletedAnnouncement. GtRrNextTaskCompletedSignal } 
			anySatisfy: [ :signalClass |
				each isKindOf: signalClass ] ]
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> numberOfQueuedMessages [
	"Count the number of messages queued (task starting signals)"
	^ self signals count: [ :each | each isKindOf: GtRrMqQueueTaskStartingSignal ]
]

{ #category : #'private - statistics' }
GtRrRunnerLogTimingAnalyzer >> recordPoint: aNumber named: aStatName [
	self currentRun ifNil: [ ^ self ].
	self currentRun addPoint: aNumber forStatisticNamed: aStatName
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> signals [
	"Lazily load signals from the log file"
	^ signals ifNil: [ 
		signals := (GtBeaconJsonLogReader new filename: filename) signals ]
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> timingStats [
	"Answer the timing stats, creating if necessary."
	timingStats ifNil: [ timingStats := GtRrRunnerLogTimingStats new ].
	^ timingStats
]

{ #category : #accessing }
GtRrRunnerLogTimingAnalyzer >> timingStats: aGtRrTimingStats [
	"Set an existing timing stats instance to update"
	timingStats := aGtRrTimingStats
]

{ #category : #statistics }
GtRrRunnerLogTimingAnalyzer >> updateAverageMessageQueueTimeStat [
	"Calculate and add the average message queue time statistic"
	| statName value |
	statName := 'Average message queue time'.
	value := self calculateAverageMessageQueueTime.
	value ifNil: [ ^ self ].
	self recordPoint: value named: statName
]

{ #category : #statistics }
GtRrRunnerLogTimingAnalyzer >> updateAverageTaskTimeStat [
	"Calculate and add the average task time statistic"
	| statName value |
	statName := 'Average task time'.
	value := self calculateAverageTaskTime.
	value ifNil: [ ^ self ].
	self recordPoint: value named: statName
]

{ #category : #statistics }
GtRrRunnerLogTimingAnalyzer >> updateFirstTaskQueuedTimeStat [
	"Calculate and add the first task queued time statistic"
	| statName value |
	statName := 'First task queued time'.
	value := self calculateFirstTaskQueuedTime.
	value ifNil: [ ^ self ].
	self recordPoint: value named: statName
]

{ #category : #statistics }
GtRrRunnerLogTimingAnalyzer >> updateFirstWorkerRegistrationTimeStat [
	"Calculate and add the first non-local worker registration time statistic"
	| statName value |
	statName := 'First worker registration'.
	value := self calculateFirstWorkerRegistrationTime.
	value ifNil: [ ^ self ].
	self recordPoint: value named: statName
]
