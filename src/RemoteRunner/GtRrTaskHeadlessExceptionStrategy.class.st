"
GtRrTaskHeadlessExceptionStrategy is the normal strategy, which is to fail the task with the exception raised as the error.
"
Class {
	#name : #GtRrTaskHeadlessExceptionStrategy,
	#superclass : #GtRrTaskExceptionStrategy,
	#classVars : [
		'StartMcpServer'
	],
	#category : #'RemoteRunner-ExceptionHandling'
}

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy class >> leJsonV4Name [

	^ #gtRrTaskHeadlessExceptionStrategy
]

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy class >> startMcpServer [
	"Answer a boolean indicating whether an MCP server should be started when an exception is caught.
	This is experimental functionality and may be removed."

	^ StartMcpServer ifNil: [ false ]
]

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy class >> startMcpServer: aBoolean [

	StartMcpServer := aBoolean.
	StringSignal emit: 'Started MCP server on error: ',
			aBoolean printString.
]

{ #category : #accessing }
GtRrTaskHeadlessExceptionStrategy >> handleException: anException workerContext: aGtRrWorkerContext [
	| infoException |

	infoException := (anException class == UnhandledError)
		ifTrue: [ anException exception ]
		ifFalse: [ anException ].
	infoException logStackToFile.
	self class startMcpServer ifTrue:
		[ self startMcpServerWith: anException context: aGtRrWorkerContext ].
	aGtRrWorkerContext worker 
		taskFailed: aGtRrWorkerContext taskContext
		with: infoException.
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

{ #category : #private }
GtRrTaskHeadlessExceptionStrategy >> startMcpServerWith: anException context: aGtRrWorkerContext [
	| onDemandServer semaphore debugInfo message |

	aGtRrWorkerContext stopTimeout.
	onDemandServer := GtLOnDemandMcpServer instance.
	semaphore := Semaphore new.
	debugInfo := {
		'testException' -> anException.
		'workerContext' -> aGtRrWorkerContext.
		'holdingSemaphore' -> semaphore.
		} asDictionary.
	onDemandServer objectStorage
		addNewObject: debugInfo reason:
			(GtLStoredObjectStringReason text: 'task_', aGtRrWorkerContext taskContext taskId asString).
	message := String streamContents: [ :stream |
		stream
			<< 'MCP server available on port: ';
			print: onDemandServer port;
			<< ', running: ';
			print: onDemandServer isRunning;
			<< ' on: ';
			print: anException printString. ].
	Stdio stdout
		<< message;
		lf;
		flush.
	StringSignal emit: message.
	Stdio stdout
		<< Time now printString;
		<< ' about to wait on semaphore';
		<< aGtRrWorkerContext taskContext taskId asString;
		lf; flush.
	semaphore wait.
	Stdio stdout
		<< Time now printString;
		<< ' finished wait on semaphore ';
		<< aGtRrWorkerContext taskContext taskId asString;
		lf; flush.
]
