Class {
	#name : #GtRrTaskCompletedAnnouncement,
	#superclass : #GtRrTaskAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #converting }
GtRrTaskCompletedAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #taskResult put: self computeTaskResult;
		at: #executionData put: self computeExecutionData;
		yourself.
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> computeExecutionData [
	^ task executionData
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> computeTaskResult [
	^ task result
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> executionData [

	^ task
		ifNil: [ self properties at: #executionData ]
		ifNotNil: [ self computeExecutionData ].
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> executionData: anExecutionData [

	self properties at: #executionData put: anExecutionData
]

{ #category : #initialization }
GtRrTaskCompletedAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.
	
	self taskResult: (aDictionary at: #taskResult).
	self executionData: (aDictionary at: #executionData)
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> taskResult [

	^ task
		ifNil: [ self properties at: #taskResult ]
		ifNotNil: [ self computeTaskResult ].
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> taskResult: aResult [

	self properties at: #taskResult put: aResult
]
