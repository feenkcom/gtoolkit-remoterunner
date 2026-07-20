Class {
	#name : #GtRrCodeSyncApplyChangeSignal,
	#superclass : #GtRrCodeSyncSignal,
	#instVars : [
		'ombuEntryReferenceName'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrCodeSyncApplyChangeSignal class >> eventType [
	^GtRrCodeSyncApplyChangeLogEvent
]

{ #category : #initialization }
GtRrCodeSyncApplyChangeSignal >> initializeFromOmbuEntry: anOmbuEntry [
	ombuEntryReferenceName := (anOmbuEntry 
		tags 
			at:  #self
			ifPresent: [ :aReference| aReference shortName ]
			ifAbsent: [ nil ]) .
]

{ #category : #initialization }
GtRrCodeSyncApplyChangeSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 
	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	ombuEntryReferenceName := aCollection third.
]

{ #category : #accessing }
GtRrCodeSyncApplyChangeSignal >> ombuEntryReferenceName [
	^ombuEntryReferenceName
]

{ #category : #printing }
GtRrCodeSyncApplyChangeSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< self ombuEntryReferenceName asString
]

{ #category : #accessing }
GtRrCodeSyncApplyChangeSignal >> signalTypeLabel [

	^ 'GtRrCodeSyncApplyChangeEvent'
]
