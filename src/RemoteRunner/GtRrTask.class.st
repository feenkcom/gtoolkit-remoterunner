Class {
	#name : #GtRrTask,
	#superclass : #Object,
	#instVars : [
		'constraint',
		'result',
		'taskId',
		'taskTimeout',
		'retryStrategy',
		'executionData'
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

{ #category : #initialization }
GtRrTask >> createResourceReport [
	^ GtVmStatisticsReportsDiff new
]

{ #category : #accessing }
GtRrTask >> duration [
	^ (self startTime isNotNil and: [ self endTime isNotNil ]) 
		ifTrue: [ self endTime - self startTime ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
GtRrTask >> durationOnRunner [
	^ (self handoverTime isNotNil and: [ self resultReceivedTime isNotNil ]) 
		ifTrue: [ self resultReceivedTime - self handoverTime ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
GtRrTask >> endTime [
	"Answer the time at which the task was completed on the worker"
	<return: #Duration>

	^ self executionData endTime
]

{ #category : #accessing }
GtRrTask >> endTime: aDuration [

	self executionData endTime: aDuration
]

{ #category : #accessing }
GtRrTask >> errorDetails [
	<return: #GtRrErrorDetails>

	^ self executionData errorDetails
]

{ #category : #accessing }
GtRrTask >> errorDetails: aGtErrorDetails [
	"Set the error details of the receiver.
	Asynchronous events may cause multiple attempts at setting the details, use the first one"

	self executionData errorDetails: aGtErrorDetails
]

{ #category : #accessing }
GtRrTask >> executionData [

	^ executionData ifNil: [ executionData := GtRrTaskExecutionData new ].
]

{ #category : #'private - accessing' }
GtRrTask >> executionData: aGtRrTaskExecutionData [
	"Only used for serialisation"

	executionData := aGtRrTaskExecutionData 
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
		  object: [ result ifNil: [ self errorDetails ifNil: [ '<No Result>' ] ] ];
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

	self errorDetails ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Trace';
		priority: 20;
		object: [ self errorDetails ];
		view: #gtTraceFor:
]

{ #category : #ui }
GtRrTask >> gtWorkerAttributesFor: aView [
	<gtView>

	self workerAttributes ifNil: [ ^ aView empty ].
	^ aView columnedList
		  title: 'Worker Attributes';
		  priority: 40;
		  items: [ self workerAttributes associations sorted: [ :a :b | a key < b key ] ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  send: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #accessing }
GtRrTask >> handoverTime [

	^ self executionData handoverTime
]

{ #category : #accessing }
GtRrTask >> handoverTime: anObject [

	self executionData handoverTime: anObject
]

{ #category : #testing }
GtRrTask >> hasCompleted [

	^ self state = #completed or: [ self state = #terminated ]
]

{ #category : #testing }
GtRrTask >> hasErrors [
	"Answer a boolean indicating if the receiver failed to execute successfully"

	^ self errorDetails isNotNil
]

{ #category : #accessing }
GtRrTask >> initialize [

	super initialize.
	self reset.
	constraint := GtRrTrueConstraint instance.
	retryStrategy := GtRrTaskNeverRetry uniqueInstance.
	taskId := UUID new asString.
]

{ #category : #testing }
GtRrTask >> isFinished [

	^ self endTime isNotNil
]

{ #category : #testing }
GtRrTask >> isNotStarted [

	^ self state = #notStarted
]

{ #category : #running }
GtRrTask >> markTaskCancelled [
	"Mark the receiver cancelled.
	Cancellation is specifically terminating the task before it was started."
	| now |

	now := DateAndTime now.
	self endTime ifNil: 
		[ self endTime: now.
		self resultReceivedTime: now ]
	ifNotNil: 
		[ self resultReceivedTime: now ].
	self errorDetails: (GtRrErrorDetails new
		errorMessage: 'Task cancelled before execution';
		setTrace).
	self state: #cancelled.
]

{ #category : #running }
GtRrTask >> markTaskCompleted [

	self resultReceivedTime: DateAndTime now.
	self state: #completed.
]

{ #category : #running }
GtRrTask >> markTaskStarted [

	self handoverTime: DateAndTime now.
	self state: #started.
]

{ #category : #running }
GtRrTask >> markTaskTerminated [
	| now |

	now := DateAndTime now.
	self endTime ifNil: 
		[ self endTime: now.
		self resultReceivedTime: DateAndTime now ]
	ifNotNil: 
		[ self resultReceivedTime: DateAndTime now ].
	self state: #terminated.
]

{ #category : #running }
GtRrTask >> markTaskTerminating [

	self state: #terminating.
]

{ #category : #copying }
GtRrTask >> postCopy [
	"A copied task has its own UID and loses any existing result"

	super postCopy.
	self reset.
	taskId := UUID new asString.
	retryStrategy := retryStrategy copy.
	executionData := executionData copy.
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

	result := nil.

]

{ #category : #accessing }
GtRrTask >> resourceReportIfPresent: aPresentBlock ifAbsent: anAbsentBlock [
	^ self executionData resourceReport 
		ifNil: [ anAbsentBlock value ]
		ifNotNil: [ :report | aPresentBlock cull: report ]
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

	^ self executionData resultReceivedTime
]

{ #category : #accessing }
GtRrTask >> resultReceivedTime: anObject [

	self executionData resultReceivedTime: anObject
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

	self result: self timedRun.

]

{ #category : #accessing }
GtRrTask >> serverDuration [

	^ (self handoverTime isNotNil and: [ self resultReceivedTime isNotNil ]) 
		ifTrue: [ self resultReceivedTime - self handoverTime ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
GtRrTask >> startTime [
	"Answer the time at which the task was started on the worker"
	<return: #Duration>

	^ self executionData startTime
]

{ #category : #accessing }
GtRrTask >> startTime: anObject [

	self executionData startTime: anObject
]

{ #category : #accessing }
GtRrTask >> state [
	"Answer a Symbol indicating the inferred state of the receiver.
	One of: #notStarted, #started, #cancelled, #terminating, #terminated, #completed.
	The errorDetails are used to determine if the task completed successfully, why and where it was terminated, etc."

	^ self executionData state
]

{ #category : #private }
GtRrTask >> state: aSymbol [
	"Set the state"

	self executionData state: aSymbol
]

{ #category : #printing }
GtRrTask >> stateDescription [
	^ String streamContents: [ :aStream |
		self printSupplementalOn: aStream ]
]

{ #category : #ui }
GtRrTask >> summaryAttributes [

	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	| attributes duration |
	attributes := OrderedCollection new.
	duration := self duration.
	attributes add: #State -> self state.
	self hasErrors ifTrue: [ attributes add: #Error -> self errorDetails ].
	result ifNotNil: 
		[ attributes add: #Result -> (result isCollection
			ifTrue: [ result class name , '(' , result size printString , ')' ]
			ifFalse: [ result ]) ].
	self startTime ifNotNil: [ attributes add: #Started -> self startTime ].
	self endTime ifNotNil: [ attributes add: #Ended -> self endTime ].
	duration ifNotNil: [ attributes add: #Duration -> duration ].
	self handoverTime ifNotNil: [ attributes add: #HandedToWorker -> self handoverTime ].
	(self handoverTime isNotNil and: [ self resultReceivedTime isNotNil ]) ifTrue: 
		[ attributes add: #ReceivedResultTime -> self resultReceivedTime ].
	self executionData resourceReport ifNotNil:
		[ :report | attributes add: #ResourceReport -> report ].
	taskTimeout ifNotNil: [ attributes add: #Timeout -> taskTimeout ].
	attributes add: #ID -> taskId.
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
	| runResult resourceReport |

	resourceReport := self createResourceReport.
	resourceReport recordSourceReport.
	self startTime: DateAndTime now.
	runResult := [ self run ] ensure:
		[ self endTime: DateAndTime now.
		resourceReport recordTargetReport.
		self executionData resourceReport: resourceReport ].
	^ runResult.
]

{ #category : #accessing }
GtRrTask >> totalGCTime [
	^ self 
		resourceReportIfPresent: [ :aReport | aReport totalGcTimeDiff ] 
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrTask >> vmMemorySizeAtCompletion [
	^ self 
		resourceReportIfPresent: [ :aReport | aReport vmMemorySizeAtEnd ] 
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrTask >> vmStatisticsAtCompletion [  
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport targetReport ] 
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrTask >> vmStatisticsAtStart [
	^ self
		resourceReportIfPresent: [ :aReport | 
			aReport sourceReport ] 
		ifAbsent: [ nil ]
]

{ #category : #accessing }
GtRrTask >> workerAttributes [

	^ self executionData workerAttributes
]

{ #category : #accessing }
GtRrTask >> workerAttributes: anObject [

	self executionData workerAttributes: anObject
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
