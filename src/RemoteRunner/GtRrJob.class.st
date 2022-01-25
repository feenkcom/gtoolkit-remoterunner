"
A GtRrJob is the object submitted to a remote runner for execution.  It answers a collection of tasks to be executed by the workers, and holds the results of the tasks.  Partial results are announced as each task is completed.
"
Class {
	#name : #GtRrJob,
	#superclass : #GtRrTask,
	#instVars : [
		'scheduler',
		'tasks'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #ui }
GtRrJob >> gtErrorsFor: aView [
	<gtView>

	^ aView list
		title: 'Errors';
		priority: 16;
		items: [ self resultsWithErrors ];
		updateWhen: GtRrAnnouncement in: [ self announcer ]
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
	tasks ifNil: [ ^ aView empty ].
	^ aView list
		  title: 'Tasks';
		  priority: 50;
		  items: [ tasks ]
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

{ #category : #accessing }
GtRrJob >> scheduler [

	^ scheduler
]

{ #category : #accessing }
GtRrJob >> scheduler: anObject [

	scheduler := anObject
]

{ #category : #'private - running' }
GtRrJob >> start [

	startTime := DateAndTime now.
	state := #started.
	self announce: (GtRrJobStartedAnnouncement job: self).

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

	"Answer the collection of tasks to be executed. Can use scheduler executors to create constraints for specific executor."

	<return: #SequenceableCollection>
	^ tasks
]

{ #category : #accessing }
GtRrJob >> tasks: aCollection [

	tasks := aCollection
]

{ #category : #accessing }
GtRrJob >> value [

	scheduler announceAndLog: (GtRrJobStartedAnnouncement job: self).
	self tasks do: [ :e | scheduler future: e ]
]
