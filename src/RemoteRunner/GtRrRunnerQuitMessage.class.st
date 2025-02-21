Class {
	#name : #GtRrRunnerQuitMessage,
	#superclass : #GtRrRunnerMessage,
	#instVars : [
		'reason'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtRrRunnerQuitMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anOwner (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	ConnectionClosed signal.
]

{ #category : #accessing }
GtRrRunnerQuitMessage >> reason [
	^ reason
]

{ #category : #accessing }
GtRrRunnerQuitMessage >> reason: aString [

	reason := aString
]
