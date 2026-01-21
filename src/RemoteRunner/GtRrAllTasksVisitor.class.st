Class {
	#name : #GtRrAllTasksVisitor,
	#superclass : #Object,
	#traits : 'TGtRrTaskVisitor',
	#classTraits : 'TGtRrTaskVisitor classTrait',
	#instVars : [
		'visitBlock'
	],
	#category : 'RemoteRunner-Tasks'
}

{ #category : #'instance creation' }
GtRrAllTasksVisitor class >> visitBlock: aBlock [

	^ self new visitBlock: aBlock
]

{ #category : #accessing }
GtRrAllTasksVisitor >> visitBlock [

	^ visitBlock
]

{ #category : #accessing }
GtRrAllTasksVisitor >> visitBlock: anObject [

	visitBlock := anObject
]

{ #category : #visiting }
GtRrAllTasksVisitor >> visitTask: aGtRrTask [

	visitBlock value: aGtRrTask
]
