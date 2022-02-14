Class {
	#name : #GtRrCompoundTask,
	#superclass : #GtRrTask,
	#instVars : [
		'subtasks'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrCompoundTask class >> leJsonV4Name [

	^ #gtRrCompoundTask
]

{ #category : #accessing }
GtRrCompoundTask >> run [

	^ subtasks collect: [ :task | task run ]
]

{ #category : #accessing }
GtRrCompoundTask >> subtasks [

	^ subtasks
]

{ #category : #accessing }
GtRrCompoundTask >> subtasks: anObject [

	subtasks := anObject
]
