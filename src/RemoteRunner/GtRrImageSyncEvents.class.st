Class {
	#name : #GtRrImageSyncEvents,
	#superclass : #Object,
	#instVars : [
		'encodedEvents',
		'sessionHistory',
		'events'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrImageSyncEvents class >> leJsonV4Name [

	^ #gtRrImageSyncEvents
]

{ #category : #accessing }
GtRrImageSyncEvents >> changesFrom: anOmReference [

	(sessionHistory includes: anOmReference) ifFalse:
		[ (GtRrUnknownOmReference omReference: anOmReference source: self) signal ].
	^ events.
]

{ #category : #accessing }
GtRrImageSyncEvents >> encodedChangesFrom: anOmReference [

	(sessionHistory includes: anOmReference) ifFalse:
		[ (GtRrUnknownOmReference omReference: anOmReference source: self) signal ].
	^ self encodedEvents.
]

{ #category : #accessing }
GtRrImageSyncEvents >> encodedEvents [

	^ encodedEvents ifNil: [ encodedEvents := STON toString: events ]
]

{ #category : #accessing }
GtRrImageSyncEvents >> encodedEvents: aCollection [

	encodedEvents := aCollection
]

{ #category : #accessing }
GtRrImageSyncEvents >> events [
	^ events
]

{ #category : #accessing }
GtRrImageSyncEvents >> events: anObject [
	events := anObject
]

{ #category : #'as yet unclassified' }
GtRrImageSyncEvents >> gtEntriesFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Entries';
		priority: 20;
		items: [ events ];
		column: 'Entry' text:
			[ :entry | entry content printString ]
]

{ #category : #ui }
GtRrImageSyncEvents >> gtSessionHistoryFor: aView [
	<gtView>

	sessionHistory ifNil: [ ^ aView empty ].
	^ aView list
		title: 'Session history';
		priority: 20;
		items: [ sessionHistory ].
]

{ #category : #testing }
GtRrImageSyncEvents >> includesReference: anOmReference [
	"Answer a boolean indicating whether anOmReference is part of the receiver's session history"

	^ sessionHistory includes: anOmReference
]

{ #category : #accessing }
GtRrImageSyncEvents >> sessionHistory [

	^ sessionHistory
]

{ #category : #accessing }
GtRrImageSyncEvents >> sessionHistory: aSequencableCollection [

	sessionHistory := aSequencableCollection asArray
]

{ #category : #accessing }
GtRrImageSyncEvents >> updateEncodedEvents [
	"Update the receiver's encoded events.
	By default the collection of events is considered fixed and no update is required.
	Subclasses may overwrite with appropriate behaviour."
]
