"
GtRrTaskStandaloneExceptionStrategy catches assertion failures and errors and populates the tasks error details.
"
Class {
	#name : #GtRrTaskStandaloneExceptionStrategy,
	#superclass : #GtRrTaskExceptionStrategy,
	#category : #'RemoteRunner-ExceptionHandling'
}

{ #category : #'as yet unclassified' }
GtRrTaskStandaloneExceptionStrategy >> handledExceptions [

	^ Error
]

{ #category : #'as yet unclassified' }
GtRrTaskStandaloneExceptionStrategy >> handleException: anError workerContext: aGtRrWorkerContext [
	| infoException executionData taskContext |

	taskContext := aGtRrWorkerContext taskContext.
	infoException := (anError class == UnhandledError)
		ifTrue: [ anError exception ]
		ifFalse: [ anError ].
	executionData := taskContext task executionData
		endTime: taskContext endTime;
		resourceReport: taskContext executionData resourceReport;
		errorDetails: (GtRrErrorDetails new
			errorMessage: (anError messageText ifEmpty:
				[ anError printString ]);
			trace: anError stackString).
	aGtRrWorkerContext signalTaskCompletion.
]

{ #category : #'as yet unclassified' }
GtRrTaskStandaloneExceptionStrategy >> runTask: taskContext inContext: aGtRrWorkerExecutionContext [
	"Run the task without any general error handling.
	Subclasses will overwrite / define how to handle exceptions.
	If the task execution doesn't complete, fork a process to notify of failure.  The fork is required to work around a bug in unwinding the stack and evaluating ensure: & ifCurtailed: blocks."
	| result |

	[ result := taskContext task timedRun ]
		on: self handledExceptions
		do: [ :ex |
			self handleException: ex workerContext: aGtRrWorkerExecutionContext ].
	aGtRrWorkerExecutionContext signalTaskCompletion
]
