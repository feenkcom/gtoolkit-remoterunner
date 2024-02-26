Class {
	#name : #GtRrResultProcessingErrorAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'workerId',
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
	self 	
		workerId: dataParts seventh;
		errorDetails: dataParts eighth.
]

{ #category : #printing }
GtRrResultProcessingErrorAnnouncement >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< workerId asString;
		<< ' | ';
		<< errorDetails asString.
]

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> workerId [

	^ workerId
]

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> workerId: anObject [

	workerId := anObject
]
