"
{{gtClass:GtRrManagerStartupAndShutdown}} controls the lifecycle for the runner by proving several hooks:
	- {{gtMethod:GtRrManagerStartupAndShutdown>>startup|label=#selector}}: action executed once when the runner is started
	- {{gtMethod:GtRrManagerStartupAndShutdown>>shutdown|label=#selector}}: action executed once when the runner is stopped.
	
This class can be used to manage resources needed by the runner, like worker processes.
"
Class {
	#name : #GtRrManagerStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'remoteRunner',
		'inImageWorker'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrManagerStartupAndShutdown >> asStatsDictionary [

	^ Dictionary new
		at: #name put: self class name;
		yourself
]

{ #category : #'api - worker' }
GtRrManagerStartupAndShutdown >> registerWorker: aWorkerConnection [
	"Subclasses can provide additional actions to perform when a worker is registered"

]

{ #category : #accessing }
GtRrManagerStartupAndShutdown >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrManagerStartupAndShutdown >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #testing }
GtRrManagerStartupAndShutdown >> shouldTerminateJobsOnNoWorkers [
	"Answer a boolean indicating whether jobs should be terminated if the last worker unregisters."
	
	^ false
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> shutdown [ 
	"Perform any actions associated with stopping the DTS cluster:
	- Stop the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	inImageWorker ifNotNil:
		[ inImageWorker stop ].
	remoteRunner server ifNotNil:
		[ :server | server stop ].
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> startHeartbeatContext [
	"Schedule the worker heartbeat checks"

	remoteRunner timeoutManager addContext: (GtRrHeartbeatContext remoteRunner: remoteRunner)
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> startInImageDebugWorker [
	"Start a worker in the same image as the runner"

	^ inImageWorker := GtRrInImageWorker new
		remoteRunner: remoteRunner;
		exceptionHandlingStrategy: GtRrTaskDebuggerExceptionStrategy new;
		start.
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> startInImageWorker [
	"Start a worker in the same image as the runner"

	^ inImageWorker := GtRrInImageWorker new
		remoteRunner: remoteRunner;
		start.
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the RemoteRunner:
	- Start the PharoLinkWorkerServer
	Subclasses can perform additional actions"
	| server port |

	port := remoteRunner port.
	port = #none ifFalse:
		[ server := PharoLinkServer new
			listenPort: port;
			setDebugMode;
			start;
			closeOnExec: true;
			yourself.
		server globals at: #GtAssignedRemoteRunner put: remoteRunner.
		remoteRunner server: server ].
	self startHeartbeatContext.
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> stopInImageWorker [

	inImageWorker ifNotNil: [ inImageWorker stop ].
	inImageWorker := nil.
]
