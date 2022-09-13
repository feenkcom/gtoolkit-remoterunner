Class {
	#name : #GtRrTask,
	#superclass : #Object,
	#instVars : [
		'constraint',
		'handoverTime',
		'startTime',
		'endTime',
		'resultReceivedTime',
		'workerAttributes',
		'result',
		'taskId',
		'errorDetails',
		'state',
		'taskTimeout',
		'retryStrategy'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrTask class >> leJsonV4Name [

	^ #remoteRunnerWorkerTask
]

{ #category : #visiting }
GtRrTask >> acceptVisitor: aVisitor [

	^ aVisitor visitTask: self
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
GtRrTask >> duration [
	^ (startTime isNotNil and: [ endTime isNotNil ]) 
		ifTrue: [ endTime - startTime ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
GtRrTask >> durationOnRunner [
	^ (handoverTime isNotNil and: [ resultReceivedTime isNotNil ]) 
		ifTrue: [ resultReceivedTime - handoverTime ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
GtRrTask >> endTime [
	"Answer the time at which the task was completed on the worker"
	<return: #Duration>

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

{ #category : #'accessing - pharolink' }
GtRrTask >> getSerialized [
	"Anser the receiver as a local value.
	For compatibility with PharoLinkProxyObject."

	^ self	
]

{ #category : #'accessing - pharolink' }
GtRrTask >> getValue [
	"Anser the receiver as a local value.
	For compatibility with PharoLinkProxyObject."

	^ self	
]

{ #category : #accessing }
GtRrTask >> gtConstraintFor: aView [
	<gtView>
	
	constraint ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Constraint';
		priority: 40;
		object: constraint;
		view: #gtLiveFor:
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

{ #category : #accessing }
GtRrTask >> handoverTime [

	^ handoverTime
]

{ #category : #accessing }
GtRrTask >> handoverTime: anObject [

	handoverTime := anObject
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
	self reset.
	constraint := GtRrTrueConstraint instance.
	retryStrategy := GtRrTaskNeverRetry uniqueInstance.
]

{ #category : #testing }
GtRrTask >> isFinished [

	^ endTime isNotNil
]

{ #category : #testing }
GtRrTask >> isNotStarted [

	^ state = #notStarted
]

{ #category : #running }
GtRrTask >> markTaskCancelled [
	"Mark the receiver cancelled.
	Cancellation is specifically terminating the task before it was started."

	endTime 
		ifNil: [ endTime := resultReceivedTime := DateAndTime now ]
		ifNotNil: [ resultReceivedTime := DateAndTime now ].
	errorDetails := (GtRrErrorDetails new
		errorMessage: 'Task cancelled before execution';
		setTrace).
	state := #cancelled.
]

{ #category : #running }
GtRrTask >> markTaskCompleted [

	resultReceivedTime := DateAndTime now.
	state := #completed.
]

{ #category : #running }
GtRrTask >> markTaskStarted [

	handoverTime := DateAndTime now.
	state := #started.
]

{ #category : #running }
GtRrTask >> markTaskTerminated [

	endTime 
		ifNil: [ endTime := resultReceivedTime := DateAndTime now ]
		ifNotNil: [ resultReceivedTime := DateAndTime now ].
	state := #terminated.
]

{ #category : #running }
GtRrTask >> markTaskTerminating [

	state := #terminating.
]

{ #category : #copying }
GtRrTask >> postCopy [
	"A copied task has its own UID and loses any existing result"

	super postCopy.
	self reset.
	taskId := UUID new asString.
	retryStrategy := retryStrategy copy.
]

{ #category : #printing }
GtRrTask >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	self printSupplementalOn: aStream.
	aStream << ', '.
	aStream print: taskId.
	aStream nextPut: $).
]

{ #category : #printing }
GtRrTask >> printSupplementalOn: aStream [

	aStream << self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #accessing }
GtRrTask >> reset [

	state := #notStarted.
	handoverTime := nil.
	startTime := nil.
	endTime := nil.
	resultReceivedTime := nil.
	workerAttributes := nil.
	result := nil.
	errorDetails := nil.
]

{ #category : #accessing }
GtRrTask >> result [

	^ result
]

{ #category : #accessing }
GtRrTask >> result: anObject [

	result := anObject
]

{ #category : #accessing }
GtRrTask >> resultReceivedTime [

	^ resultReceivedTime
]

{ #category : #accessing }
GtRrTask >> resultReceivedTime: anObject [

	^ resultReceivedTime := anObject
]

{ #category : #accessing }
GtRrTask >> retryStrategy [

	^ retryStrategy
]

{ #category : #accessing }
GtRrTask >> retryStrategy: anObject [

	retryStrategy := anObject
]

{ #category : #accessing }
GtRrTask >> retryTasks [
	"Answer the collection of tasks to be retried"

	^ retryStrategy retryTask: self.
]

{ #category : #running }
GtRrTask >> run [

	self subclassResponsibility
]

{ #category : #running }
GtRrTask >> runInImage [
	"Run the receiver in the current process.
	For testing only - no error handling, etc."

	self markTaskStarted.
	self result: self timedRun.
	self markTaskCompleted.
]

{ #category : #accessing }
GtRrTask >> serverDuration [
	^ (handoverTime isNotNil and: [ resultReceivedTime isNotNil ]) 
		ifTrue: [ resultReceivedTime - handoverTime ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
GtRrTask >> startTime [
	"Answer the time at which the task was started on the worker"
	<return: #Duration>

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

	| attributes duration |
	attributes := OrderedCollection new.
	duration := self duration.
	attributes add: #State -> self state.
	self hasErrors ifTrue: [ attributes add: #Error -> errorDetails ].
	result ifNotNil: [ 
		attributes add: #Result -> (result isCollection
				 ifTrue: [ 
				 result class name , '(' , result size printString , ')' ]
				 ifFalse: [ result ]) ].
	handoverTime ifNotNil: [ attributes add: #HandedToWorker -> handoverTime ].
	startTime ifNotNil: [ attributes add: #Started -> startTime ].
	endTime ifNotNil: [ attributes add: #Ended -> endTime ].
	duration ifNotNil: [ attributes add: #Duration -> duration ].
	(handoverTime isNotNil and: [ resultReceivedTime isNotNil ]) ifTrue: 
		[ attributes add: #ReceivedResultTime -> resultReceivedTime ].
	taskTimeout ifNotNil: [ attributes add: #Timeout -> taskTimeout ].
	attributes
		add: #ID -> taskId;
		add: 'Worker Attributes' -> workerAttributes.
	^ attributes
]

{ #category : #accessing }
GtRrTask >> summaryString [

	^ String streamContents: [ :stream |
		stream << 'Task Summary:'; cr.
		self summaryAttributes do: [ :assoc |
			stream
				<< (assoc key padRightTo: 30);
				<< (assoc value printString padLeftTo: 30);
				cr ] ]
]

{ #category : #printing }
GtRrTask >> supplementalDescription [
	^ String streamContents: [ :aStream |
		self printSupplementalOn: aStream ]
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

{ #category : #running }
GtRrTask >> timedRun [
	| runResult |

	startTime := DateAndTime now.
	runResult := self run.
	endTime := DateAndTime now.
	^ runResult.
]

{ #category : #accessing }
GtRrTask >> workerAttributes [

	^ workerAttributes
]

{ #category : #accessing }
GtRrTask >> workerAttributes: anObject [

	workerAttributes := anObject
]

{ #category : #accessing }
GtRrTask >> workerId [
	^ self workerAttributes ifNotNil: [ :attributes |
		attributes at: 'id' ifAbsent: [ nil ] ]
]

{ #category : #accessing }
GtRrTask >> workerIpAddress [
	^ self workerAttributes ifNotNil: [ :attributes |
		attributes at: 'workerIpAddress' ifAbsent: [ nil ] ]
]
