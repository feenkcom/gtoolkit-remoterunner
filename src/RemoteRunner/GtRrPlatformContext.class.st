Class {
	#name : #GtRrPlatformContext,
	#superclass : #Object,
	#instVars : [
		'jobContext',
		'platform',
		'results',
		'pendingTasks',
		'currentTasks',
		'completedTasks'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrPlatformContext >> completedTasks [

	^ completedTasks
]

{ #category : #accessing }
GtRrPlatformContext >> currentTasks [

	^ currentTasks
]

{ #category : #initialization }
GtRrPlatformContext >> initialize [

	super initialize.
	pendingTasks := SharedQueue new.
	currentTasks := Dictionary new.
	completedTasks := OrderedCollection new.
]

{ #category : #testing }
GtRrPlatformContext >> isFinished [
	"Answer a boolean indicating whether the receiver has finished or not"

	^ pendingTasks isEmpty and: [ currentTasks isEmpty and: [ completedTasks isNotEmpty ]]
]

{ #category : #accessing }
GtRrPlatformContext >> jobContext [

	^ jobContext
]

{ #category : #accessing }
GtRrPlatformContext >> jobContext: anObject [

	jobContext := anObject
]

{ #category : #accessing }
GtRrPlatformContext >> pendingTasks [

	^ pendingTasks
]

{ #category : #accessing }
GtRrPlatformContext >> platform [

	^ platform
]

{ #category : #accessing }
GtRrPlatformContext >> platform: anObject [

	platform := anObject
]

{ #category : #accessing }
GtRrPlatformContext >> results [

	^ results
]
