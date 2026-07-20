"
GtRrMessages are passed between the GtRrWorker and GtRemoteRunner.

Currently only used by MessageQueue.  PharoLink to-be-implemented.
"
Class {
	#name : #GtRrMessage,
	#superclass : #Object,
	#category : 'RemoteRunner-Model'
}

{ #category : #processing }
GtRrMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	^ self subclassResponsibility
]
