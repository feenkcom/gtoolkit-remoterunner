Class {
	#name : #GtRrWorkerApplyChangeCompletedSignal,
	#superclass : #GtRrWorkerApplyChangeSignal,
	#instVars : [
		'applied'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerApplyChangeCompletedSignal >> applied [
	^ applied
]

{ #category : #accessing }
GtRrWorkerApplyChangeCompletedSignal >> applied: anObject [
	applied := anObject
]

{ #category : #initialization }
GtRrWorkerApplyChangeCompletedSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 
	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	applied := aCollection sixth.
]

{ #category : #testing }
GtRrWorkerApplyChangeCompletedSignal >> isEndSignalType [
	^ true
]

{ #category : #printing }
GtRrWorkerApplyChangeCompletedSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< applied asString
]
