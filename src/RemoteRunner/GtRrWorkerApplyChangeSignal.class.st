Class {
	#name : #GtRrWorkerApplyChangeSignal,
	#superclass : #GtRrWorkerChangesSignal,
	#instVars : [
		'ombuEntryReferenceName'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerApplyChangeSignal class >> eventType [
	^GtRrWorkerApplyChangeLogEvent
]

{ #category : #initialization }
GtRrWorkerApplyChangeSignal >> initializeFromOmbuEntry: anOmbuEntry [
	ombuEntryReferenceName := (anOmbuEntry 
		tags 
			at:  #self
			ifPresent: [ :aReference| aReference shortName ]
			ifAbsent: [ nil ]) .
]

{ #category : #initialization }
GtRrWorkerApplyChangeSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 
	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	ombuEntryReferenceName := aCollection fifth.
]

{ #category : #accessing }
GtRrWorkerApplyChangeSignal >> ombuEntryReferenceName [
	^ombuEntryReferenceName
]

{ #category : #'as yet unclassified' }
GtRrWorkerApplyChangeSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< self ombuEntryReferenceName asString
]

{ #category : #accessing }
GtRrWorkerApplyChangeSignal >> signalTypeLabel [

	^ 'Worker Apply Change Signal'
]
