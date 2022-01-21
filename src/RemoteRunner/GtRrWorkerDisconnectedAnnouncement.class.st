Class {
	#name : #GtRrWorkerDisconnectedAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'reason'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerDisconnectedAnnouncement >> reason [

	^ reason
]

{ #category : #accessing }
GtRrWorkerDisconnectedAnnouncement >> reason: anObject [

	reason := anObject
]
