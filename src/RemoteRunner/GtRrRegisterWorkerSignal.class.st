Class {
	#name : #GtRrRegisterWorkerSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'workerAttributes',
		'mutexWait'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrRegisterWorkerSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	workerAttributes := self class evaluate: (aCollection at: 3).
	mutexWait := aCollection at: 4.
]

{ #category : #accessing }
GtRrRegisterWorkerSignal >> mutexWait [
	^ mutexWait
]

{ #category : #accessing }
GtRrRegisterWorkerSignal >> mutexWait: anObject [
	mutexWait := anObject
]

{ #category : #printing }
GtRrRegisterWorkerSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< workerAttributes storeString;
		<< ' | ';
		<< mutexWait asString
]

{ #category : #accessing }
GtRrRegisterWorkerSignal >> signalTypeLabel [

	^ 'GtRrRegisterWorkerSignal'
]

{ #category : #accessing }
GtRrRegisterWorkerSignal >> workerAttributes [

	^ workerAttributes
]

{ #category : #accessing }
GtRrRegisterWorkerSignal >> workerAttributes: anObject [

	workerAttributes := anObject
]

{ #category : #accessing }
GtRrRegisterWorkerSignal >> workerId [

	^ workerAttributes at: #workerId
]
