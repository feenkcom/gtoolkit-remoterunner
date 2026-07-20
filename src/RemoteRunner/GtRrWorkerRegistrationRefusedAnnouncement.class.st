Class {
	#name : #GtRrWorkerRegistrationRefusedAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'currentlyExecutingJobIds'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'api - worker' }
GtRrWorkerRegistrationRefusedAnnouncement >> currentlyExecutingJobIds: aCollection [ 
	currentlyExecutingJobIds := aCollection
]

{ #category : #accessing }
GtRrWorkerRegistrationRefusedAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	super initializeFromTimestamp: aTimestamp andData: dataParts.
	currentlyExecutingJobIds := self class evaluate: (dataParts at: 7).
]

{ #category : #printing }
GtRrWorkerRegistrationRefusedAnnouncement >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream 
		<< ' | ';
		<< currentlyExecutingJobIds storeString
]
