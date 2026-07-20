Class {
	#name : #GtRrWorkerApplyChangeLogEvent,
	#superclass : #GtRrWorkerChangesLogEvent,
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrWorkerApplyChangeLogEvent class >> eventLabel [
	^ 'Worker Apply Change Event'
]

{ #category : #printing }
GtRrWorkerApplyChangeLogEvent >> descriptionOn: aStream [

	super descriptionOn: aStream.
		
	"aStream << ' | changeId='.
	aStream << self ombuEntryReferenceName"
]

{ #category : #accessing }
GtRrWorkerApplyChangeLogEvent >> ombuEntryReferenceName [
	^self eventStartedSignal ombuEntryReferenceName
]
