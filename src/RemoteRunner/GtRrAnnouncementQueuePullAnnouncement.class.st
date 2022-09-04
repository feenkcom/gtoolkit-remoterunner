Class {
	#name : #GtRrAnnouncementQueuePullAnnouncement,
	#superclass : #GtRrAnnouncementQueueAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrAnnouncementQueuePullAnnouncement class >> eventType [
	^ GtRrAnnouncementQueuePullEvent
]
