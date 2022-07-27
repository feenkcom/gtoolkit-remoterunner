"
{{gtClass:GtRrTasksJob}} is a simple job that is given a list of tasks to execute.
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

{ #category : #'accessing - examples' }
GtRrTasksJob >> allExamples [
	^ tasks flatCollect: #examples
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> erroredExamples [
	^ tasks flatCollect: [:aTask | aTask erroredExamples ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> erroredExamplesCount [ 
	^ (tasks flatCollect: #erroredExamples) size
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> executedExamplesCount [ 
	^ (tasks flatCollect: #executedExamples) size
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> failedExamples [
	^ tasks flatCollect: [:aTask | aTask failedExamples ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> failedExamplesCount [ 
	^ (tasks flatCollect: #failedExamples) size
]

{ #category : #testing }
GtRrTasksJob >> hasTests [
	"Answer a boolean indicating if the receiver has one or more tasks that are considered test tasks"

	^ self tasks anySatisfy: [ :task | task isKindOf: GtRrAbstractExamplesTask ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> notExecutedExamples [
	^  (tasks reject: #isFinished) flatCollect: #examples
]

{ #category : #copying }
GtRrTasksJob >> postCopy [

	super postCopy.
	tasks := tasks collect: #copy.
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

{ #category : #ui }
GtRrTasksJob >> showExamplesProgressNotification [
	"Open a global notification showing the progress of the receiver assuming all tasks are exemples / test related"

	^ GtRrExamplesProgressNotification job: self.
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> skippedExamples [
	^ tasks flatCollect: [ :aTask | aTask skippedExamples ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> successfulExamples [
	^ tasks flatCollect: [ :aTask | aTask successfulExamples ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> successfulExamplesCount [ 
	^ (tasks flatCollect: #successfulExamples) size
]

{ #category : #accessing }
GtRrTasksJob >> tasks [

	^ tasks
]

{ #category : #accessing }
GtRrTasksJob >> tasks: anObject [

	tasks := anObject
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> totalExamplesCount [ 
	^ tasks sumNumbers: #totalCount
]
