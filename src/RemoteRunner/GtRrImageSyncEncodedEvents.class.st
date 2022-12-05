"
GtRrImageSyncEncodedEvents holds a pre-serialised collection of Epicea events ready for replay on a worker machine.
"
Class {
	#name : #GtRrImageSyncEncodedEvents,
	#superclass : #Object,
	#instVars : [
		'encodedEvents',
		'sessionHistory',
		'latestOmReference'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrImageSyncEncodedEvents class >> leJsonV4Name [

	^ #gtRrImageSyncEncodedEvents
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> encodedChangesFrom: anOmReference [

	(sessionHistory includes: anOmReference) ifFalse:
		[ self error: 'Unknown OmReference: ', anOmReference gtDisplayString ].
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

	^ encodedEvents collect: [ :each |
		(LanguageLinkUtils base64Decode: each readStream) ].
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> latestOmReference [

	^ latestOmReference
]

{ #category : #accessing }
GtRrImageSyncEncodedEvents >> latestOmReference: anObject [

	latestOmReference := anObject
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
