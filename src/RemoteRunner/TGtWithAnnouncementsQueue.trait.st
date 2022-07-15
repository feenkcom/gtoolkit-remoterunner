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
TGtWithAnnouncementsQueue >> registerAnnouncementsQueue [
	"Register a queue that stores announcements."
	self assert: [ announcementQueue isNil ].
	
	announcementQueue := GtRemoteAnnouncementQueue onAnnouncer: self
]
