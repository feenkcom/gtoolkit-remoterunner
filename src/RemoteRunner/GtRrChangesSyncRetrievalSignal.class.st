Class {
	#name : #GtRrChangesSyncRetrievalSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'omReference',
		'workerId'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrChangesSyncRetrievalSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	omReference := aCollection at: 3.
	workerId := aCollection at: 4.
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> omReference [
	^ omReference
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> omReference: anObject [
	omReference := anObject
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< omReference asString;
		<< ' | ';
		<< workerId asString
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> signalTypeLabel [

	^ 'GtRrChangesSyncRetrieval'
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> workerId [
	^ workerId
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> workerId: anObject [
	workerId := anObject
]
