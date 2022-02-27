Class {
	#name : #GtRrTaskFactory,
	#superclass : #Object,
	#instVars : [
		'stream',
		'taskTimeout'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #'private - utility' }
GtRrTaskFactory >> classWithName: aString [

	^ (aString endsWith: ' class')
		ifTrue: [ (self class environment at: (aString copyFrom: 1 to: aString size - 6) asSymbol) class ]
		ifFalse: [ self class environment at: aString asSymbol ].
]

{ #category : #initialization }
GtRrTaskFactory >> initialize [

	super initialize.
	self reset.
]

{ #category : #'api - generation' }
GtRrTaskFactory >> job [

	^ GtRrTasksJob new tasks: self tasks.
]

{ #category : #initialization }
GtRrTaskFactory >> reset [

	stream := Array new writeStream.
]

{ #category : #'api - generation' }
GtRrTaskFactory >> tasks [

	^ stream contents
]

{ #category : #accessing }
GtRrTaskFactory >> taskTimeout [
	<return: #Duration or: nil>

	^ taskTimeout
]

{ #category : #accessing }
GtRrTaskFactory >> taskTimeout: aDuration [

	taskTimeout := aDuration
]
