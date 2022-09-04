Class {
	#name : #GtRrAnnouncementQueuePullCompletedAnnouncement,
	#superclass : #GtRrAnnouncementQueuePullAnnouncement,
	#instVars : [
		'retrivedAnnouncementCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #testing }
GtRrAnnouncementQueuePullCompletedAnnouncement class >> isEndSignalType [
	^ true
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedAnnouncement >> announcementsCount [
	^ self retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedAnnouncement >> printOneLineContentsOn: stream [

	stream 
		<< 'count: '
		print: retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedAnnouncement >> retrivedAnnouncementCount [
	^ retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedAnnouncement >> retrivedAnnouncementCount: anInteger [
	retrivedAnnouncementCount := anInteger
]
