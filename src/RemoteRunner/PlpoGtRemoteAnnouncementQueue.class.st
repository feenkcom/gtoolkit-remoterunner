Class {
	#name : #PlpoGtRemoteAnnouncementQueue,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-AnnouncementQueue'
}

{ #category : #accessing }
PlpoGtRemoteAnnouncementQueue class >> remoteClassName [

	^ #GtRemoteAnnouncementQueue
]

{ #category : #accessing }
PlpoGtRemoteAnnouncementQueue >> poll [
	^ self proxyPerform: #poll
]

{ #category : #accessing }
PlpoGtRemoteAnnouncementQueue >> pollSerialized [
	^ self proxyPerform: #pollSerialized
]
