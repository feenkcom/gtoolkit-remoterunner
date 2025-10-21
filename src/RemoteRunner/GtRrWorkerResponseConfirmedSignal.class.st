Class {
	#name : #GtRrWorkerResponseConfirmedSignal,
	#superclass : #GtRrWorkerTaskSignal,
	#instVars : [
		'result'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrWorkerResponseConfirmedSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	result := aCollection at: 4.
]

{ #category : #printing }
GtRrWorkerResponseConfirmedSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< result asString
]

{ #category : #accessing }
GtRrWorkerResponseConfirmedSignal >> result [

	^ result
]

{ #category : #accessing }
GtRrWorkerResponseConfirmedSignal >> result: anObject [

	result := anObject
]
