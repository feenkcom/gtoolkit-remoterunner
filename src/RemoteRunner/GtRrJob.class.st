"
A GtRrJob is the object submitted to a remote runner for execution.  It answers a collection of tasks to be executed by the workers, and holds the results of the tasks.  Partial results are announced as each task is completed.
"
Class {
	#name : #GtRrJob,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'platforms',
		'state',
		'results',
		'announcer',
		'id'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
GtRrJob >> addResult: aGtRrTask [
	"Add the completed task to the results"

	results add: aGtRrTask.
	self announce: (aGtRrTask hasErrors
		ifTrue: [ GtRrTaskFailedAnnouncement task: aGtRrTask ]
		ifFalse: [ GtRrTaskCompletedAnnouncement task: aGtRrTask ])
]

{ #category : #accessing }
GtRrJob >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #ui }
GtRrJob >> gtResultsFor: aView [
	<gtView>

	^ aView list
		title: 'Results';
		priority: 10;
		items: [ results ];
		updateWhen: GtRrJobAnnouncement in: [ self announcer ]
]

{ #category : #testing }
GtRrJob >> hasErrors [
	"Answer a boolean indicating whether the receiver has tasks that failed"

	^ results anySatisfy: [ :task | task hasErrors ]
]

{ #category : #accessing }
GtRrJob >> id [

	^ id
]

{ #category : #initialization }
GtRrJob >> initialize [

	super initialize.
	id := UUID new asString.
	platforms := { OSPlatform current name }.
	results := OrderedCollection new.
	state := #notStarted
]

{ #category : #accessing }
GtRrJob >> platforms [
	<return: #Array>

	^ platforms
]

{ #category : #accessing }
GtRrJob >> platforms: anArray [

	platforms := anArray
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
GtRrJob >> results [

	^ results
]

{ #category : #accessing }
GtRrJob >> state [
	<return: #Symbol>

	^ state
]

{ #category : #accessing }
GtRrJob >> state: aSymbol [
	"One of: #notStarted, #started, #completed"

	state := aSymbol.

	state = #started ifTrue:
		[ self announce: (GtRrJobStartedAnnouncement job: self) ].
	state = #completed ifTrue:
		[ self announce: (GtRrJobCompletedAnnouncement job: self) ].

]

{ #category : #accessing }
GtRrJob >> tasks [
	"Answer the collection of tasks to be executed"
	<return: #SequenceableCollection>

	^ self subclassResponsibility 
]
