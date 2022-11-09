Class {
	#name : #GtRrWorkerImageSyncedAnnouncement,
	#superclass : #GtRrWorkerImageSyncAnnouncement,
	#instVars : [
		'events'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerImageSyncedAnnouncement >> events [

	^ events
]

{ #category : #accessing }
GtRrWorkerImageSyncedAnnouncement >> events: anObject [

	events := anObject
]
