Class {
	#name : #GtRrMqTaskMissingSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'taskId',
		'taskContextId'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrMqTaskMissingSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	taskId := aCollection at: 3.
	taskContextId := aCollection at: 4.
	
]

{ #category : #printing }
GtRrMqTaskMissingSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< taskId asString;
		<< ' | ';
		<< taskContextId asString
]

{ #category : #accessing }
GtRrMqTaskMissingSignal >> taskContextId [
	^taskContextId
]

{ #category : #accessing }
GtRrMqTaskMissingSignal >> taskContextId: anObject [
	taskContextId := anObject
]

{ #category : #accessing }
GtRrMqTaskMissingSignal >> taskId [
	^taskId
]

{ #category : #accessing }
GtRrMqTaskMissingSignal >> taskId: anObject [
	taskId := anObject
]
