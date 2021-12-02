Class {
	#name : #GtDtsLocalManagerStartupAndShutdown,
	#superclass : #GtDtsManagerStartupAndShutdown,
	#instVars : [
		'pool'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'startup - shutdown' }
GtDtsLocalManagerStartupAndShutdown >> shutdown [ 

	pool stop.
	super shutdown.

]

{ #category : #'startup - shutdown' }
GtDtsLocalManagerStartupAndShutdown >> startup [ 

	super startup.
	pool := PharoLinkWorkerLocalPool new
		size: 2;
		server: manager server;
		start;
		yourself
]
