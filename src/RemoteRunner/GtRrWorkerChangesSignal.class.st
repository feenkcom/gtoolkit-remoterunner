Class {
	#name : #GtRrWorkerChangesSignal,
	#superclass : #GtRrWorkerOperationSignal,
	#instVars : [
		'remoteAddressString',
		'workerId'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrWorkerChangesSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	remoteAddressString := aCollection third.
	workerId := aCollection fourth.
]

{ #category : #printing }
GtRrWorkerChangesSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< self remoteAddressString asString;
		<< ' | ';
		<< self workerId asString
]

{ #category : #accessing }
GtRrWorkerChangesSignal >> remoteAddressString [
	^ remoteAddressString
]

{ #category : #accessing }
GtRrWorkerChangesSignal >> remoteAddressString: anObject [
	remoteAddressString := anObject
]

{ #category : #accessing }
GtRrWorkerChangesSignal >> workerId [
	^ workerId
]

{ #category : #accessing }
GtRrWorkerChangesSignal >> workerId: anObject [
	workerId := anObject
]
