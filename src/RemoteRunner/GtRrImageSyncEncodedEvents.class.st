"
GtRrImageSyncEncodedEvents holds a pre-serialised collection of Epicea events ready for replay on a worker machine.
"
Class {
	#name : #GtRrImageSyncEncodedEvents,
	#superclass : #Object,
	#instVars : [
		'encodedEvents',
		'sessionHistory'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrImageSyncEncodedEvents class >> leJsonV4Name [

	^ #gtRrChangesSyncEncodedEvents
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> encodedChangesFrom: anOmReference [

	(sessionHistory includes: anOmReference) ifFalse:
		[ (GtRrUnknownOmReference omReference: anOmReference source: self) signal ].
	^ encodedEvents.
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> encodedEvents [

	^ encodedEvents
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> encodedEvents: anObject [

	encodedEvents := anObject
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> events [
	"Answer the unencoded events."

	^ STON fromString: encodedEvents.
]

{ #category : #'as yet unclassified' }
GtRrImageSyncEncodedEvents >> gtEntriesFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Entries';
		priority: 20;
		items: [ STON fromString: encodedEvents ];
		column: 'Entry' text:
			[ :entry | entry content printString ]
]

{ #category : #ui }
GtRrImageSyncEncodedEvents >> gtSessionHistoryFor: aView [
	<gtView>

	sessionHistory ifNil: [ ^ aView empty ].
	^ aView list
		title: 'Session history';
		priority: 20;
		items: [ sessionHistory ].
]

{ #category : #testing }
GtRrImageSyncEncodedEvents >> includesReference: anOmReference [
	"Answer a boolean indicating whether anOmReference is part of the receiver's session history"

	^ sessionHistory includes: anOmReference
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> sessionHistory [

	^ sessionHistory
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> sessionHistory: aSequencableCollection [

	sessionHistory := aSequencableCollection asArray
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> updateEncodedEvents [
	"Update the receiver's encoded events.
	By default the collection of events is considered fixed and no update is required.
	Subclasses may overwrite with appropriate behaviour."
]
