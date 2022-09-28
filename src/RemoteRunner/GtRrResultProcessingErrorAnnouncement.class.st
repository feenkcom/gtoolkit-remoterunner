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
GtRrResultProcessingErrorAnnouncement >> printOneLineContentsOn: aStream [

	(workerId isNil and: [ errorDetails isNil ]) ifTrue: [ ^ super printOneLineContentsOn: aStream ].
	workerId ifNotNil: [ aStream << workerId asString ].
	aStream << ': '.
	errorDetails ifNotNil: [ aStream << errorDetails errorMessage asString ].
]

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> workerId [

	^ workerId
]

{ #category : #accessing }
GtRrResultProcessingErrorAnnouncement >> workerId: anObject [

	workerId := anObject
]
