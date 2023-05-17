"
nil
"
Class {
	#name : #GtRrChangesSync,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'sessionHistory',
		'subscription',
		'workerOmReference',
		'encodedEvents',
		'latestOmReference',
		'mutex',
		'epLog'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #accessing }
GtRrChangesSync class >> applyChanges: encodedEvents [
	"Apply the supplied encodedEvents"
	| events |

	events  := STON fromString: encodedEvents.
	events do: [ :event | event content applyCodeChange ].
]

{ #category : #accessing }
GtRrChangesSync class >> headReference [
	"Answer the current headReference, using the latest recorded session if a memory store is being used"
	| omReference |

	omReference := EpMonitor current log headReference.
	"If this is the null reference and we've been started with epiceaMemoryStore use the latest recorded session"
	(omReference isNull and: [ Smalltalk argumentsInclude: '--epiceaMemoryStore' ]) ifTrue:
		[ omReference := self uniqueInstance sessionHistory last ].
	^ omReference.
]

{ #category : #initialization }
GtRrChangesSync class >> initialize [
	"Create the uniqueInstance to collect the session history"

	self uniqueInstance.
]

{ #category : #'private - hooks' }
GtRrChangesSync class >> onRemoveUniqueInstance: anInstance [
	"Classes may perform some activities on a singleton that is about to be released"

	anInstance stop.
]

{ #category : #accessing }
GtRrChangesSync class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new start ]
]

{ #category : #private }
GtRrChangesSync >> addEntry: anOmEntry [
	"Update the session history based on the supplied entry.
	If it is a snapshot we need to ensure that the current localName is in the history."

	self addReference: (anOmEntry tagAt: #self).
	"If this is a snapshot add the entry a second time.
	Subsequent code modifications will update this entry in the history and keep the original unmodified in case the snapshot is used at a later date"
	anOmEntry content class = EpSessionSnapshot 
		ifTrue: [ sessionHistory add: (anOmEntry tagAt: #self) ].

]

{ #category : #private }
GtRrChangesSync >> addReference: anOmReference [
	"Add the supplied reference.
	If it is in the same file as the most recent entry, just update the localName."

	self assert: anOmReference isNull not.
	sessionHistory ifEmpty: [ ^ sessionHistory add: anOmReference ].
	^ sessionHistory last globalName = anOmReference globalName ifTrue:
		[ sessionHistory at: sessionHistory size put: anOmReference ]
	ifFalse:
		[ sessionHistory add: anOmReference ].
]

{ #category : #accessing }
GtRrChangesSync >> allEncodedChanges [

	^ self encodedChangesFrom: sessionHistory first.
]

{ #category : #'api - remoterunner' }
GtRrChangesSync >> changesFrom: anOmReference [
	"Answer the encoded collection of EpEvents from anOmReference up to the image's current state."
	| enumerator |

	(self includesReference: anOmReference) ifFalse:
		[ self error: 'Unknown OmReference: ', anOmReference gtDisplayString ].

	enumerator := GtEpLogEnumerator new latestLog: self epLog.
	^ GtEpEventSequencer
		sequence: (enumerator entriesFrom: anOmReference to: self epLog headReference)
		withCurrent: true.
]

{ #category : #'api - remoterunner' }
GtRrChangesSync >> encodedChangesFrom: anOmReference [
	"Answer the encoded collection of EpEvents from anOmReference up to the image's current state.
	Cache the latest request on the assumption that all workers will start from the same image."
	| enumerator entries haveLatest headReference |

	haveLatest := latestOmReference = self epLog headReference.
	(haveLatest and: [ workerOmReference = anOmReference ]) ifTrue: [ ^ encodedEvents ].
	(self includesReference: anOmReference) ifFalse:
		[ (GtRrUnknownOmReference omReference: anOmReference source: self) signal ].

	^ mutex critical: 
		[ haveLatest := latestOmReference = self epLog headReference.
		(haveLatest and: [ workerOmReference = anOmReference ]) ifFalse:
			[ enumerator := GtEpLogEnumerator new latestLog: self epLog.
			headReference := self epLog headReference.
			entries := GtEpEventSequencer
				sequence: (enumerator entriesFrom: anOmReference to: headReference)
				withCurrent: true.
			workerOmReference := anOmReference.
			latestOmReference := headReference.
			encodedEvents := STON toString: entries ].
		encodedEvents ]
]

{ #category : #accessing }
GtRrChangesSync >> epLog [
	"Answer the EpLog to use for building the event list.
	This should normally be the default, but may be set for testing purposes."
	<Return: #EpLog>

	^ epLog ifNil: [ EpMonitor current log ].
]

{ #category : #accessing }
GtRrChangesSync >> epLog: anEpLog [
	"Set the receiver's EpLog.
	Note that the sessionHistory must be updated to match."

	epLog := anEpLog
]

{ #category : #finalization }
GtRrChangesSync >> finalize [

	self stop.
	super finalize
]

{ #category : #ui }
GtRrChangesSync >> gtSessionHistoryFor: aView [
	<gtView>

	^ aView list
		title: 'Session history';
		priority: 10;
		items: [ sessionHistory reversed ];
		actionUpdateButton
]

{ #category : #testing }
GtRrChangesSync >> includesReference: anOmReference [
	"Answer a boolean indicating whether anOmReference is part of the receiver's session history"

	^ sessionHistory includes: anOmReference
]

{ #category : #initialization }
GtRrChangesSync >> initialize [

	super initialize.
	sessionHistory := OrderedCollection new.
	mutex := Mutex new.
]

{ #category : #'hooks - session' }
GtRrChangesSync >> onEntryAdded: anAnnouncement [

	self addEntry: anAnnouncement entry.
]

{ #category : #accessing }
GtRrChangesSync >> reset [

	encodedEvents := nil.
]

{ #category : #private }
GtRrChangesSync >> sessionHistory [

	^ sessionHistory
]

{ #category : #private }
GtRrChangesSync >> sessionHistory: anOrderedCollection [

	sessionHistory := anOrderedCollection 
]

{ #category : #'start - stop' }
GtRrChangesSync >> start [

	subscription ifNil: 
		[ subscription := EpMonitor current log announcer
			when: EpEntryAdded
			send: #onEntryAdded:
			to: self ].
]

{ #category : #'start - stop' }
GtRrChangesSync >> stop [

	subscription ifNotNil: [ 
		subscription announcer removeSubscription: subscription.
		subscription := nil ]
]

{ #category : #'private - debugging' }
GtRrChangesSync >> workerChanges [
	"Convenience method to regenerate the encodedChanges unencoded."

	^ self changesFrom: workerOmReference.
]
