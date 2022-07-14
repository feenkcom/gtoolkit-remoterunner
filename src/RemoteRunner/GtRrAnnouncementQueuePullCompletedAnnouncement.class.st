Class {
	#name : #GtRrAnnouncementQueuePullCompletedAnnouncement,
	#superclass : #GtRrAnnouncementQueuePullAnnouncement,
	#instVars : [
		'retrivedAnnouncementCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedAnnouncement >> printOneLineContentsOn: stream [

	stream 
		<< 'count: '
		print: retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedAnnouncement >> retrivedAnnouncementCount: anInteger [
	retrivedAnnouncementCount := anInteger
]
