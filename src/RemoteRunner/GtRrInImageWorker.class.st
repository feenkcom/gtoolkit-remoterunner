"
GtRrInImageWorker is a simple worker that runs in the same image as the RemoteRunner server.

The worker process runs at low priority to not interfere with user operations (see {{gtMethod:GtRrInImageWorker>>#start}}).
"
Class {
	#name : #GtRrInImageWorker,
	#superclass : #Object,
	#instVars : [
		'process',
		'remoteRunner',
		'connection',
		'details',
		'uid'
	],
	#category : #'RemoteRunner-Worker'
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
GtRrInImageWorker >> currentProcessId [
	"Answer the PID of this OS process"

	^ GtOsSystemInfo current currentProcessId
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
	uid := UUID new asString.
	details := Dictionary new
		at: #workingDirectory put: FileLocator workingDirectory resolve fullName;
		at: #id put: uid;
		at: #pid put: self currentProcessId;
		at: #platform put: OSPlatform current name;
		at: #workerPriority put: 10;
		at: #workerInImage put: true;
		yourself.
	connection := GtRrPseudoPharoLinkServerConnection new.
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
	process := [ self taskPollForever ] forkAt: Processor userBackgroundPriority.
]

{ #category : #accessing }
GtRrInImageWorker >> stop [

	process ifNil: [ ^ self ].
	process terminate.
	process := nil.
]

{ #category : #running }
GtRrInImageWorker >> taskDone: aTaskContext with: anObject [

	remoteRunner 
		taskDone: aTaskContext taskContextId 
		started: aTaskContext startTime
		completed: aTaskContext endTime
		with: anObject.
]

{ #category : #running }
GtRrInImageWorker >> taskFailed: aTaskContext with: anError [

	remoteRunner 
		taskFailed: aTaskContext taskContextId 
		started: aTaskContext startTime
		completed: aTaskContext endTime
		with: (GtRrErrorDetails new
			errorMessage: anError messageText;
			trace: anError stackString).
]

{ #category : #running }
GtRrInImageWorker >> taskPoll [
	| serialisedTask |

	PharoLinkServerCurrentConnection 
		value: connection
		during: [ serialisedTask := remoteRunner nextTaskSerializedForWorkerId: 
			(details at: #id) ].
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
