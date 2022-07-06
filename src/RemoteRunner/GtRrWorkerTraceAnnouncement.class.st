Class {
	#name : #GtRrWorkerTraceAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'message'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerTraceAnnouncement >> message [

	^ message
]

{ #category : #accessing }
GtRrWorkerTraceAnnouncement >> message: anObject [

	message := anObject
]

{ #category : #accessing }
GtRrWorkerTraceAnnouncement >> printOneLineContentsOn: stream [

	stream 
		print: message;
		<< ' from: '.
	super printOneLineContentsOn: stream.
]
