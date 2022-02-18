Class {
	#name : #GtRrTask,
	#superclass : #Object,
	#instVars : [
		'constraint',
		'startTime',
		'endTime',
		'workerAttributes',
		'result',
		'taskId',
		'errorDetails',
		'state',
		'taskTimeout'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrTask class >> leJsonV4Name [

	^ #remoteRunnerWorkerTask
]

{ #category : #converting }
GtRrTask >> asJob [
	"Answer a GtRrTasksJob with the receiver as its single task"

	^ GtRrTasksJob tasks: { self }
]

{ #category : #'private - utility' }
GtRrTask >> classWithName: aString [

	^ (aString endsWith: ' class')
		ifTrue: [ (self class environment at: (aString copyFrom: 1 to: aString size - 6) asSymbol) class ]
		ifFalse: [ self class environment at: aString asSymbol ].
]

{ #category : #accessing }
GtRrTask >> constraint [

	^ constraint
]

{ #category : #accessing }
GtRrTask >> constraint: anObject [

	constraint := anObject
]

{ #category : #accessing }
GtRrTask >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrTask >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrTask >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrTask >> errorDetails: aGtErrorDetails [
	"Set the error details of the receiver.
	Asynchronous events may cause multiple attempts at setting the details, use the first one"

	errorDetails ifNotNil: [ ^ self ].
	errorDetails := aGtErrorDetails
]

{ #category : #ui }
GtRrTask >> gtResultFor: aView [
	<gtView>
	| view |

	view := result isCollection
		ifTrue: [ #gtItemsFor: ]
		ifFalse: [ #gtLiveFor: ].
	^ aView forward
		  title: 'Result';
		  priority: 20;
		  object: [ result ifNil: [ errorDetails ifNil: [ '<No Result>' ] ] ];
		  view: view;
		  actionUpdateButton
]

{ #category : #ui }
GtRrTask >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		send: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrTask >> gtTraceFor: aView [
	<gtView>

	errorDetails ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Trace';
		priority: 20;
		object: [ errorDetails ];
		view: #gtTraceFor:
]

{ #category : #ui }
GtRrTask >> gtWorkerAttributesFor: aView [
	<gtView>

	workerAttributes ifNil: [ ^ aView empty ].
	^ aView columnedList
		  title: 'Worker Attributes';
		  priority: 40;
		  items: [ workerAttributes associations sorted: [ :a :b | a key < b key ] ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  send: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #testing }
GtRrTask >> hasCompleted [

	^ state = #completed or: [ state = #terminated ]
]

{ #category : #testing }
GtRrTask >> hasErrors [
	"Answer a boolean indicating if the receiver failed to execute successfully"

	^ errorDetails isNotNil
]

{ #category : #accessing }
GtRrTask >> initialize [

	super initialize.
	taskId := UUID new asString.
	state := #notStarted.
	constraint := GtRrTrueConstraint instance.
]

{ #category : #testing }
GtRrTask >> isFinished [

	^ endTime isNotNil
]

{ #category : #running }
GtRrTask >> markTaskCancelled [
	"Mark the receiver cancelled.
	Cancellation is specifically terminating the task before it was started."

	endTime := DateAndTime now.
	errorDetails := (GtRrErrorDetails new
		errorMessage: 'Task cancelled before execution';
		setTrace).
	state := #cancelled.
]

{ #category : #running }
GtRrTask >> markTaskCompleted [

	endTime := DateAndTime now.
	state := #completed.
]

{ #category : #running }
GtRrTask >> markTaskStarted [

	startTime := DateAndTime now.
	state := #started.
]

{ #category : #running }
GtRrTask >> markTaskTerminated [

	endTime := DateAndTime now.
	state := #terminated.
]

{ #category : #running }
GtRrTask >> markTaskTerminating [

	state := #terminating.
]

{ #category : #printing }
GtRrTask >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	self printSupplementalOn: aStream.
	aStream nextPut: $).
]

{ #category : #printing }
GtRrTask >> printSupplementalOn: aStream [

	aStream << self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #accessing }
GtRrTask >> result [

	^ result
]

{ #category : #accessing }
GtRrTask >> result: anObject [

	result := anObject
]

{ #category : #running }
GtRrTask >> run [

	self subclassResponsibility
]

{ #category : #'private - running' }
GtRrTask >> runInImage [
	"Run the receiver in the current process.
	For testing only - no error handling, etc."

	result := self run.
]

{ #category : #accessing }
GtRrTask >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrTask >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
GtRrTask >> state [
	"Answer a Symbol indicating the inferred state of the receiver.
	One of: #notStarted, #started, #cancelled, #terminating, #terminated, #completed.
	The errorDetails are used to determine if the task completed successfully, why and where it was terminated, etc."

	^ state
]

{ #category : #private }
GtRrTask >> state: aSymbol [
	"Set the state.
	Only used by object serialisation"
	
	state := aSymbol
]

{ #category : #ui }
GtRrTask >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"
	| attributes |

	attributes := OrderedCollection new.
	attributes add: #State -> self state.
	self hasErrors ifTrue:
		[ attributes add: #Error -> errorDetails ].
	startTime ifNotNil:
		[ attributes add: #Started -> startTime ].
	endTime ifNotNil:
		[ attributes add: #Ended -> endTime ].
	taskTimeout ifNotNil:
		[ attributes add: #Timeout -> taskTimeout ].
	attributes
		add: #ID -> taskId;
		add: 'Worker Attributes' -> workerAttributes.
	^ attributes
]

{ #category : #accessing }
GtRrTask >> taskId [

	^ taskId
]

{ #category : #accessing }
GtRrTask >> taskId: anObject [

	taskId := anObject
]

{ #category : #accessing }
GtRrTask >> taskTimeout [
	<return: #Duration>

	^ taskTimeout
]

{ #category : #accessing }
GtRrTask >> taskTimeout: aDuration [

	taskTimeout := aDuration
]

{ #category : #accessing }
GtRrTask >> workerAttributes [

	^ workerAttributes
]

{ #category : #accessing }
GtRrTask >> workerAttributes: anObject [

	workerAttributes := anObject
]
