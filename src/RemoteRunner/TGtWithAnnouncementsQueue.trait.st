"
{{gtClass:TGtWithAnnouncementsQueue}} is an utily trait that adds a {{gtClass:name=GtRemoteAnnouncementQueue}} to an object. The object needs to control the lifecycle of the queue.
"
Trait {
	#name : #TGtWithAnnouncementsQueue,
	#instVars : [
		'announcementQueue'
	],
	#category : #'RemoteRunner-AnnouncementQueue'
}

{ #category : #'announcements - queue' }
TGtWithAnnouncementsQueue >> announcementQueue [
	^ announcementQueue
]

{ #category : #'announcements - queue' }
TGtWithAnnouncementsQueue >> pollSerializedAnnouncementQueue [
	^ self announcementQueue pollSerialized
]

{ #category : #'announcements - queue' }
TGtWithAnnouncementsQueue >> registerAnnouncementsQueue [
	"Register a queue that stores announcements."
	self assert: [ announcementQueue isNil ].
	
	self 
		registerAnnouncementsQueueForAnnouncementType: Announcement
]

{ #category : #'announcements - queue' }
TGtWithAnnouncementsQueue >> registerAnnouncementsQueueForAnnouncementType: anAnnouncementType [
	"Register a queue that stores announcements."
	self assert: [ announcementQueue isNil ].
	
	announcementQueue := GtRemoteAnnouncementQueue 
		onAnnouncingObject: self
		withAnnouncementType: anAnnouncementType
]
