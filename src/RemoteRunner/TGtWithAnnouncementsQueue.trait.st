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

{ #category : #'private - serialization' }
TGtWithAnnouncementsQueue >> announcementQueue: aQueue [
	"Set the receiver's announcementQueue.
	This should only be done as part of deserialization."

	announcementQueue := aQueue
]

{ #category : #'announcements - queue' }
TGtWithAnnouncementsQueue >> ensureAnnouncementsQueue [
	"Ensure the announcements queue has been registered"

	announcementQueue ifNil:
		[ self registerAnnouncementsQueueForAnnouncementType: Announcement ]
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
	"Ensure there is a queue that stores announcements."

	announcementQueue ifNotNil: [ ^ self ].
	
	announcementQueue := GtRemoteAnnouncementQueue 
		onAnnouncingObject: self
		withAnnouncementType: anAnnouncementType
]
