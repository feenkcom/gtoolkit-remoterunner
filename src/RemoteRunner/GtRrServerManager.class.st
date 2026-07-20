Class {
	#name : #GtRrServerManager,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : 'RemoteRunner-Runner-Manager'
}

{ #category : #'api - worker' }
GtRrServerManager >> registerWorker: aWorkerConnection [
	"Do nothing"
]

{ #category : #accessing }
GtRrServerManager >> remoteRunner [
	^ remoteRunner
]

{ #category : #accessing }
GtRrServerManager >> remoteRunner: anObject [
	remoteRunner := anObject
]

{ #category : #'api - worker' }
GtRrServerManager >> startup [

	self subclassResponsibility
]
