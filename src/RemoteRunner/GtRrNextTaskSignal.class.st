Class {
	#name : #GtRrNextTaskSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'taskId',
		'mutexWait',
		'workerId'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrNextTaskSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	taskId := aCollection at: 3.
	mutexWait := aCollection at: 4.
	workerId := aCollection at: 5.
]

{ #category : #accessing }
GtRrNextTaskSignal >> mutexWait [

	^ mutexWait
]

{ #category : #accessing }
GtRrNextTaskSignal >> mutexWait: anObject [

	mutexWait := anObject
]

{ #category : #printing }
GtRrNextTaskSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< taskId asString;
		<< ' | ';
		<< mutexWait asString;
		<< ' | ';
		<< workerId asString
]

{ #category : #accessing }
GtRrNextTaskSignal >> signalTypeLabel [

	^ 'GtRrNextTaskSignal'
]

{ #category : #accessing }
GtRrNextTaskSignal >> taskId [

	^ taskId
]

{ #category : #accessing }
GtRrNextTaskSignal >> taskId: anObject [

	taskId := anObject
]

{ #category : #accessing }
GtRrNextTaskSignal >> workerId [
	^ workerId
]

{ #category : #accessing }
GtRrNextTaskSignal >> workerId: anObject [
	workerId := anObject
]
