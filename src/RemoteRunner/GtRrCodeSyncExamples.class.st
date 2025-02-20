Class {
	#name : #GtRrCodeSyncExamples,
	#superclass : #Object,
	#classVars : [
		'TestValue'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrCodeSyncExamples class >> testValue [
	^ TestValue
]

{ #category : #accessing }
GtRrCodeSyncExamples class >> testValue: anObject [
	TestValue := anObject
]

{ #category : #accessing }
GtRrCodeSyncExamples >> addRemoveMethod [
	<gtExample>
	<noTest>
	| runner codeSync semaphore |
	runner := self simpleRunner.
	codeSync := runner managerStartupAndShutdown codeSync.
	runner managerStartupAndShutdown poolSize: 1.
	[ semaphore := Semaphore new.
	runner 
		when: GtRrWorkerRegisteredAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	runner start.
	semaphore
		wait: 10 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected registration announcement' ].
	"Signal the semaphore when a code sync task completes so we can wait for changes to be propagated"
	runner
		when: GtRrTaskCompletedAnnouncement 
		do: [ :ann | semaphore signal ] 
		for: self.
	"add/remove method changes should be propagated to workers"
	self assert: (self hasMethodIn: runner) not.
	semaphore consumeAllSignals.
	self class compile: 'blub ^ 1'.
	semaphore
		wait: 5 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 1' ].
	self assert: (self hasMethodIn: runner).
	semaphore consumeAllSignals.
	self class removeSelector: #blub.
	semaphore
		wait: 5 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 2' ].
	self assert: (self hasMethodIn: runner) not.
	"stopping sync should no longer propagate changes"
	codeSync stop.
	self class compile: 'blub ^ 1'.
	self assert: (self hasMethodIn: runner) not ] ensure: [ 
		self class removeSelector: #blub.
		runner stop ].
	^ runner
]

{ #category : #accessing }
GtRrCodeSyncExamples >> evaluateExpression [
	<gtExample>
	| runner codeSync semaphore timestamp task |
	runner := GtRemoteRunner new
		        port: 0;
				startLogging;
		        yourself.
	codeSync := runner managerStartupAndShutdown codeSync.
	runner managerStartupAndShutdown poolSize: 1.
	[ semaphore := Semaphore new.
	runner 
		when: GtRrWorkerRegisteredAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	runner start.
	semaphore
		wait: 20 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected registration announcement' ].
	"Signal the semaphore when a code sync task completes so we can wait for changes to be propagated"
	runner
		when: GtRrTaskCompletedAnnouncement 
		do: [ :ann | semaphore signal ] 
		for: self.
	timestamp := DateAndTime now printString.
	semaphore consumeAllSignals.
	SystemAnnouncer uniqueInstance announce: (ExpressionEvaluated expression: 
		'GtRrCodeSyncExamples testValue: ''', timestamp, '''').
	semaphore
		wait: 20 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 1' ].
	semaphore consumeAllSignals.
	task := GtRrScriptTask script: 'GtRrCodeSyncExamples testValue'.
	runner submitJob: task asJob.
	semaphore
		wait: 20 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 2' ].
	self assert: task result equals: timestamp ] ensure: 
		[ runner stop ].
	^ runner
]

{ #category : #accessing }
GtRrCodeSyncExamples >> hasMethodIn: aRunner [
	| job semaphore |

	job := GtRrJob script: self class name , ' includesSelector: #blub'.
	semaphore := Semaphore new.
	job
		when: GtRrJobCompletedAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	aRunner submitJob: job.
	semaphore 
		wait: 5 seconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected job completion announcement' ].
	^ job tasks first result
]

{ #category : #'as yet unclassified' }
GtRrCodeSyncExamples >> simpleRunner [
	"Answer a started RemoteRunner.
	It is up to the caller to stop the runner (and thus the workers)."
	| remoteRunner  |

	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown 
		autoRestart: false;
		poolSize: 1.

	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	^ remoteRunner
]
