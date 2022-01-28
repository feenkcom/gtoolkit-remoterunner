Class {
	#name : #GtRrWorkerCommandAnnouncement,
	#superclass : #GtRrWorkerOperationAnnouncement,
	#instVars : [
		'command',
		'message'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerCommandAnnouncement >> command [

	^ command
]

{ #category : #accessing }
GtRrWorkerCommandAnnouncement >> command: anObject [

	command := anObject
]

{ #category : #accessing }
GtRrWorkerCommandAnnouncement >> message [

	^ message
]

{ #category : #accessing }
GtRrWorkerCommandAnnouncement >> message: anObject [

	message := anObject
]

{ #category : #printing }
GtRrWorkerCommandAnnouncement >> printOneLineContentsOn: stream [

	stream 
		print: command;
		<< ': ';
		print: message
]
