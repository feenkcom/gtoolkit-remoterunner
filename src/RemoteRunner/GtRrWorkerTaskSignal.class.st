Class {
	#name : #GtRrWorkerTaskSignal,
	#superclass : #GtRrWorkerOperationSignal,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRrWorkerTaskSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	task := aCollection at: 3.
]

{ #category : #printing }
GtRrWorkerTaskSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< (task
			ifNil: [ '<no task>' ]
			ifNotNil: [ task id asString ])
]

{ #category : #accessing }
GtRrWorkerTaskSignal >> task [

	^ task
]

{ #category : #accessing }
GtRrWorkerTaskSignal >> task: anObject [

	task := anObject
]
