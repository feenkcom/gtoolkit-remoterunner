Class {
	#name : #GtRrStatusMessageChangedAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'statusMessage'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #converting }
GtRrStatusMessageChangedAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #statusMessage put: self statusMessage asDictionaryForExport;
		yourself.
]

{ #category : #initialization }
GtRrStatusMessageChangedAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.

	statusMessage := GtRrStatusMessage 
		fromJSONDictionary:  (aDictionary at: #taskExecutionResult).
]

{ #category : #accessing }
GtRrStatusMessageChangedAnnouncement >> statusMessage [
	^ statusMessage
]

{ #category : #accessing }
GtRrStatusMessageChangedAnnouncement >> statusMessage: aStatusMessage [
	statusMessage := aStatusMessage
]
