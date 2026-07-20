Class {
	#name : #GtRrCodeSyncApplyChangeLogEvent,
	#superclass : #GtRrCodeSyncLogEvent,
	#category : 'RemoteRunner-Logging-Events'
}

{ #category : #acccessing }
GtRrCodeSyncApplyChangeLogEvent class >> eventLabel [
	^ 'Code Sync Apply Change Event'
]

{ #category : #printing }
GtRrCodeSyncApplyChangeLogEvent >> descriptionOn: aStream [

	super descriptionOn: aStream.
	
	"aStream << ' | changeId='.
	aStream << self ombuEntryReferenceName asString"
]
