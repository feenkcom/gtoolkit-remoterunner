Class {
	#name : #PlpoGtRrTask,
	#superclass : #PharoLinkProxyObject,
	#instVars : [
		'finished',
		'a'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
PlpoGtRrTask class >> remoteClassName [

	^ #GtRrTask
]

{ #category : #testing }
PlpoGtRrTask >> isFinished [
	"Answer a boolean indicating whether the receiver's object has finished.
	If it has, cache the result since tasks never 'unfinish'."

	finished ifNotNil: [ ^ finished ].

	^ (self proxyPerform: #isFinished)
		ifTrue: [ finished := true ]
		ifFalse: [ false ].
]
