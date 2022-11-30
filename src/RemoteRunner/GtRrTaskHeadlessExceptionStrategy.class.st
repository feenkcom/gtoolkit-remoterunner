"
GtRrTaskHeadlessExceptionStrategy is the normal strategy, which is to fail the task with the exception raised as the error.
"
Class {
	#name : #GtRrTaskHeadlessExceptionStrategy,
	#superclass : #GtRrTaskExceptionStrategy,
	#category : #'RemoteRunner-ExceptionHandling'
}

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy class >> leJsonV4Name [

	^ #gtRrTaskHeadlessExceptionStrategy
]

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy >> handleException: anException workerContext: aGtRrWorkerContext [

	aGtRrWorkerContext worker 
		taskFailed: aGtRrWorkerContext taskContext
		with: anException.
	aGtRrWorkerContext signalTaskCompletion.
]

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy >> handledExceptions [

	^ Error, UnhandledException
]

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy >> runTask: task inContext: aGtRrWorkerExecutionContext [

	[ super runTask: task inContext: aGtRrWorkerExecutionContext ]
		on: self handledExceptions
		do: [ :ex |
			self handleException: ex workerContext: aGtRrWorkerExecutionContext ].
]
