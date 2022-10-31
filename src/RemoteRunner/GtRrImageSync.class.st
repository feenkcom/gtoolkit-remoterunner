"
GtRrImageSync is responsible for listening to the Epicea Monitor (gtClass:EpMonitor) and storing a history of the sessions that a part of this image.

This allows a quick check to be made whether a requested event chain can be formed from a given starting point (since the starting point must be in the sessionHistory.  Otherwise log files would have to be parsed until either the requested {{gtClass:OmReference}} had been found, or all files have been parsed (and parsing is slow).

Note that saving an image and then quitting will produce duplicate entries in the session history.  This is required in case the saved image is used separately from the current image.
"
Class {
	#name : #GtRrImageSync,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'sessionHistory',
		'subscription',
		'workerOmReference',
		'encodedEvents',
		'latestOmReference'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #initialization }
GtRrImageSync class >> initialize [
	"Create the uniqueInstance to collect the session history"

	self uniqueInstance.
]

{ #category : #'private - hooks' }
GtRrImageSync class >> onRemoveUniqueInstance: anInstance [
	"Classes may perform some activities on a singleton that is about to be released"

	anInstance stop.
]

{ #category : #accessing }
GtRrImageSync class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new start ]
]

{ #category : #private }
GtRrImageSync >> addEntry: anOmEntry [
	"Update the session history based on the supplied entry.
	If it is a snapshot we need to ensure that the current localName is in the history."

	self addReference: (anOmEntry tagAt: #self).
	"If this is a snapshot add the entry a second time.
	Subsequent code modifications will update this entry in the history and keep the original unmodified in case the snapshot is used at a later date"
	anOmEntry content class = EpSessionSnapshot 
		ifTrue: [ sessionHistory add: (anOmEntry tagAt: #self) ].

]

{ #category : #private }
GtRrImageSync >> addReference: anOmReference [
	"Add the supplied reference.
	If it is in the same file as the most recent entry, just update the localName."

	self assert: anOmReference isNull not.
	sessionHistory ifEmpty: [ ^ sessionHistory add: anOmReference ].
	^ sessionHistory last globalName = anOmReference globalName ifTrue:
		[ sessionHistory at: sessionHistory size put: anOmReference ]
	ifFalse:
		[ sessionHistory add: anOmReference ].
]

{ #category : #'api - remoterunner' }
GtRrImageSync >> encodedChangesFrom: anOmReference [
	"Answer the encoded collection of EpEvents from anOmReference up to the image's current state.
	Cache the latest request on the assumption that all workers will start from the same image."
	| enumerator entries haveLatest |

	haveLatest := latestOmReference = EpMonitor current log headReference.
	(haveLatest and: [ workerOmReference = anOmReference ]) ifTrue: [ ^ encodedEvents ].
	(self includesReference: anOmReference) ifFalse:
		[ self error: 'Unknown OmReference: ', anOmReference gtDisplayString ].

	enumerator := GtEpLogEnumerator new latestLog: EpMonitor current log.
	workerOmReference := anOmReference.
	latestOmReference := EpMonitor current log headReference.
	entries := GtEpEventSequencer uniqueInstance
		sequence: (enumerator entriesFrom: workerOmReference to: latestOmReference)
		withCurrent: true.
	encodedEvents := entries collect: [ :entry |
		LanguageLinkUtils base64Encode: entry content ].
	^ encodedEvents
]

{ #category : #finalization }
GtRrImageSync >> finalize [

	self stop.
	super finalize
]

{ #category : #ui }
GtRrImageSync >> gtSessionHistoryFor: aView [
	<gtView>

	^ aView list
		title: 'Session History';
		priority: 10;
		items: [ sessionHistory reversed ];
		actionUpdateButton
]

{ #category : #testing }
GtRrImageSync >> includesReference: anOmReference [
	"Answer a boolean indicating whether anOmReference is part of the receiver's session history"

	^ sessionHistory includes: anOmReference
]

{ #category : #initialization }
GtRrImageSync >> initialize [

	super initialize.
	sessionHistory := OrderedCollection new.
	self addReference: EpMonitor current log headReference.
]

{ #category : #'hooks - session' }
GtRrImageSync >> onEntryAdded: anAnnouncement [

	self addEntry: anAnnouncement entry.
]

{ #category : #private }
GtRrImageSync >> sessionHistory [

	^ sessionHistory
]

{ #category : #private }
GtRrImageSync >> sessionHistory: anOrderedCollection [

	sessionHistory := anOrderedCollection 
]

{ #category : #'start - stop' }
GtRrImageSync >> start [

	subscription ifNil: 
		[ subscription := EpMonitor current log announcer
			when: EpEntryAdded
			send: #onEntryAdded:
			to: self ].
]

{ #category : #'start - stop' }
GtRrImageSync >> stop [

	subscription ifNotNil: [ 
		subscription announcer removeSubscription: subscription.
		subscription := nil ]
]
