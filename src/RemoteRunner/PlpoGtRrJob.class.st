Class {
	#name : #PlpoGtRrJob,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrJob class >> remoteClassName [

	^ #GtRrJob
]

{ #category : #accessing }
PlpoGtRrJob >> isFinished [

	^ self proxyPerform: #isFinished
]
