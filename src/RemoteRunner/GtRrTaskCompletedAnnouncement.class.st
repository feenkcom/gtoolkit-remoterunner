Class {
	#name : #GtRrTaskCompletedAnnouncement,
	#superclass : #GtRrTaskAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #taskResult put: task result;
		yourself.
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.
	
	self properties at: #taskResult put: (aDictionary at: #taskResult)
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> taskResult [

	^ task
		ifNil: [ self properties at: #taskResult ]
		ifNotNil: [ task result ].
]
