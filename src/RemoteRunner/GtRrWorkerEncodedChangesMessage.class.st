Class {
	#name : #GtRrWorkerEncodedChangesMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'headReference'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrWorkerEncodedChangesMessage >> headReference [
	^ headReference
]

{ #category : #accessing }
GtRrWorkerEncodedChangesMessage >> headReference: anObject [
	headReference := anObject
]

{ #category : #'as yet unclassified' }
GtRrWorkerEncodedChangesMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Retrieve the changes from the runner and return to the worker.
	This serialises the changes for every worker.
	For large installations, transferring the changes to the worker is normally handled out-of-band."

	^ anOwner remoteRunner encodedChangesSyncEventsFrom: headReference workerId: workerId
]
