Class {
	#name : #GtRrWorkerOperationShutdownAnnouncement,
	#superclass : #GtRrWorkerOperationAnnouncement,
	#instVars : [
		'reason'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #serialization }
GtRrWorkerOperationShutdownAnnouncement >> asDataForRemoteSerialize [

	^ super asDataForRemoteSerialize
		at: #reson put: reason;
		yourself.
]

{ #category : #serialization }
GtRrWorkerOperationShutdownAnnouncement >> initializeFromSlotData: aDictionary [ 

	super initializeFromSlotData: aDictionary.
	reason := aDictionary at: #reason.
]

{ #category : #accessing }
GtRrWorkerOperationShutdownAnnouncement >> printOneLineContentsOn: stream [

	reason ifNotNil:
		[ stream << reason asString ].
]

{ #category : #accessing }
GtRrWorkerOperationShutdownAnnouncement >> reason [
	^ reason
]

{ #category : #accessing }
GtRrWorkerOperationShutdownAnnouncement >> reason: anObject [
	reason := anObject
]
