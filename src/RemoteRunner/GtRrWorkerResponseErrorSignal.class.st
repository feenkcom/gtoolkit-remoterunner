Class {
	#name : #GtRrWorkerResponseErrorSignal,
	#superclass : #GtRrWorkerTaskSignal,
	#instVars : [
		'errorMessage',
		'workerId',
		'taskContextId'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerResponseErrorSignal >> errorMessage [
	^errorMessage
]

{ #category : #accessing }
GtRrWorkerResponseErrorSignal >> errorMessage: anObject [
	errorMessage := anObject
]

{ #category : #initialization }
GtRrWorkerResponseErrorSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	errorMessage := aCollection at: 4.
	workerId := aCollection at: 5.
	taskContextId := aCollection at: 6.
]

{ #category : #printing }
GtRrWorkerResponseErrorSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< errorMessage asString;
		<< ' | ';
		<< workerId asString;
		<< ' | ';
		<< taskContextId asString
]

{ #category : #accessing }
GtRrWorkerResponseErrorSignal >> taskContextId [
	^taskContextId
]

{ #category : #accessing }
GtRrWorkerResponseErrorSignal >> taskContextId: anObject [
	taskContextId := anObject
]

{ #category : #accessing }
GtRrWorkerResponseErrorSignal >> workerId [
	^workerId
]

{ #category : #accessing }
GtRrWorkerResponseErrorSignal >> workerId: anObject [
	workerId := anObject
]
