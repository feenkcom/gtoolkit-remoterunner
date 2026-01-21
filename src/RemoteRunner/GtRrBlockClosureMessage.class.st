Class {
	#name : #GtRrBlockClosureMessage,
	#superclass : #GtRrMessage,
	#instVars : [
		'blockClosure'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrBlockClosureMessage >> blockClosure [
	^ blockClosure
]

{ #category : #accessing }
GtRrBlockClosureMessage >> blockClosure: anObject [
	blockClosure := anObject
]

{ #category : #processing }
GtRrBlockClosureMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	^ blockClosure cull: mqMessage cull: aGtRrProcessor cull: anOwner
]
