Class {
	#name : #GtRrWorkerResponseSentSignal,
	#superclass : #GtRrWorkerTaskSignal,
	#instVars : [
		'result'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrWorkerResponseSentSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	result := aCollection at: 4.
]

{ #category : #printing }
GtRrWorkerResponseSentSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< result asString
]

{ #category : #accessing }
GtRrWorkerResponseSentSignal >> result [

	^ result
]

{ #category : #accessing }
GtRrWorkerResponseSentSignal >> result: anObject [

	result := anObject
]
