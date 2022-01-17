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

{ #category : #printing }
GtRrWorkerAnnouncement >> printOneLineContentsOn: stream [

	worker ifNil: [ ^ self ].
	stream 
		<< (worker remoteAddressString);
		space;
		<< (worker details at: #workingDirectory ifAbsent: [ '<unknown directory>' ])
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker [

	^ worker
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker: anObject [

	worker := anObject
]
