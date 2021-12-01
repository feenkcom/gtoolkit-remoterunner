Class {
	#name : #GtDtsManagerStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'manager'
	],
	#category : #'RemoteRunner-DistributedTesting'
}

{ #category : #'startup - shutdown' }
GtDtsManagerStartupAndShutdown >> shutdown [ 
	"Perform any actions associated with stopping the DTS cluster:
	- Stop the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	manager server stop.
]

{ #category : #'startup - shutdown' }
GtDtsManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the DTS cluster:
	- Start the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	manager server: (PharoLinkWorkerServer new
		listenPort: manager port;
		setDebugMode;
		start;
		yourself).
	
]
