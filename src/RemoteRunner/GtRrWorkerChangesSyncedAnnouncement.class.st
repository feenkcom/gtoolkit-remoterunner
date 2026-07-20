Class {
	#name : #GtRrWorkerChangesSyncedAnnouncement,
	#superclass : #GtRrWorkerChangesSyncAnnouncement,
	#instVars : [
		'events'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerChangesSyncedAnnouncement >> events [

	^ events
]

{ #category : #accessing }
GtRrWorkerChangesSyncedAnnouncement >> events: anObject [

	events := anObject
]
