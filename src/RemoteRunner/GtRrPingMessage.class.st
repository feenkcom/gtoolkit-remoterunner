Class {
	#name : #GtRrPingMessage,
	#superclass : #GtRrMessage,
	#category : 'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtRrPingMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	^ #ping
]
