Class {
	#name : #GtRrAnnouncementQueueDeliveryAnnouncement,
	#superclass : #GtRrAnnouncementQueueAnnouncement,
	#instVars : [
		'announcementsCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrAnnouncementQueueDeliveryAnnouncement >> announcementsCount: anInteger [
	announcementsCount := anInteger
]

{ #category : #accessing }
GtRrAnnouncementQueueDeliveryAnnouncement >> printOneLineContentsOn: stream [

	stream 
		<< 'count: '
		print: announcementsCount
]
