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
		'details'
	],
	#category : #'RemoteRunner-Examples'
}

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
GtRrInImageWorker >> details [

	^ details
]

{ #category : #accessing }
GtRrInImageWorker >> details: anObject [

	details := anObject
]

{ #category : #initialization }
GtRrInImageWorker >> initialize [

	super initialize.
	details := Dictionary new.
]

{ #category : #accessing }
GtRrInImageWorker >> process [

	^ process
]

{ #category : #accessing }
GtRrInImageWorker >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrInImageWorker >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #running }
GtRrInImageWorker >> start [

	process ifNotNil: [ ^ self error: 'Worker already started' ].
	self assert: remoteRunner isNotNil
		description: 'The worker''s remote runner must be set before starting'.
	PharoLinkServerCurrentConnection 
		value: connection
		during: [ remoteRunner registerWorkerWithDetails: details ].
	process := [ self taskPollForever ] fork.
]

{ #category : #accessing }
GtRrInImageWorker >> stop [

	process ifNil: [ ^ self ].
	process terminate.
	process := nil.
]

{ #category : #running }
GtRrInImageWorker >> taskDone: aTaskContext with: anObject [

	remoteRunner taskDone: aTaskContext taskContextId with: anObject.
]

{ #category : #running }
GtRrInImageWorker >> taskFailed: aTaskContext with: anError [

	remoteRunner 
		taskFailed: aTaskContext taskContextId 
		with: (GtRrErrorDetails new
			errorMessage: anError messageText;
			trace: anError stackString).
]

{ #category : #running }
GtRrInImageWorker >> taskPoll [
	| serialisedTask |

	PharoLinkServerCurrentConnection 
		value: connection
		during: [ serialisedTask := remoteRunner nextTaskSerializedForCurrentWorker ].
	^ LeJsonV4 uniqueInstance deserialize: serialisedTask readStream.
]

{ #category : #running }
GtRrInImageWorker >> taskPollForever [

	[ self taskRun: self taskPoll ] repeat
]

{ #category : #running }
GtRrInImageWorker >> taskRun: aTaskContext [
	| result error |

	[ result := aTaskContext value ]
		on: Error 
		do: [ :ex |
			ex freeze.
			error := ex ].
	error
		ifNil: [ self taskDone: aTaskContext with: result ]
		ifNotNil: [ self taskFailed: aTaskContext with: error ]
]
