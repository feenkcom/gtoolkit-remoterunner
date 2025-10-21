Class {
	#name : #GtRrAnnouncementQueueDeliveryAnnouncement,
	#superclass : #GtRrAnnouncementQueueSignal,
	#instVars : [
		'announcementsCount'
	],
	#category : 'RemoteRunner-Logging-Signals'
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

{ #category : #printing }
GtRrAnnouncementQueueDeliveryAnnouncement >> printOneLineContentsOn: stream [

	stream 
		<< 'count: '
		print: announcementsCount
]
