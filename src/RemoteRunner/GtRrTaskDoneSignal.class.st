Class {
	#name : #GtRrTaskDoneSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'taskId',
		'mutexWait'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrTaskDoneSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	taskId := aCollection at: 3.
	mutexWait := aCollection at: 4.
	
]

{ #category : #accessing }
GtRrTaskDoneSignal >> mutexWait [

	^ mutexWait
]

{ #category : #accessing }
GtRrTaskDoneSignal >> mutexWait: anObject [

	mutexWait := anObject
]

{ #category : #printing }
GtRrTaskDoneSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< taskId asString;
		<< ' | ';
		<< mutexWait asString
]

{ #category : #accessing }
GtRrTaskDoneSignal >> signalTypeLabel [

	^ 'GtRrTaskDoneSignal'
]

{ #category : #accessing }
GtRrTaskDoneSignal >> taskId [

	^ taskId
]

{ #category : #accessing }
GtRrTaskDoneSignal >> taskId: anObject [

	taskId := anObject
]
