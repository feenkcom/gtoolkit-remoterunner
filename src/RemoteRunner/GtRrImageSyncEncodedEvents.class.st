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
