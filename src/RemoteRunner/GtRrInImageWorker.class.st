"
GtRrInImageWorker is a simple worker that runs in the same image as the RemoteRunner server and is used for testing and demonstrating the system.
"
Class {
	#name : #GtRrInImageWorker,
	#superclass : #Object,
	#instVars : [
		'process',
		'remoteRunner',
		'connection',
		'attributes'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrInImageWorker >> attributes [

	^ attributes
]

{ #category : #accessing }
GtRrInImageWorker >> attributes: anObject [

	attributes := anObject
]

{ #category : #accessing }
GtRrInImageWorker >> connection [
	<return: #PharoLinkServerConnection>

	^ connection
]

{ #category : #accessing }
GtRrInImageWorker >> connection: aPharoLinkServerConnection [

	connection := aPharoLinkServerConnection
]

{ #category : #accessing }
GtRrInImageWorker >> process [

	^ process
]

{ #category : #accessing }
GtRrInImageWorker >> scheduler [

	^ remoteRunner
]

{ #category : #accessing }
GtRrInImageWorker >> scheduler: anObject [

	remoteRunner := anObject
]

{ #category : #running }
GtRrInImageWorker >> start [

	process ifNotNil: [ ^ self error: 'Worker already started' ].
	self
		assert: attributes isNotNil
		description: 'The worker''s details must be set before starting'.
	self
		assert: remoteRunner isNotNil
		description:
		'The worker''s remote runner must be set before starting'.
	PharoLinkServerCurrentConnection
		value: connection
		during: [ 
		remoteRunner connectWithAttributes: attributes observer: #yourself ].
	process := [ self taskPollForever ] fork
]

{ #category : #accessing }
GtRrInImageWorker >> stop [

	process ifNil: [ ^ self ].
	process terminate.
	process := nil.
]

{ #category : #running }
GtRrInImageWorker >> task: aTask failure: anError [

	remoteRunner task: aTask id failure: anError gtRrAsError
]

{ #category : #running }
GtRrInImageWorker >> task: aTask success: anObject [

	remoteRunner task: aTask id success: anObject.
]

{ #category : #running }
GtRrInImageWorker >> taskPoll [

	| serialisedTask |
	PharoLinkServerCurrentConnection value: connection during: [ 
		serialisedTask := LeJsonV4 uniqueInstance serialize:
			                  remoteRunner taskNext ].
	^ LeJsonV4 uniqueInstance deserialize: serialisedTask readStream
]

{ #category : #running }
GtRrInImageWorker >> taskPollForever [

	[ self taskRun: self taskPoll ] repeat
]

{ #category : #running }
GtRrInImageWorker >> taskRun: aTask [

	| result error |
	[ result := aTask value ]
		on: Error
		do: [ :ex | 
			ex freeze.
			error := ex ].
	error
		ifNil: [ self task: aTask success: result ]
		ifNotNil: [ self task: aTask failure: error ]
]
