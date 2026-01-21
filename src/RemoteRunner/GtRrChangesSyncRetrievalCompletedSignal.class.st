Class {
	#name : #GtRrChangesSyncRetrievalCompletedSignal,
	#superclass : #GtRrChangesSyncRetrievalSignal,
	#instVars : [
		'resultSize'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #'as yet unclassified' }
GtRrChangesSyncRetrievalCompletedSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	resultSize := (aCollection at: 5) ifNotNil: [ :v | v asNumber ].
]

{ #category : #testing }
GtRrChangesSyncRetrievalCompletedSignal >> isEndSignalType [
	^ true
]

{ #category : #'as yet unclassified' }
GtRrChangesSyncRetrievalCompletedSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< resultSize asString
]

{ #category : #accessing }
GtRrChangesSyncRetrievalCompletedSignal >> resultSize [
	^resultSize
]

{ #category : #accessing }
GtRrChangesSyncRetrievalCompletedSignal >> resultSize: anObject [
	resultSize := anObject
]
