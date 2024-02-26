Class {
	#name : #GtRrWorkerTaskCompletedSignal,
	#superclass : #GtRrWorkerTaskSignal,
	#instVars : [
		'message'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrWorkerTaskCompletedSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	message := aCollection at: 4.
]

{ #category : #testing }
GtRrWorkerTaskCompletedSignal >> isEndSignalType [
	^ true
]

{ #category : #accessing }
GtRrWorkerTaskCompletedSignal >> message [

	^ message
]

{ #category : #accessing }
GtRrWorkerTaskCompletedSignal >> message: anObject [

	message := anObject
]

{ #category : #printing }
GtRrWorkerTaskCompletedSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< message asString
]
