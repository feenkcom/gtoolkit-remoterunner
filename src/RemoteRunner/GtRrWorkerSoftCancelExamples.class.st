"
Examples for cancelling the current task of a worker without stopping the worker: {{gtMethod:GtRrWorker>>#commandTerminateTaskContextId:}} and {{gtMethod:GtRrWorkerExecutionContext>>#cancelWithReason:}}.

The task fails with a cancellation error, the job completes, and the worker stays registered and runs the next task. Compare with {{gtMethod:GtRemoteRunner>>#terminateTaskContextId:}}, which closes the worker connection (the worker stops).
"
Class {
	#name : #GtRrWorkerSoftCancelExamples,
	#superclass : #Object,
	#traits : 'TAssertable + TGtRrExampleHelp',
	#classTraits : 'TAssertable classTrait + TGtRrExampleHelp classTrait',
	#instVars : [
		'remoteRunner',
		'worker',
		'localRunner'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #private }
GtRrWorkerSoftCancelExamples >> assertWorkerRunsNextTaskOn: aRunner [
	"The worker is still usable after a cancellation"

	| aTask aSemaphore |
	aTask := GtRrScriptTask script: '3 + 4'.
	aSemaphore := Semaphore new.
	self
		submit: aTask
		to: aRunner
		signalling: aSemaphore.
	self
		waitOn: aSemaphore
		for: 20
		description: 'The next task did not complete'.
	self assert: aTask hasErrors not.
	self assert: aTask result equals: 7
]

{ #category : #examples }
GtRrWorkerSoftCancelExamples >> cancelRunningTask [
	"Cancelling the running task fails it with a cancellation error. The worker stays registered and runs the next task."

	<gtExample>
	<after: #cleanUp>
	<return: #GtRrScriptTask>
	| aTask aSemaphore aContext anAnswer aStart |
	self startInImageRunner.
	aTask := GtRrScriptTask script: '20 seconds wait. 42'.
	aSemaphore := Semaphore new.
	self
		submit: aTask
		to: remoteRunner
		signalling: aSemaphore.
	aContext := self runningTaskContextOf: aTask in: remoteRunner.
	aStart := DateAndTime now.
	anAnswer := worker commandTerminateTaskContextId: aContext taskContextId.
	self assert: anAnswer.
	self
		waitOn: aSemaphore
		for: 5
		description: 'The cancelled task did not complete'.
	self assert: DateAndTime now - aStart < 5 seconds.
	self assert: aTask hasErrors.
	self
		assert: (aTask errorDetails errorMessage
				includesSubstring: 'received TerminateCurrentTask').
	self assert: aTask result isNil.
	self assert: worker isRunning.
	self assert: remoteRunner registeredWorkers size equals: 1.
	self assertWorkerRunsNextTaskOn: remoteRunner.
	^ aTask
]

{ #category : #examples }
GtRrWorkerSoftCancelExamples >> cancelThroughControlChannel [
	"Cancel the running task of a local worker process through its control channel: the worker keeps its pid.
	The worker gets this image's changes at startup, so it has the fix even if the saved image does not.
	Slow, so not run as a test."

	<gtExample>
	<noTest>
	<after: #cleanUp>
	<return: #GtRrScriptTask>
	| aConnection aPid aTask aSemaphore aContext anAnswer aDeadline |
	localRunner := GtRemoteRunner new.
	localRunner managerStartupAndShutdown: GtRrLocalManagerStartupAndShutdown new.
	localRunner managerStartupAndShutdown
		poolSize: 1;
		autoRestart: false.
	localRunner start.
	aDeadline := DateAndTime now + 2 minutes.
	[ localRunner registeredWorkers isEmpty and: [ DateAndTime now < aDeadline ] ]
		whileTrue: [ 500 milliSeconds wait ].
	self assert: localRunner registeredWorkers size equals: 1.
	aConnection := localRunner registeredWorkers anyOne.
	self assert: aConnection hasObserver.
	aPid := aConnection attributes at: #pid.
	aTask := GtRrScriptTask script: '30 seconds wait. 42'.
	aSemaphore := Semaphore new.
	self
		submit: aTask
		to: localRunner
		signalling: aSemaphore.
	aContext := self runningTaskContextOf: aTask in: localRunner.
	anAnswer := aConnection commandTerminateTaskContextId: aContext taskContextId.
	self assert: anAnswer equals: true.
	self
		waitOn: aSemaphore
		for: 10
		description: 'The cancelled task did not complete'.
	self assert: aTask hasErrors.
	self
		assert: (aTask errorDetails errorMessage
				includesSubstring: 'received TerminateCurrentTask').
	self
		assert: (localRunner registeredWorkers at: aConnection workerId) == aConnection.
	self
		assert: ((localRunner registeredWorkers at: aConnection workerId) attributes at: #pid)
		equals: aPid.
	self assertWorkerRunsNextTaskOn: localRunner.
	^ aTask
]

{ #category : #examples }
GtRrWorkerSoftCancelExamples >> cancelWithOtherTaskContextId [
	"A cancellation for another task context does nothing: the running task continues"

	<gtExample>
	<after: #cleanUp>
	<return: #GtRrScriptTask>
	| aTask aSemaphore aContext |
	self startInImageRunner.
	aTask := GtRrScriptTask script: '20 seconds wait. 42'.
	aSemaphore := Semaphore new.
	self
		submit: aTask
		to: remoteRunner
		signalling: aSemaphore.
	aContext := self runningTaskContextOf: aTask in: remoteRunner.
	self deny: (worker commandTerminateTaskContextId: 'another-task-context-id').
	self deny: (aSemaphore waitTimeoutMilliseconds: 500) not.
	self deny: aTask isFinished.	"Clean up: cancel the right one"
	self assert: (worker commandTerminateTaskContextId: aContext taskContextId).
	self
		waitOn: aSemaphore
		for: 5
		description: 'The cancelled task did not complete'.
	^ aTask
]

{ #category : #examples }
GtRrWorkerSoftCancelExamples >> cancelWithoutRunningTask [
	"An idle worker answers false"

	<gtExample>
	<after: #cleanUp>
	<return: #GtRrInImageWorker>
	self startInImageRunner.
	self deny: (worker commandTerminateTaskContextId: 'any-task-context-id').
	self assertWorkerRunsNextTaskOn: remoteRunner.
	^ worker
]

{ #category : #cleanup }
GtRrWorkerSoftCancelExamples >> cleanUp [
	worker ifNotNil: [ worker stop ].
	worker := nil.
	remoteRunner ifNotNil: [ remoteRunner stop ].
	remoteRunner := nil.
	localRunner ifNotNil: [ localRunner stop ].
	localRunner := nil
]

{ #category : #private }
GtRrWorkerSoftCancelExamples >> runningTaskContextOf: aTask in: aRunner [
	"Wait until aTask runs on a worker and answer its runner-side task context"

	| aDeadline |
	aDeadline := DateAndTime now + 30 seconds.
	[ DateAndTime now < aDeadline ]
		whileTrue: [ (aRunner currentlyExecutingTasks values
				detect: [ :each | each taskId = aTask taskId ]
				ifNone: [ nil ])
				ifNotNil: [  "Give the worker time to start the task process":aContext | 
					200 milliSeconds wait.
					^ aContext ].
			50 milliSeconds wait ].
	self error: 'The task did not start'
]

{ #category : #private }
GtRrWorkerSoftCancelExamples >> startInImageRunner [
	remoteRunner := GtRemoteRunner new
			port: #none;
			yourself.
	remoteRunner start.
	worker := GtRrInImageWorker new
			remoteRunner: remoteRunner;
			start;
			yourself.
	^ remoteRunner
]

{ #category : #private }
GtRrWorkerSoftCancelExamples >> submit: aTask to: aRunner signalling: aSemaphore [
	| aJob |
	aJob := aTask asJob.
	aJob
		when: GtRrJobCompletedAnnouncement
		do: [ :anAnnouncement | aSemaphore signal ]
		for: self.
	aRunner submitJob: aJob.
	^ aJob
]
