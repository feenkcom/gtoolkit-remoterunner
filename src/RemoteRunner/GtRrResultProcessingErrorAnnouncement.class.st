Class {
	#name : #GtRrResultProcessingErrorAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'errorDetails'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> errorDetails: anObject [

	errorDetails := anObject
]

{ #category : #printing }
GtRrResultProcessingErrorAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	super initializeFromTimestamp: aTimestamp andData: dataParts.
	self errorDetails: dataParts seventh.
]

{ #category : #printing }
GtRrResultProcessingErrorAnnouncement >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< errorDetails asString.
]
