"
GtRrJobContext holds the current state of a job during execution.
"
Class {
	#name : #GtRrJobContext,
	#superclass : #Object,
	#instVars : [
		'job',
		'tasks',
		'remoteRunner',
		'platformContexts'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #adding }
GtRrJobContext >> addTask: aGtRrTask [

	tasks add: aGtRrTask 
]

{ #category : #accessing }
GtRrJobContext >> allItems [

	^ job allItems
]

{ #category : #initialization }
GtRrJobContext >> initialize [ 

	super initialize.
	tasks := OrderedCollection new
]

{ #category : #testing }
GtRrJobContext >> isFinished [

	^ platformContexts allSatisfy: #isFinished
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
GtRrJobContext >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrJobContext >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #accessing }
GtRrJobContext >> tasks [

	^ tasks
]

{ #category : #accessing }
GtRrJobContext >> tasks: anObject [

	tasks := anObject
]
