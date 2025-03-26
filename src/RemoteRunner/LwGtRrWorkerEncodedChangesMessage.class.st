Class {
	#name : #LwGtRrWorkerEncodedChangesMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'headReference',
		'integrationVersion'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
LwGtRrWorkerEncodedChangesMessage >> headReference [
	^ headReference
]

{ #category : #accessing }
LwGtRrWorkerEncodedChangesMessage >> headReference: anObject [
	headReference := anObject
]

{ #category : #accessing }
LwGtRrWorkerEncodedChangesMessage >> integrationVersion [
	^integrationVersion
]

{ #category : #accessing }
LwGtRrWorkerEncodedChangesMessage >> integrationVersion: aString [

	integrationVersion := aString
]

{ #category : #'as yet unclassified' }
LwGtRrWorkerEncodedChangesMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	^ anOwner remoteRunner 
		lwChangesSyncEventsFrom: headReference 
		integrationVersion: integrationVersion
		workerId: workerId.
]
