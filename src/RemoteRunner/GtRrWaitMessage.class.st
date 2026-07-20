"
GtRrWaitMessage is just for testing.
It will wait for the specified time, and then answer that time.
"
Class {
	#name : #GtRrWaitMessage,
	#superclass : #GtRrMessage,
	#instVars : [
		'seconds'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #processing }
GtRrWaitMessage >> processMq: mqMessage processor: aGtRrProcessor for: anObject [

	seconds seconds wait.
	^ seconds
]

{ #category : #accessing }
GtRrWaitMessage >> seconds [
	^ seconds
]

{ #category : #accessing }
GtRrWaitMessage >> seconds: anObject [
	seconds := anObject
]
