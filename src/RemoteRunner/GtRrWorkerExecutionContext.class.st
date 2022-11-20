"
A GtRrWorkerExecutionContext is held in a {{gtClass:GtRrCurrentWorkerExecutionContext}}.
"
Class {
	#name : #GtRrWorkerExecutionContext,
	#superclass : #Object,
	#instVars : [
		'worker',
		'executionProcess',
		'taskContext',
		'timeout',
		'semaphore',
		'timeoutProcess'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorkerExecutionContext >> exceptionStrategy [

	^ worker exceptionStrategy
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> forkAndRun [
	"Run the task in a separate Process."

	executionProcess := [ self exceptionStrategy
		runTask: taskContext
		inContext: self ]
			forkAt: Processor userBackgroundPriority named: taskContext taskId, ' execution'.
	timeout ifNotNil:
		[ timeoutProcess := [ self timeoutTask ] forkAt: Processor lowIOPriority named: taskContext taskId, ' timeout' ].
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> initialize [

	super initialize.
	semaphore := Semaphore new.
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> signalTaskCompletion [

	semaphore signal
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> taskContext [

	^ taskContext
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> taskContext: anObject [

	taskContext := anObject
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> timeout [
	<return: #Duration>

	^ timeout
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> timeout: aDuration [

	timeout := aDuration
]

{ #category : #private }
GtRrWorkerExecutionContext >> timeoutTask [

	timeout wait.
	"Don't terminate the process if it is already terminated or is suspended (likely being debugged)"
	(executionProcess isTerminated or: [ executionProcess isSuspended ]) ifFalse:
		[ executionProcess signalException: GtRrTimeoutTaskError new ].
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> waitForTaskCompletion [

	semaphore wait
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> worker [

	^ worker
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> worker: anObject [

	worker := anObject
]
