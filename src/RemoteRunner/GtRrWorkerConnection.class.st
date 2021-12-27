"
GtRrWorkerConnection is the runner's representation of a worker.  The term 'proxy' isn't used as it isn't a PharoLink proxy object - it will use the worker's control channel to send messages back to the worker.
"
Class {
	#name : #GtRrWorkerConnection,
	#superclass : #Object,
	#instVars : [
		'connection',
		'platform',
		'remoteAddress',
		'details'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrWorkerConnection class >> connection: aConnection [

	^ self new connection: aConnection
]

{ #category : #accessing }
GtRrWorkerConnection >> connection [

	^ connection
]

{ #category : #accessing }
GtRrWorkerConnection >> connection: aPharoLinkServerConnection [

	connection := aPharoLinkServerConnection.
	remoteAddress := connection remoteAddress.
]

{ #category : #initialization }
GtRrWorkerConnection >> initialize [

	super initialize.
	details := Dictionary new.
]

{ #category : #accessing }
GtRrWorkerConnection >> platform [

	^ platform
]

{ #category : #accessing }
GtRrWorkerConnection >> platform: anObject [

	platform := anObject
]

{ #category : #accessing }
GtRrWorkerConnection >> remoteAddress [

	^ remoteAddress
]

{ #category : #'start-stop' }
GtRrWorkerConnection >> stop [

	connection stop
]
