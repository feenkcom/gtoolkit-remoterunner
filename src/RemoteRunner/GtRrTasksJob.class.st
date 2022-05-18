"
GtRrTasksJob is a simple job that is given a list of tasks to execute.
"
Class {
	#name : #GtRrTasksJob,
	#superclass : #GtRrJob,
	#instVars : [
		'tasks'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #jsonV4 }
GtRrTasksJob class >> leJsonV4AttributeMapping [
	"Answer the Array of attribute to store keys.
	Subclasses should override this with their attributes."

	^ super leJsonV4AttributeMapping
		add: #tasks -> #tasks;
		yourself.
]

{ #category : #jsonV4 }
GtRrTasksJob class >> leJsonV4Name [

	^ #gtRrTasksJob
]

{ #category : #'instance creation' }
GtRrTasksJob class >> tasks: aCollection [

	^ self new tasks: aCollection
]

{ #category : #testing }
GtRrTasksJob >> hasTests [
	"Answer a boolean indicating if the receiver has one or more tasks that are considered test tasks"

	^ self tasks 
		detect: [ :task | (task isKindOf: GtRrExamplesTask) or: (task isKindOf: GtRrTestTask) ]
		ifFound: [ true ]
		ifNone: [ false ]
	
]

{ #category : #printing }
GtRrTasksJob >> printOn: aStream [

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title;
		nextPut: $(;
		print: self tasks size;
		<< ' tasks, ';
		print: self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].
	aStream
		nextPut: $).
]

{ #category : #accessing }
GtRrTasksJob >> tasks [

	^ tasks
]

{ #category : #accessing }
GtRrTasksJob >> tasks: anObject [

	tasks := anObject
]
