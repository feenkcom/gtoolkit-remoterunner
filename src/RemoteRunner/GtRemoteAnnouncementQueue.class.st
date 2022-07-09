Class {
	#name : #GtRemoteAnnouncementQueue,
	#superclass : #Object,
	#instVars : [
		'queue',
		'object'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #jsonV4 }
GtRemoteAnnouncementQueue class >> leJsonV4Name [

	^ #gtRemoteAnnouncementQueue
]

{ #category : #accessing }
GtRemoteAnnouncementQueue class >> onAnnouncer: anAnnouncingObject [
	^ self new
		object: anAnnouncingObject
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> initialize [
	queue := OrderedCollection new
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> object [
	^ object
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> object: anAnnouncingObject [ 
	object := anAnnouncingObject.
	self subscribeToObject
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
GtRemoteAnnouncementQueue >> queue [
	^ queue
]

{ #category : #accessing }
GtRemoteAnnouncementQueue >> subscribeToObject [
	object when: Announcement send: #onAnnouncement: to: self
]
