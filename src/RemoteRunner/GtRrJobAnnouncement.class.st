Class {
	#name : #GtRrJobAnnouncement,
	#superclass : #GtRrAnnouncement,
	#instVars : [
		'job'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrJobAnnouncement class >> job: aGtRrJob [

	^ self new job: aGtRrJob
]

{ #category : #accessing }
GtRrJobAnnouncement >> job [

	^ job
]

{ #category : #accessing }
GtRrJobAnnouncement >> job: anObject [

	job := anObject
]
