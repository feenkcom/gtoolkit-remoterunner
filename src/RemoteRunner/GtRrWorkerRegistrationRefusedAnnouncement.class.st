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

{ #category : #printing }
GtRrWorkerRegistrationRefusedAnnouncement >> printOneLineContentsOn: aStream [
	aStream 
		nextPut: $|; space;
		nextPutAll: 'WorkerSignal';
		space; nextPut: $|; space;
		nextPutAll: currentlyExecutingJobIds storeString;
		space; nextPut: $|; space;
		nextPutAll: workerAttributes storeString;
		space; nextPut: $|; space;
		nextPutAll: self processId
]
