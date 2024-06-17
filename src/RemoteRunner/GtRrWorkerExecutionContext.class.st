"
nil
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
		'timeoutProcess',
		'exceptionHandlingStrategy'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #testing }
GtRrWorkerExecutionContext >> allowDebugger [
	"Answer a boolean indicating whether the debugger should be opened as the result of an exception"
	
	^ self exceptionHandlingStrategy allowDebugger
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> exceptionHandlingStrategy [

	^ exceptionHandlingStrategy ifNil:
		[ taskContext exceptionHandlingStrategy ifNil:
			[ worker exceptionHandlingStrategy ] ]
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> exceptionHandlingStrategy: anObject [

	exceptionHandlingStrategy := anObject
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> forkAndRun [
	"Run the task and timeout monitor in separate processes.  Some UI processes are executed at userBackgroundPriority, so run just under that to avoid slowing down the UI when run in-image.  Dedicated workers shouldn't have higher priority processes anyway."

	executionProcess := [ self runTask]
		forkAt: Processor userBackgroundPriority  - 2
			named: taskContext taskId, ' execution'.
	timeout ifNotNil:
		[ timeoutProcess := [ self timeoutTask ] 
			forkAt: Processor lowIOPriority 
				named: taskContext taskId, ' timeout' ].
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> initialize [

	super initialize.
	semaphore := Semaphore new.
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> runTask [
	"Run the task with the receiver's environment set up."

	GtRrCurrentWorkerExecutionContext value: self.
	self exceptionHandlingStrategy
		runTask: taskContext
		inContext: self.
]

{ #category : #accessing }
GtRrWorkerExecutionContext >> signalTaskCompletion [

	semaphore signal
]

{ #category : #'start-stop' }
GtRrWorkerExecutionContext >> stop [

	( executionProcess isTerminating or: [ executionProcess isTerminated ]) ifFalse:
		[ executionProcess signalException:
			GtRrWorkerTerminationNotification new ]
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
