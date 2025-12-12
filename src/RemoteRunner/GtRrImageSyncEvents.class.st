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

{ #category : #serialization }
GtRrImageSyncEvents class >> deSerializeAllImplementorsInstances [
	"Answer a collection of instances to be tested for serialisation / deserialisation"

	^ { self new events: #() }
]

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
	<return: #GtRrImageSync>

	^ encodedEvents ifNil: [ encodedEvents := (GtRrImageSync forChanges: events) entries: events ]
]

{ #category : #'private - serialization' }
GtRrImageSyncEvents >> encodedEvents: aGtRrImageSync [

	encodedEvents := aGtRrImageSync
]

{ #category : #accessing }
GtRrImageSyncEvents >> events [
	^ events
]

{ #category : #accessing }
GtRrImageSyncEvents >> events: aCollection [
	"The entries are a collection of {{gtClass:OmEntry}}"

	events := aCollection
]

{ #category : #ui }
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
