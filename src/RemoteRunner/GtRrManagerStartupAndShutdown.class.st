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

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> shutdown [ 
	"Perform any actions associated with stopping the DTS cluster:
	- Stop the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	remoteRunner server stop.
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> startInImageWorker [
	"Start a worker in the same image as the runner"

	inImageWorker := GtRrInImageWorker new
		remoteRunner: remoteRunner;
		start.
]

{ #category : #'startup - shutdown' }
GtRrManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the RemoteRunner:
	- Start the PharoLinkWorkerServer
	Subclasses can perform additional actions"
	| server |

	server := PharoLinkServer new
		listenPort: remoteRunner port;
		setDebugMode;
		start;
		setCloseOnExec: true;
		yourself.
	server globals at: #GtAssignedRemoteRunner put: remoteRunner.
	remoteRunner server: server.
]
