Class {
	#name : #GtRrChangesSyncRetrievalSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'omReference',
		'ipAddress'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrChangesSyncRetrievalSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	omReference := aCollection at: 3.
	ipAddress := aCollection at: 4.
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> ipAddress [
	^ ipAddress
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> ipAddress: anObject [
	ipAddress := anObject
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
		<< ipAddress asString
]

{ #category : #accessing }
GtRrChangesSyncRetrievalSignal >> signalTypeLabel [

	^ 'GtRrChangesSyncRetrieval'
]
