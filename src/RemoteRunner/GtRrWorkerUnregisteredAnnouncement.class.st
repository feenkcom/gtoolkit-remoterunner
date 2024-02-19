Class {
	#name : #GtRrWorkerUnregisteredAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'reason',
		'workerCount'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #serialization }
GtRrWorkerUnregisteredAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	self
		basicTimestamp: aTimestamp;
		remoteAddressString: dataParts third;
		reason: dataParts sixth;
		workerAttributes: (self class evaluate: dataParts fifth).
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> reason [

	^ reason
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> reason: anObject [

	reason := anObject
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> workerCount [
	^ workerCount
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> workerCount: anObject [
	workerCount := anObject
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> workerDetailsForLog [
	^ {self reason asString. workerCount asString. }
]
