Class {
	#name : #GtRrWorkerApplyChangesCompletedSignal,
	#superclass : #GtRrWorkerApplyChangesSignal,
	#instVars : [
		'encodedEventsSize',
		'eventsCount'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerApplyChangesCompletedSignal >> encodedEventsSize [
	^ encodedEventsSize
]

{ #category : #accessing }
GtRrWorkerApplyChangesCompletedSignal >> encodedEventsSize: anObject [
	encodedEventsSize := anObject
]

{ #category : #accessing }
GtRrWorkerApplyChangesCompletedSignal >> eventsCount [
	^ eventsCount
]

{ #category : #accessing }
GtRrWorkerApplyChangesCompletedSignal >> eventsCount: anObject [
	eventsCount := anObject
]

{ #category : #initialization }
GtRrWorkerApplyChangesCompletedSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	encodedEventsSize := aCollection fifth.
	eventsCount := aCollection sixth.
]

{ #category : #testing }
GtRrWorkerApplyChangesCompletedSignal >> isEndSignalType [
	^ true
]

{ #category : #printing }
GtRrWorkerApplyChangesCompletedSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< self encodedEventsSize asString;
		<< ' | ';
		<< self eventsCount asString
]
