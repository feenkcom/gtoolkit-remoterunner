Class {
	#name : #GtRrStopRegisteredWorkersSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'registeredWorkerCount'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrStopRegisteredWorkersSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	registeredWorkerCount := aCollection at: 3.
	
]

{ #category : #printing }
GtRrStopRegisteredWorkersSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< registeredWorkerCount asString
]

{ #category : #accessing }
GtRrStopRegisteredWorkersSignal >> registeredWorkerCount [

	^ registeredWorkerCount
]

{ #category : #accessing }
GtRrStopRegisteredWorkersSignal >> registeredWorkerCount: anObject [

	registeredWorkerCount := anObject
]

{ #category : #accessing }
GtRrStopRegisteredWorkersSignal >> signalTypeLabel [

	^ 'GtRrStopRegisteredWorkersSignal'
]
