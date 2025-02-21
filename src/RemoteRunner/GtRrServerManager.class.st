Class {
	#name : #GtRrServerManager,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Runner-Manager'
}

{ #category : #accessing }
GtRrServerManager >> remoteRunner [
	^ remoteRunner
]

{ #category : #accessing }
GtRrServerManager >> remoteRunner: anObject [
	remoteRunner := anObject
]

{ #category : #'as yet unclassified' }
GtRrServerManager >> startup [

	self subclassResponsibility
]
