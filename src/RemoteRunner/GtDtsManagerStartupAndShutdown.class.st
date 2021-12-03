Class {
	#name : #GtDtsManagerStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtDtsManagerStartupAndShutdown >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtDtsManagerStartupAndShutdown >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #'startup - shutdown' }
GtDtsManagerStartupAndShutdown >> shutdown [ 
	"Perform any actions associated with stopping the DTS cluster:
	- Stop the PharoLinkWorkerServer
	Subclasses can perform additional actions"

	remoteRunner server stop.
]

{ #category : #'startup - shutdown' }
GtDtsManagerStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the DTS cluster:
	- Start the PharoLinkWorkerServer
	Subclasses can perform additional actions"
	| server |

	server := PharoLinkServer new
		listenPort: remoteRunner port;
		setDebugMode;
		start;
		yourself.
	server globals at: #GtAssignedRemoteRunner put: remoteRunner.
	remoteRunner server: server.
]
