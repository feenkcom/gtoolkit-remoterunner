Class {
	#name : #GtRrWorkerRegisteredAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'workerCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #serialization }
GtRrWorkerRegisteredAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	self
		basicTimestamp: aTimestamp;
		remoteAddressString: dataParts third;
		workerAttributes: (self class evaluate: dataParts fifth).
]

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
