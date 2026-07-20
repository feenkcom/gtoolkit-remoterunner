Class {
	#name : #GtRrResultProcessingErrorAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'errorInfo'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> errorInfo [
	^errorInfo
]

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> errorInfo: anObject [
	errorInfo := anObject
]

{ #category : #printing }
GtRrResultProcessingErrorAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	super initializeFromTimestamp: aTimestamp andData: dataParts.
	self errorInfo: (self class compiler evaluate: dataParts seventh).
]

{ #category : #printing }
GtRrResultProcessingErrorAnnouncement >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< errorInfo storeString.
]
