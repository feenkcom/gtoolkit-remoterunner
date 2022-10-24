Class {
	#name : #GtRrWorkerUnregisteredAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'reason'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> reason [

	^ reason
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> reason: anObject [

	reason := anObject
]
