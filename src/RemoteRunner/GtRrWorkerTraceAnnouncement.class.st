Class {
	#name : #GtRrWorkerTraceAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'message'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerTraceAnnouncement >> emit [
	"Disable as they are mostly noise unless there is something really wrong."
]

{ #category : #accessing }
GtRrWorkerTraceAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	super initializeFromTimestamp: aTimestamp andData: dataParts.
	message := dataParts at: 7.
]

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

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< message asString
]
