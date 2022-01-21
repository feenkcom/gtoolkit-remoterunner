"
A GtRrJob is the object submitted to a remote runner for execution.  It answers a collection of tasks to be executed by the workers, and holds the results of the tasks.  Partial results are announced as each task is completed.
"
Class {
	#name : #GtRrJob,
	#superclass : #GtRrTask,
	#instVars : [
		'tasks',
		'announcer'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrJob >> addResult: aGtRrTask [
	"Add the completed task to the results"

	results add: aGtRrTask.
	self announce: (aGtRrTask hasErrors
		ifTrue: [ GtRrTaskFailedAnnouncement task: aGtRrTask ]
		ifFalse: [ GtRrTaskFinishedAnnouncement task: aGtRrTask ])
]

{ #category : #announcer }
GtRrJob >> announce: anAnnouncement [

	^ self announcer announce: anAnnouncement
]

{ #category : #accessing }
GtRrJob >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #'private - running' }
GtRrJob >> cancel [

	"Mark the receiver as cancelled (before being started).
	This not be called by the end user, but via {{gtMethod:GtRemoteRunner>>terminateJobId:}}"

	state := #cancelled.
	self announce: (GtRrJobCancelledAnnouncement job: self)
]

{ #category : #'private - running' }
GtRrJob >> complete [

	endTime := DateAndTime now.
	state := #completed.
	self announce: (GtRrJobCompletedAnnouncement job: self).

]

{ #category : #accessing }
GtRrJob >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrJob >> errorDetails [
	"If set, the error details will contain the overall reason for the failure of the job.
	Some individual tasks may still successfully complete."
	<return: #GtRrError or: nil>

	^ errorDetails
]

{ #category : #accessing }
GtRrJob >> errorDetails: aGtErrorDetails [
	"Set the error details of the receiver.
	Asynchronous events may cause multiple attempts at setting the details, use the first one"

	errorDetails ifNotNil: [ ^ self ].
	errorDetails := aGtErrorDetails
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
		  updateWhen: GtRrJobAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrJob >> gtTasksFor: aView [
	<gtView>

	^ aView list
		title: 'Tasks';
		priority: 50;
		items: [ self tasks ]
]

{ #category : #testing }
GtRrJob >> hasErrors [
	"Answer a boolean indicating whether the receiver has tasks that failed"

	^ results anySatisfy: [ :task | task hasErrors ]
]

{ #category : #announcer }
GtRrJob >> hasSubscriber: anObject [

	^ self announcer hasSubscriber: anObject
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

{ #category : #accessing }
GtRrJob >> results [

	^ results
]

{ #category : #accessing }
GtRrJob >> resultsWithErrors [
	"Answer the subset of results that have errors"

	^ results select: #hasErrors
]

{ #category : #'private - running' }
GtRrJob >> start [

	startTime := DateAndTime now.
	state := #started.
	self announce: (GtRrJobStartedAnnouncement job: self).

]

{ #category : #accessing }
GtRrJob >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrJob >> state [
	"One of: #notStarted, #started, #cancelled, #completed"
	<return: #Symbol>

	^ state
]

{ #category : #ui }
GtRrJob >> summaryAttributes [

	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ OrderedCollection new
		  add: #State -> self state;
		  add: #Tasks -> self tasks size;
		  add: #Results -> results size;
		  add: #Errors -> self resultsWithErrors size;
		  add: #Start -> startTime;
		  add: #End -> endTime;
		  add: #Duration -> ((startTime isNotNil and: [ endTime isNotNil ])
					   ifTrue: [ (endTime - startTime) humanReadablePrintString ]
					   ifFalse: [ nil ]);
		  add: #Timeout -> timeout;
		  add: #Id -> self id;
		  yourself
]

{ #category : #accessing }
GtRrJob >> tasks [
	"Answer the collection of tasks to be executed"
	<return: #SequenceableCollection>

	^ self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
GtRrJob >> tasksFor: someExecutors [

	^ self tasks
]

{ #category : #'private - running' }
GtRrJob >> terminate [

	state := #terminating.

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
