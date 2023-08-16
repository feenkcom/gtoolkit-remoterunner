Class {
	#name : #GtRrWorkerRegisteredAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerRegisteredAnnouncement >> workerDetailsForLog [
	^ { workerAttributes storeString }
]
