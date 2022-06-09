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
GtRrManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the RemoteRunner:
	- Start the PharoLinkWorkerServer
	- Create an in-image worker
	Subclasses can perform additional actions"
	| server |

	server := PharoLinkServer new
		listenPort: remoteRunner port;
		setDebugMode;
		start;
		setCloseOnExec: true;
		yourself.
	server globals at: #GtAssignedRemoteRunner put: remoteRunner.
	inImageWorker := GtRrInImageWorker new
		remoteRunner: remoteRunner;
		start.
	remoteRunner server: server.
]
