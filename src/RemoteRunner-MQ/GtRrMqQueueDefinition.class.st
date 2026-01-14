Class {
	#name : #GtRrMqQueueDefinition,
	#superclass : #Object,
	#instVars : [
		'basename',
		'stompName',
		'headers',
		'prefetchCount'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrMqQueueDefinition >> basename [
	^ basename
]

{ #category : #accessing }
GtRrMqQueueDefinition >> basename: aString [

	basename := aString
]

{ #category : #accessing }
GtRrMqQueueDefinition >> headerAt: aString [

	^ headers ifNotNil: [ headers at: aString ]
]

{ #category : #accessing }
GtRrMqQueueDefinition >> headerAt: keyString put: valueString [

	
	^ self headers at: keyString put: valueString
]

{ #category : #private }
GtRrMqQueueDefinition >> headers [

	^ headers ifNil: [ headers := SmallDictionary new ]
]

{ #category : #accessing }
GtRrMqQueueDefinition >> prefetchCount [
	^ prefetchCount
]

{ #category : #accessing }
GtRrMqQueueDefinition >> prefetchCount: anInteger [

	prefetchCount := anInteger
]

{ #category : #printing }
GtRrMqQueueDefinition >> printOn: aStream [

	super printOn: aStream.
	basename ifNotNil:
		[ aStream parenthesize: [ aStream << basename asString ] ]
]

{ #category : #'as yet unclassified' }
GtRrMqQueueDefinition >> setHeadersIn: aStampFrame [

	headers ifNil: [ ^ self ].
	headers keysAndValuesDo: [ :key :value |
		aStampFrame headerAt: key put: value ].
]

{ #category : #accessing }
GtRrMqQueueDefinition >> stompName [
	^ stompName
]

{ #category : #accessing }
GtRrMqQueueDefinition >> stompName: aString [

	stompName := aString
]
