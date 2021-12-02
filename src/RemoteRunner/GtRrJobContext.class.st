"
GtRrJobContext holds the current state of a job during execution.
"
Class {
	#name : #GtRrJobContext,
	#superclass : #Object,
	#instVars : [
		'manager',
		'job',
		'results',
		'pendingTasks',
		'currentTasks',
		'completedTasks'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrJobContext >> completedTasks [

	^ completedTasks
]

{ #category : #accessing }
GtRrJobContext >> currentTasks [

	^ currentTasks
]

{ #category : #initialization }
GtRrJobContext >> initialize [

	super initialize.
	pendingTasks := SharedQueue new.
	currentTasks := Dictionary new.
	completedTasks := OrderedCollection new.
]

{ #category : #accessing }
GtRrJobContext >> job [

	^ job
]

{ #category : #accessing }
GtRrJobContext >> job: anObject [

	job := anObject
]

{ #category : #accessing }
GtRrJobContext >> manager [

	^ manager
]

{ #category : #accessing }
GtRrJobContext >> manager: anObject [

	manager := anObject
]

{ #category : #accessing }
GtRrJobContext >> pendingTasks [

	^ pendingTasks
]

{ #category : #accessing }
GtRrJobContext >> results [

	^ results
]
