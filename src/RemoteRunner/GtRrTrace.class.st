Class {
	#name : #GtRrTrace,
	#superclass : #GtRrBeaconSignal,
	#instVars : [
		'message',
		'operation'
	],
	#category : #'RemoteRunner-Beacon'
}

{ #category : #accessing }
GtRrTrace >> message [

	^ message
]

{ #category : #accessing }
GtRrTrace >> message: anObject [

	message := anObject
]

{ #category : #accessing }
GtRrTrace >> operation [

	^ operation
]

{ #category : #accessing }
GtRrTrace >> operation: anObject [

	operation := anObject
]

{ #category : #printing }
GtRrTrace >> printOneLineContentsOn: aStream [

	operation ifNotNil:
		[ aStream << operation ].
	(operation isNotNil and: [ message isNotNil ]) ifTrue:
		[ aStream << ': ' ].
	message ifNotNil: 
		[ aStream << message ]
]
