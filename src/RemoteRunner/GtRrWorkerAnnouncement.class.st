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

{ #category : #'gt - extensions' }
GtRrWorkerAnnouncement >> gtViewWorkerAttributesFor: aView [ 
	<gtView>	
	self workerAttributes ifNil: [ ^ aView empty ].
	
	^ aView forward 
		title: 'Worker attributes';
		object: [ self workerAttributes ];
		view: #gtItemsFor:
]

{ #category : #serialization }
GtRrWorkerAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.
	
	self remoteAddressString: (aDictionary at: #remoteAddressString).
	self workerAttributes: (aDictionary at: #workerAttributes).
]

{ #category : #printing }
GtRrWorkerAnnouncement >> printOneLineContentsOn: aStream [

	(self worker isNil and: [
		self remoteAddressString isNil ]) ifTrue: [ ^ self ].
		
	aStream 
		nextPut: $|; space;
		nextPutAll: 'WorkerSignal';
		space; nextPut: $|; space;
		nextPutAll: self workerId;
		space; nextPut: $|; space;
		nextPutAll: self remoteAddressString;
		space; nextPut: $|; space;
		nextPutAll: self workingDirectory;
		space; nextPut: $|; space.
	
	self workerDetailsForLog do: [ :aValue |
		aStream 
			nextPutAll: (aValue ifNil: [ '' ]);
			space; nextPut: $|; space ]. 

	aStream
		nextPutAll: self processId
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
	remoteAddressString ifNil:
		[ self remoteAddressString:  worker remoteAddressString ].
	self workerAttributes:  (worker attributes ifNil: [ Dictionary new])
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workerAttributes [
	^ workerAttributes
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workerAttributes: aDictionary [ 
	workerAttributes := aDictionary
]

{ #category : #printing }
GtRrWorkerAnnouncement >> workerDetailsForLog [
	^ #()
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workerId [
	^ self workerAttributes
		at: #id 
		ifAbsent: [ '<unknown directory>' ]
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> workingDirectory [
	^ self workerAttributes
		at: #workingDirectory 
		ifAbsent: [ '<unknown directory>' ]
]
