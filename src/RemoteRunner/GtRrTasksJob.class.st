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
