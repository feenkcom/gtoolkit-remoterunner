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
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	^ anOwner remoteRunner changesSyncEventsFrom: headReference workerId: workerId
]
