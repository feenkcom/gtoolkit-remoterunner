Class {
	#name : #GtRrMqManagerStartupAndShutdown,
	#superclass : #GtRrManagerStartupAndShutdown,
	#category : #'RemoteRunner-Runner'
}

{ #category : #'startup - shutdown' }
GtRrMqManagerStartupAndShutdown >> shutdown [
self halt.
	remoteRunner critical:
		[ remoteRunner registeredWorkersDo: [ :worker |
			worker stop ] ].
	super shutdown.
]

{ #category : #'startup - shutdown' }
GtRrMqManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the RemoteRunner:
	- Start the PharoLinkWorkerServer
	Subclasses can perform additional actions"
	| server |

	server := GtRrMqServer new
		remoteRunner: remoteRunner.
	remoteRunner server: server.
	server start.
	self startHeartbeatContext.
]
