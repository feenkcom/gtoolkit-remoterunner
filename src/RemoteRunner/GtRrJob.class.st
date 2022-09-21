"
A {{gtClass:GtRrJob}} is the object submitted to a remote runner for execution.  It answers a collection of tasks to be executed by the workers, and holds the results of the tasks.  Partial results are announced as each task is completed.
Since task retry may split tasks out, e.g. see {{gtClass:GtRrTaskTestRetry}}, the number of results may be different to the number of tasks.

Implementation Details:

- An errorCount is kept up to date during execution for performance reasons.
  The result count isn't required as an instance variable as OrderedCollections know their size without scanning.
"
Class {
	#name : #GtRrJob,
	#superclass : #Object,
	#traits : 'TGtWithAnnouncementsQueue',
	#classTraits : 'TGtWithAnnouncementsQueue classTrait',
	#instVars : [
		'results',
		'announcer',
		'id',
		'state',
		'startTime',
		'endTime',
		'jobTimeout',
		'taskTimeout',
		'errorDetails',
		'errorCount',
		'name',
		'creationTime'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #'job submission' }
GtRrJob class >> exampleNames: anArray [
	"Answer a job with the supplied test names"

	^ GtRrChecksJob exampleNames: anArray
]

{ #category : #'instance creation' }
GtRrJob class >> fromSton: stonReader [

	| signal |

	stonReader parseListDo: [ :each :idx |
		idx = 1 ifFalse: [ self error: 'Invalid STON' ].
		signal := self fromStonDictionary: each ].
	^signal
]

{ #category : #'instance creation' }
GtRrJob class >> fromStonDictionary: aDictionary [
	| object |
	
	object := self new.
	aDictionary keysAndValuesDo: [ :key :value |
		object perform: key asMutator with: value ].
	^ object
]

{ #category : #jsonV4 }
GtRrJob class >> leJsonV4AttributeMapping [
	"Answer the Array of attribute to store keys.
	Subclasses should override this with their attributes."

	^ { 
		#results -> #results.
		#id -> #id.
		#state -> #state.
		#startTime -> #startTime.
		#endTime -> #endTime.
		#creationTime -> #creationTime.
		#jobTimeout -> #jobTimeout.
		#taskTimeout -> #taskTimeout.
		#errorDetails -> #errorDetails.
	 } asOrderedCollection.
]

{ #category : #jsonV4 }
GtRrJob class >> leJsonV4Name [

	^ #gtRrJob
]

{ #category : #'job submission' }
GtRrJob class >> script: aString [
	"Answer a job with a single script task"

	^ GtRrTasksJob tasks: { (GtRrScriptTask script: aString) }
]

{ #category : #'job submission' }
GtRrJob class >> sunitTestNames: anArray [
	"Answer a job with the supplied test names"

	^ GtRrChecksJob sunitTestNames: anArray
]

{ #category : #accessing }
GtRrJob >> addResult: aGtRrTask [
	"Add the completed task to the results"
	| hasErrors |

	results add: aGtRrTask.
	hasErrors := aGtRrTask hasErrors.
	hasErrors ifTrue: [ errorCount := errorCount + 1 ].
	self announce: (hasErrors
		ifTrue: [ GtRrTaskFailedAnnouncement task: aGtRrTask ]
		ifFalse: [ GtRrTaskCompletedAnnouncement task: aGtRrTask ])
]

{ #category : #announcer }
GtRrJob >> announce: anAnnouncement [

	^ self announcer announce: anAnnouncement
]

{ #category : #accessing }
GtRrJob >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #converting }
GtRrJob >> asDictionary [
	| dict |

	dict := Dictionary new.
	self class allInstVarNames do: [ :name |
		dict at: name put: (name value: self) ].
	dict removeKey: #announcer.
	^ dict
]

{ #category : #'private - running' }
GtRrJob >> cancelJob [
	"Mark the receiver as cancelled (before being started).
	This not be called by the end user, but via {{gtMethod:GtRemoteRunner>>terminateJobId:}}"

	self markJobCancelled.

]

{ #category : #accessing }
GtRrJob >> creationTime [

	^ creationTime
]

{ #category : #accessing }
GtRrJob >> creationTime: anObject [

	creationTime := anObject
]

{ #category : #accessing }
GtRrJob >> endTime [

	^ endTime
]

{ #category : #'private - serialization' }
GtRrJob >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrJob >> errorCount [

	^ errorCount
]

{ #category : #accessing }
GtRrJob >> errorDetails [
	"If set, the error details will contain the overall reason for the failure of the job.
	Some individual tasks may still successfully complete."
	<return: #GtRrErrorDetails or: nil>

	^ errorDetails
]

{ #category : #accessing }
GtRrJob >> errorDetails: aGtErrorDetails [
	"Set the error details of the receiver.
	Asynchronous events may cause multiple attempts at setting the details, use the first one"

	errorDetails ifNotNil: [ ^ self ].
	errorDetails := aGtErrorDetails
]

{ #category : #'accessing - pharolink' }
GtRrJob >> getSerialized [
	"Anser the receiver as a local value.
	For compatibility with PlpoGtRrJob."

	^ self	
]

{ #category : #'accessing - pharolink' }
GtRrJob >> getValue [
	"Anser the receiver as a local value.
	For compatibility with PlpoGtRrJob."

	^ self	
]

{ #category : #ui }
GtRrJob >> gtErrorsFor: aView [
	<gtView>

	^ aView list
		title: 'Errors';
		priority: 16;
		items: [ self resultsWithErrors ];
		updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ]
]

{ #category : #ui }
GtRrJob >> gtResultsFor: aView [
	<gtView>

	^ aView list
		title: 'Results';
		priority: 15;
		items: [ results ];
		itemText: [ :item | item result ifNil: [ item errorDetails ] ];
		updateWhen: GtRrJobAnnouncement in: [ self announcer ]
]

{ #category : #ui }
GtRrJob >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrJob >> gtTasksFor: aView [

	<gtView>
	^ aView list
		  title: 'Tasks';
		  priority: 50;
		  items: [ self tasks ];
		  updateWhen: GtRrJobAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #testing }
GtRrJob >> hasErrors [
	"Answer a boolean indicating whether the receiver has tasks that failed"

	^ errorCount > 0
]

{ #category : #announcer }
GtRrJob >> hasSubscriber: anObject [

	^ self announcer hasSubscriber: anObject
]

{ #category : #accessing }
GtRrJob >> id [

	^ id
]

{ #category : #'private - serialization' }
GtRrJob >> id: anObject [

	id := anObject
]

{ #category : #initialization }
GtRrJob >> initialize [

	super initialize.
	self reset.
]

{ #category : #testing }
GtRrJob >> isFinished [

	^ state == #completed
]

{ #category : #testing }
GtRrJob >> isStarted [

	^ state == #started
]

{ #category : #accessing }
GtRrJob >> jobName [
	^ self name
]

{ #category : #accessing }
GtRrJob >> jobTimeout [
	<return: #Duration>

	^ jobTimeout
]

{ #category : #accessing }
GtRrJob >> jobTimeout: aDuration [

	jobTimeout := aDuration
]

{ #category : #'private - running' }
GtRrJob >> markJobCancelled [

	state := #cancelled.
	self announce: (GtRrJobCancelledAnnouncement job: self).

]

{ #category : #'private - running' }
GtRrJob >> markJobCompleted [

	self isFinished ifTrue: [ ^ self ].
	endTime := DateAndTime now.
	state := #completed.
	self announce: (GtRrJobCompletedAnnouncement job: self).

]

{ #category : #'private - running' }
GtRrJob >> markJobStarted [

	self isStarted ifTrue: [ ^ self ].
	startTime := DateAndTime now.
	state := #started.
	self announce: (GtRrJobStartedAnnouncement job: self).

]

{ #category : #'private - running' }
GtRrJob >> markJobTerminating [

	state := #terminating.

]

{ #category : #accessing }
GtRrJob >> name [

	^ name ifNil: [ self printString ]
]

{ #category : #accessing }
GtRrJob >> name: anObject [

	name := anObject
]

{ #category : #copying }
GtRrJob >> postCopy [
	"A copied job has its own UID and tasks (as a task holds its results)"

	self reset.

]

{ #category : #printing }
GtRrJob >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].
	aStream
		nextPut: $).
]

{ #category : #'announcer - subscription' }
GtRrJob >> removeSubscription: subscription [
	"Remove the given subscription from the receiver"

	^ self announcer removeSubscription: subscription
]

{ #category : #initialization }
GtRrJob >> reset [

	id := UUID new asString.
	results := OrderedCollection new.
	errorCount := 0.
	state := #notStarted.
	announcer := nil.
	startTime := nil.
	endTime := nil.
	errorDetails := nil.
	creationTime := DateAndTime now.
]

{ #category : #accessing }
GtRrJob >> resultCount [

	^ results size
]

{ #category : #accessing }
GtRrJob >> results [

	^ results
]

{ #category : #'private - serialization' }
GtRrJob >> results: aCollection [
	"OrderedCollections are serialised as Arrays, so need to be converted back"

	results := aCollection asOrderedCollection
]

{ #category : #accessing }
GtRrJob >> resultsWithErrors [
	"Answer the subset of results that have errors"

	^ results select: #hasErrors
]

{ #category : #'private - running' }
GtRrJob >> runInImage [

	^ (GtRrJobContext new 
		job: self;
		remoteRunner: GtRemoteRunner new) runInImage.
]

{ #category : #ui }
GtRrJob >> showExamplesProgressNotification [
	"Open a global notification showing the progress of the receiver assuming all tasks are exemples / test related"

	^ GtRrExamplesProgressNotification job: self.
]

{ #category : #ui }
GtRrJob >> showProgressNotification [
	"Open a global notification showing the progress of the receiver"

	^ GtRrJobProgressNotification job: self.
]

{ #category : #accessing }
GtRrJob >> startTime [

	^ startTime
]

{ #category : #'private - serialization' }
GtRrJob >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
GtRrJob >> state [
	"One of: #notStarted, #started, #cancelled, #completed"
	<return: #Symbol>

	^ state
]

{ #category : #'private - serialization' }
GtRrJob >> state: anObject [

	state := anObject
]

{ #category : #'ston persistence' }
GtRrJob >> stonOn: stonWriter [

	stonWriter writeObject: self streamShortList: [ :array |
		array add: self asDictionary ]
]

{ #category : #accessing }
GtRrJob >> successfulCount [

	^ results size - errorCount
]

{ #category : #ui }
GtRrJob >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"
	| attributes |

	attributes := OrderedCollection new.
	attributes 
		add: #State -> self state;
		add: #Tasks -> self tasks size;
		add: #Results -> results size;
		add: #Errors -> errorCount;
		add: 'Start Time' -> startTime;
		add: 'End Time' -> endTime.
	(startTime isNotNil and: [ endTime isNotNil ]) ifTrue:
		[ attributes add: 'Duration' -> (endTime - startTime) humanReadablePrintString ].
	self taskExecutionTime ifNotNil:
		[ :time | attributes add: 'Task Execution Time' -> time humanReadablePrintString ].
	attributes
		add: 'Job Timeout' -> jobTimeout;
		add: 'Task Timeout' -> taskTimeout;
		add: 'Id' -> self id.
	^ attributes
]

{ #category : #accessing }
GtRrJob >> summaryString [

	^ String streamContents: [ :stream |
		stream << 'Job Summary:'; cr.
		self summaryAttributes do: [ :assoc |
			stream
				<< (assoc key padRightTo: 30);
				<< (assoc value printString padLeftTo: 30);
				cr ] ]
]

{ #category : #accessing }
GtRrJob >> taskCount [

	^ self tasks size.
]

{ #category : #accessing }
GtRrJob >> taskExecutionTime [
	"Answer the time actually spent by the workers executing the task (excludes failed tasks and communication & scheduling overheads)."
	<return: #Duration or: nil>

	self isFinished ifFalse: [ ^ nil ].

	^ results inject: Duration zero into: [ :s :v | 
		v
			ifNil: [ s ]
			ifNotNil: [ s + ((v duration
				ifNil: [ Duration zero ])) ] ].
]

{ #category : #accessing }
GtRrJob >> taskTimeout [
	<return: #Duration>

	^ taskTimeout
]

{ #category : #accessing }
GtRrJob >> taskTimeout: aDuration [

	taskTimeout := aDuration
]

{ #category : #accessing }
GtRrJob >> tasks [
	"Answer the collection of tasks to be executed"
	<return: #SequenceableCollection>

	^ self subclassResponsibility 
]

{ #category : #accessing }
GtRrJob >> tasksFor: aGtRemoteRunner [
	"Special jobs may depend on the remote runner to create the tasks,
	e.g. the code sync wants a task per worker.
	Such subclasses can override this method."

	^ self tasks.
]

{ #category : #'announcer - subscription' }
GtRrJob >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"
	
	^ self announcer unsubscribe: anObject
]

{ #category : #'announcer - subscription' }
GtRrJob >> weak [
	"announcer weak subscribe: foo"

	^ self announcer weak
]

{ #category : #'announcer - subscription' }
GtRrJob >> when: anAnnouncementClass do: aValuable [
	"Declare that when anAnnouncementClass is raised, aValuable is executed.  Pay attention that ushc method as well as when:do: should not be used on weak announcer since the block holds the receiver and more strongly."

		^ self announcer when: anAnnouncementClass do: aValuable
]

{ #category : #'announcer - subscription' }
GtRrJob >> when: anAnnouncementClass do: aValuable for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, aValuable is executed and define the subscriber."

	^ (self when: anAnnouncementClass do: aValuable) subscriber: aSubscriber; yourself.
]

{ #category : #'announcer - subscription' }
GtRrJob >> when: anAnnouncementClass doOnce: aValuable for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, aValuable is executed and define the subscriber.
	A valuable is executed ONCE, and then a subscriber gets unsubscribed"

	^ self
		when: anAnnouncementClass
		do: [ :anAnnouncement |
			self unsubscribe: aSubscriber.
			aValuable cull: anAnnouncement ]
		for: aSubscriber
]

{ #category : #'announcer - subscription' }
GtRrJob >> when: anAnnouncementClass send: aSelector to: anObject [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector.
    When the message expects one argument (eg #fooAnnouncement:) the announcement is passed as argument.
    When the message expects two arguments (eg #fooAnnouncement:announcer:) both the announcement and the announcer 
    are passed as argument"

		^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : #'announcer - subscription' }
GtRrJob >> when: anAnnouncementClass send: aSelector to: anObject for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector."

	^ (self when: anAnnouncementClass send: aSelector to: anObject) subscriber: aSubscriber.
]
