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

	workerAttributes := Dictionary new.
	self
		basicTimestamp: aTimestamp;
		workerId: dataParts third;
		remoteAddressString: dataParts fourth;
		workingDirectory: dataParts fifth;
		reason: dataParts sixth;
		workerCount: dataParts seventh asNumber.
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
