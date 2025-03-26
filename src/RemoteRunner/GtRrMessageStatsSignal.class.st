Class {
	#name : #GtRrMessageStatsSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'messageClassName',
		'encodedSize'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrMessageStatsSignal >> encodedSize [
	^encodedSize
]

{ #category : #accessing }
GtRrMessageStatsSignal >> encodedSize: anObject [
	encodedSize := anObject
]

{ #category : #initialization }
GtRrMessageStatsSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	messageClassName := aCollection at: 3.
	encodedSize := (aCollection at: 4) asNumber.
]

{ #category : #accessing }
GtRrMessageStatsSignal >> messageClassName [
	^messageClassName
]

{ #category : #accessing }
GtRrMessageStatsSignal >> messageClassName: anObject [
	messageClassName := anObject
]

{ #category : #printing }
GtRrMessageStatsSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream 
		space; nextPut: $|; space;
		nextPutAll: messageClassName asString;
		space; nextPut: $|; space;
		nextPutAll: encodedSize asString
]
