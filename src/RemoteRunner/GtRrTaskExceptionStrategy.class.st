"
GtRrTaskExceptionStrategys define how exceptions, including halt, are handled by the workers.
"
Class {
	#name : #GtRrTaskExceptionStrategy,
	#superclass : #Object,
	#category : #'RemoteRunner-ExceptionHandling'
}

{ #category : #testing }
GtRrTaskExceptionStrategy >> allowDebugger [
	"Answer a boolean indicating whether the debugger should be opened as the result of an exception"

	^ false
]

{ #category : #accessing }
GtRrTaskExceptionStrategy >> notifyTaskDidntComplete: taskContext inContext: aGtRrWorkerExecutionContext [
	"Notify the runner that the task failed to complete for unknown reasons."

	aGtRrWorkerExecutionContext worker 
		taskFailed: taskContext
		with: (Error new messageText: 'Task process terminated unexpectedly').
	aGtRrWorkerExecutionContext signalTaskCompletion.
]

{ #category : #accessing }
GtRrTaskExceptionStrategy >> notifyTaskTimedOut: taskContext inContext: aGtRrWorkerExecutionContext [

	aGtRrWorkerExecutionContext worker 
		taskFailed: taskContext
		with: (Error new messageText: 'Timeout after: ', aGtRrWorkerExecutionContext timeout printString).
	aGtRrWorkerExecutionContext signalTaskCompletion.
]

{ #category : #accessing }
GtRrTaskExceptionStrategy >> runTask: taskContext inContext: aGtRrWorkerExecutionContext [
	"Run the task without any general error handling.
	Subclasses will overwrite / define how to handle exceptions.
	If the task execution doesn't complete, fork a process to notify of failure.  The fork is required to work around a bug in unwinding the stack and evaluating ensure: & ifCurtailed: blocks."
	| result |

	[ [ [ result := taskContext task timedRun ]
		on: GtRrTimeoutTaskError
		do: [ :ex | self notifyTaskTimedOut: taskContext inContext: aGtRrWorkerExecutionContext ].
	aGtRrWorkerExecutionContext worker
		taskDone: taskContext with: result.
	aGtRrWorkerExecutionContext signalTaskCompletion ]
		on: GtRrWorkerTerminationNotification
		do: [ :ex | ] ] ifCurtailed:
			[ [ self notifyTaskDidntComplete: taskContext 
					inContext: aGtRrWorkerExecutionContext ] fork ].
]
