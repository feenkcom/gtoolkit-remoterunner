Class {
	#name : #GtRrAnnouncementQueueDeliveryAnnouncement,
	#superclass : #GtRrAnnouncementQueueAnnouncement,
	#instVars : [
		'announcementsCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrAnnouncementQueueDeliveryAnnouncement class >> eventType [
	^ GtRrAnnouncementQueueDeliveryEvent
]

{ #category : #accessing }
GtRrAnnouncementQueueDeliveryAnnouncement >> announcementsCount [
	^ announcementsCount
]

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
