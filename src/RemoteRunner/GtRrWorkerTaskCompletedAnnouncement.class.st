Class {
	#name : #GtRrWorkerTaskCompletedAnnouncement,
	#superclass : #GtRrWorkerTaskAnnouncement,
	#instVars : [
		'message'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerTaskCompletedAnnouncement >> message [

	^ message
]

{ #category : #accessing }
GtRrWorkerTaskCompletedAnnouncement >> message: anObject [

	message := anObject
]

{ #category : #printing }
GtRrWorkerTaskCompletedAnnouncement >> printOneLineContentsOn: stream [

	task ifNil: [ ^ self ].
	stream 
		print: task taskContextId;
		<< ': ';
		print: message
]
