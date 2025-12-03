Class {
	#name : #PlpoGtRrManagerStartupAndShutdown,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
PlpoGtRrManagerStartupAndShutdown class >> remoteClassName [

	^ #GtRrManagerStartupAndShutdown
]

{ #category : #'startup - shutdown' }
PlpoGtRrManagerStartupAndShutdown >> startInImageWorker [ 

	^ self proxyPerform: #startInImageWorker.
]
