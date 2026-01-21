Class {
	#name : #GtRrStopRegisteredWorkerSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'workerId',
		'attributes',
		'registeredWorkerCount'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrStopRegisteredWorkerSignal >> attributes [
	^attributes
]

{ #category : #accessing }
GtRrStopRegisteredWorkerSignal >> attributes: anObject [
	attributes := anObject
]

{ #category : #'as yet unclassified' }
GtRrStopRegisteredWorkerSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< registeredWorkerCount asString;
		<< ' | ';
		print: workerId;
		<< ' | ';
		print: attributes
]

{ #category : #accessing }
GtRrStopRegisteredWorkerSignal >> registeredWorkerCount [
	^registeredWorkerCount
]

{ #category : #accessing }
GtRrStopRegisteredWorkerSignal >> registeredWorkerCount: anObject [
	registeredWorkerCount := anObject
]

{ #category : #accessing }
GtRrStopRegisteredWorkerSignal >> workerId [
	^workerId
]

{ #category : #accessing }
GtRrStopRegisteredWorkerSignal >> workerId: anObject [
	workerId := anObject
]
