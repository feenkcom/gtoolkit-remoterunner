Class {
	#name : #GtRrWorkerRegisteredAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'workerCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerRegisteredAnnouncement >> workerCount [
	^ workerCount
]

{ #category : #accessing }
GtRrWorkerRegisteredAnnouncement >> workerCount: anObject [
	workerCount := anObject
]

{ #category : #accessing }
GtRrWorkerRegisteredAnnouncement >> workerDetailsForLog [
	^ { workerAttributes storeString. workerCount asString }
]
