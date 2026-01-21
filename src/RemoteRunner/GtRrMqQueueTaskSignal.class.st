Class {
	#name : #GtRrMqQueueTaskSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'taskId'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrMqQueueTaskSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	taskId := aCollection at: 3.
]

{ #category : #printing }
GtRrMqQueueTaskSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< taskId asString
]

{ #category : #accessing }
GtRrMqQueueTaskSignal >> signalTypeLabel [

	^ 'GtRrMqQueueTaskSignal'
]

{ #category : #accessing }
GtRrMqQueueTaskSignal >> taskId [
	^taskId
]

{ #category : #accessing }
GtRrMqQueueTaskSignal >> taskId: anObject [
	taskId := anObject
]
