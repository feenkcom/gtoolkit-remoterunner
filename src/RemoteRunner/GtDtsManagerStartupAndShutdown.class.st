Class {
	#name : #GtDtsManagerStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'rrManager'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'startup - shutdown' }
GtDtsManagerStartupAndShutdown >> shutdown [ 
	"Perform any actions associated with stopping the DTS cluster:
	- Stop the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	rrManager server stop.
]

{ #category : #'startup - shutdown' }
GtDtsManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the DTS cluster:
	- Start the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	rrManager server: (PharoLinkWorkerServer new
		listenPort: rrManager port;
		setDebugMode;
		start;
		yourself).
	
]
