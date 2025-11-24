"
GtRrWorkerMessages are passed from the GtRrWorker to the GtRemoteRunner.
"
Class {
	#name : #GtRrWorkerMessage,
	#superclass : #GtRrMessage,
	#instVars : [
		'workerId'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrWorkerMessage >> workerId [
	^ workerId
]

{ #category : #accessing }
GtRrWorkerMessage >> workerId: anObject [
	workerId := anObject
]
