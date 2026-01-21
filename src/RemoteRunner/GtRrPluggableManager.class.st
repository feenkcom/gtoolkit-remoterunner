"
GtRrPluggableManager is intended to replace the GtRrManagerStartupAndShutdown and its proliferation of subclasses.
"
Class {
	#name : #GtRrPluggableManager,
	#superclass : #Object,
	#instVars : [
		'remoteRunner',
		'inImageWorker',
		'serverManager',
		'codeSyncManager',
		'workerManager',
		'workerTerminationStrategy'
	],
	#category : #'RemoteRunner-Runner-Manager'
}

{ #category : #accessing }
GtRrPluggableManager >> asStatsDictionary [

	^ Dictionary new
		at: #name put: self class name;
		yourself
]

{ #category : #accessing }
GtRrPluggableManager >> codeSync [

	^ codeSyncManager ifNotNil: #codeSync
]

{ #category : #accessing }
GtRrPluggableManager >> codeSyncManager [
	^ codeSyncManager
]

{ #category : #accessing }
GtRrPluggableManager >> codeSyncManager: anObject [
	codeSyncManager := anObject
]

{ #category : #'as yet unclassified' }
GtRrPluggableManager >> poolSize [

	^ workerManager poolSize
]

{ #category : #'as yet unclassified' }
GtRrPluggableManager >> poolSize: anInteger [

	workerManager poolSize: anInteger
]

{ #category : #'api - worker' }
GtRrPluggableManager >> registerWorker: aWorkerConnection [
	"Subclasses can provide additional actions to perform when a worker is registered"

	serverManager registerWorker: aWorkerConnection.
	workerManager ifNotNil: [ workerManager registerWorker: aWorkerConnection ].
	codeSyncManager ifNotNil: [ codeSyncManager registerWorker: aWorkerConnection ].
]

{ #category : #accessing }
GtRrPluggableManager >> remoteRunner [
	^ remoteRunner
]

{ #category : #accessing }
GtRrPluggableManager >> remoteRunner: aGtRemoteRunner [

	remoteRunner := aGtRemoteRunner.
	serverManager ifNotNil: [ serverManager remoteRunner: remoteRunner ].
	workerManager ifNotNil: [ workerManager remoteRunner: remoteRunner ].
	codeSyncManager ifNotNil: [ codeSyncManager remoteRunner: remoteRunner ].
]

{ #category : #accessing }
GtRrPluggableManager >> serverManager [
	^ serverManager
]

{ #category : #accessing }
GtRrPluggableManager >> serverManager: anObject [
	serverManager := anObject
]

{ #category : #'as yet unclassified' }
GtRrPluggableManager >> shouldTerminateJobsOnNoWorkers [
	"Answer a boolean indicating whether jobs should be terminated if the last worker unregisters."
	^ false
]

{ #category : #'startup - shutdown' }
GtRrPluggableManager >> shutdown [ 

	self stopInImageWorker.
	codeSyncManager ifNotNil: [ codeSyncManager shutdown ].
	workerManager ifNotNil: [ workerManager shutdown ].
	serverManager shutdown.
]

{ #category : #'startup - shutdown' }
GtRrPluggableManager >> startHeartbeatContext [
	"Schedule the worker heartbeat checks"

	remoteRunner timeoutManager addContext: (GtRrHeartbeatContext remoteRunner: remoteRunner)
]

{ #category : #'startup - shutdown' }
GtRrPluggableManager >> startInImageWorker [
	"Start a worker in the same image as the runner"

	^ inImageWorker := GtRrInImageWorker new
		remoteRunner: remoteRunner;
		start.
]

{ #category : #'startup - shutdown' }
GtRrPluggableManager >> startup [ 

	serverManager startup.
	workerManager ifNotNil: [ workerManager startup ].
	codeSyncManager ifNotNil: [ codeSyncManager startup ].
	self startHeartbeatContext.
]

{ #category : #'startup - shutdown' }
GtRrPluggableManager >> stopInImageWorker [

	inImageWorker ifNotNil: [ inImageWorker stop ].
	inImageWorker := nil.
]

{ #category : #accessing }
GtRrPluggableManager >> workerManager [
	^ workerManager
]

{ #category : #accessing }
GtRrPluggableManager >> workerManager: anObject [
	workerManager := anObject
]

{ #category : #accessing }
GtRrPluggableManager >> workerTerminationStrategy [
	^ workerTerminationStrategy
]

{ #category : #accessing }
GtRrPluggableManager >> workerTerminationStrategy: anObject [
	workerTerminationStrategy := anObject
]
