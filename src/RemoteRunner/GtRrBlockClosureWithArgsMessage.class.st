Class {
	#name : #GtRrBlockClosureWithArgsMessage,
	#superclass : #GtRrBlockClosureMessage,
	#instVars : [
		'arguments'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrBlockClosureWithArgsMessage >> arguments [
	^arguments
]

{ #category : #accessing }
GtRrBlockClosureWithArgsMessage >> arguments: anObject [
	arguments := anObject
]

{ #category : #processing }
GtRrBlockClosureWithArgsMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anOwner.
	anOwner (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	^ blockClosure cull: mqMessage cull: aGtRrProcessor cull: anOwner cull: arguments
]
