Class {
	#name : #GtRemoteAnnouncementQueue,
	#superclass : #Object,
	#instVars : [
		'queue'
	],
	#category : #'RemoteRunner-AnnouncementQueue'
}

{ #category : #jsonV4 }
GtRemoteAnnouncementQueue class >> leJsonV4Name [

	^ #gtRemoteAnnouncementQueue
]

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
GtRemoteAnnouncementQueue >> queue [
	^ queue
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> subscribeAnnouncingObject: anAnnouncingObject [
	anAnnouncingObject 
		when: Announcement send: #onAnnouncement: to: self
]
