Class {
	#name : #GtRrWorkerTaskSignal,
	#superclass : #GtRrWorkerOperationSignal,
	#instVars : [
		'taskId'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrWorkerTaskSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	taskId := aCollection at: 3.
]

{ #category : #printing }
GtRrWorkerTaskSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< taskId asString
]

{ #category : #accessing }
GtRrWorkerTaskSignal >> signalTypeLabel [

	^ 'Worker Task Signal'
]

{ #category : #accessing }
GtRrWorkerTaskSignal >> taskId [
	^ taskId
]

{ #category : #accessing }
GtRrWorkerTaskSignal >> taskId: anObject [
	taskId := anObject
]
