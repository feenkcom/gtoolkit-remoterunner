"
GtRrRunnerMessages are passed from the GtRemoteRunner to the GtRrWorker.
"
Class {
	#name : #GtRrRunnerMessage,
	#superclass : #GtRrMessage,
	#category : #'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtRrRunnerMessage >> process: mqMessage withWorker: aGtRrWorker [

	self subclassResponsibility
]
