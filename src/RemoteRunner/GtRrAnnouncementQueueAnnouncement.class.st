Class {
	#name : #GtRrAnnouncementQueueAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #testing }
GtRrAnnouncementQueueAnnouncement class >> isEndSignalType [
	^ false
]

{ #category : #testing }
GtRrAnnouncementQueueAnnouncement class >> isStartSignalType [
	^ false
]
