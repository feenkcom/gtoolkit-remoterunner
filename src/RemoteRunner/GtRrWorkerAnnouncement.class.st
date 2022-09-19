Class {
	#name : #GtRrWorkerAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'worker',
		'remoteAddressString',
		'workerAttributes'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerAnnouncement class >> worker: aGtRrWorkerRemote [

	^ self new 
		worker: aGtRrWorkerRemote
]

{ #category : #serialization }
GtRrWorkerAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #remoteAddressString put: self remoteAddressString;
		at: #workerAttributes put: self workerAttributes;
		yourself.
]

{ #category : #serialization }
GtRrWorkerAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.
	
	self remoteAddressString: (aDictionary at: #remoteAddressString).
	self workerAttributes: (aDictionary at: #workerAttributes).
]

{ #category : #printing }
GtRrWorkerAnnouncement >> printOneLineContentsOn: stream [

	(self worker isNil and: [
		self remoteAddressString isNil ]) ifTrue: [ ^ self ].
		
	stream 
		<< self remoteAddressString;
		space;
		<< self workingDirectory
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> remoteAddressString [
	^ remoteAddressString
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> remoteAddressString: anAddressString [ 
	remoteAddressString := anAddressString
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker [

	^ worker
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker: anObject [

	worker := anObject.
	self remoteAddressString:  worker remoteAddressString.
	self workerAttributes:  (worker details ifNil: [ Dictionary new])
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workerAttributes [
	^ workerAttributes
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workerAttributes: aDictionary [ 
	workerAttributes := aDictionary
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workingDirectory [
	^ self workerAttributes
		at: #workingDirectory 
		ifAbsent: [ '<unknown directory>' ]
]
