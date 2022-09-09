"
{{gtClass:name=GtRemoteAnnouncementQueue}} records announcements raised by an announcer-like object and stores them in a queue from where they can be retreived.

To work with the queue objects to be announcers or have a method similar to {{gtMethod:Announcer>>#when:send:to:}}, used in {{gtMethod:name=GtRemoteAnnouncementQueue>>subscribeAnnouncingObject:|label=#selector}}.
Polling announcements from the queue can be done using: 
	- {{gtMethod:GtRemoteAnnouncementQueue>>poll}} or
	- {{gtMethod:GtRemoteAnnouncementQueue>>pollSerialized}} 

"
Class {
	#name : #GtRemoteAnnouncementQueue,
	#superclass : #Object,
	#instVars : [
		'queue'
	],
	#category : #'RemoteRunner-AnnouncementQueue'
}

{ #category : #accessing }
GtRemoteAnnouncementQueue class >> onAnnouncer: anAnnouncingObject [
	^ self new
		initializeForAnnouncingObject: anAnnouncingObject
]

{ #category : #accessing }
GtRemoteAnnouncementQueue class >> onAnnouncingObject: anAnnouncingObject [
	^ self new
		initializeForAnnouncingObject: anAnnouncingObject
]

{ #category : #'gt - extensions' }
GtRemoteAnnouncementQueue >> gtViewQueueFor: aView [
	<gtView>
	
	^ aView list
		title: 'Queue';
		items: [ queue ]
]

{ #category : #initiailize }
GtRemoteAnnouncementQueue >> initialize [
	super initialize.
	queue := OrderedCollection new
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> initializeForAnnouncingObject: anAnnouncingObject [ 
	self subscribeAnnouncingObject: anAnnouncingObject 
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> onAnnouncement: anAnnouncement [
	queue add: anAnnouncement
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> poll [
	| results |
	results := queue.
	queue := OrderedCollection new.
	^ results
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> pollSerialized [
	^ self poll 
		collect: [ :anAnnouncement | 
			anAnnouncement serializeForRemoteDelivery ]
		as: Array
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> subscribeAnnouncingObject: anAnnouncingObject [
	"For now this only subscribes strongly to the object."
	
	anAnnouncingObject 
		when: Announcement send: #onAnnouncement: to: self
]
