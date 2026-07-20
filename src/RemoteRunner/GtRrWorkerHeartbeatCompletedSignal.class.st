Class {
	#name : #GtRrWorkerHeartbeatCompletedSignal,
	#superclass : #GtRrWorkerHeartbeatSignal,
	#instVars : [
		'milliseconds'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #'as yet unclassified' }
GtRrWorkerHeartbeatCompletedSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	milliseconds := aCollection third.
]

{ #category : #'as yet unclassified' }
GtRrWorkerHeartbeatCompletedSignal >> isEndSignalType [
	^ true
]

{ #category : #accessing }
GtRrWorkerHeartbeatCompletedSignal >> milliseconds [
	^ milliseconds
]

{ #category : #accessing }
GtRrWorkerHeartbeatCompletedSignal >> milliseconds: anObject [
	milliseconds := anObject
]

{ #category : #'as yet unclassified' }
GtRrWorkerHeartbeatCompletedSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< milliseconds asString
]
