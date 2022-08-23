Class {
	#name : #GtRrWorkerAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'worker'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerAnnouncement class >> worker: aGtRrWorkerRemote [

	^ self new worker: aGtRrWorkerRemote
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #remoteAddressString put: self remoteAddressString;
		yourself.
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> computeRemoteAddressString [
	^ worker remoteAddressString
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.
	
	self remoteAddressString: (aDictionary at: #remoteAddressString)
]

{ #category : #printing }
GtRrWorkerAnnouncement >> printOneLineContentsOn: stream [

	worker ifNil: [ ^ self ].
	stream 
		<< (worker remoteAddressString);
		space;
		<< (worker details at: #workingDirectory ifAbsent: [ '<unknown directory>' ])
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> remoteAddressString [
	^ self properties 
		at: #remoteAddressString 
		ifAbsent: [ self computeRemoteAddressString ]
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> remoteAddressString: anObject [ 
	self properties at: #remoteAddressString put: anObject
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker [

	^ worker
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker: anObject [

	worker := anObject.
	self remoteAddressString:  self computeRemoteAddressString
]
