Class {
	#name : #PlpoGtRemoteAnnouncementQueue,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
PlpoGtRemoteAnnouncementQueue class >> remoteClassName [

	^ #GtRemoteAnnouncementQueue
]

{ #category : #accessing }
PlpoGtRemoteAnnouncementQueue >> poll [
	^ (self newCommandFactory
		<< 'self poll asArray';
		sendAndWait) getValue
]
