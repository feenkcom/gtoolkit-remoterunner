Class {
	#name : #GtRrImageSyncEventsBuilder,
	#superclass : #Object,
	#instVars : [
		'sessionHistory',
		'events'
	],
	#category : #'RemoteRunner-Runner-ImageSync'
}

{ #category : #'event construction' }
GtRrImageSyncEventsBuilder >> addEntry: anOmEntry [

	events add: anOmEntry
]

{ #category : #'event construction' }
GtRrImageSyncEventsBuilder >> addImageEvents [
	"Add the events"

	events addAll: (GtRrChangesSync uniqueInstance changesFrom: sessionHistory first).
]

{ #category : #'as yet unclassified' }
GtRrImageSyncEventsBuilder >> encodedEvents [
	| sequencedEvents |

	sequencedEvents := GtEpForExportEventSequencer sequence: events.
	^ GtRrImageSyncEncodedEvents new
		encodedEvents: (STON toString: sequencedEvents);
		sessionHistory: sessionHistory.
]

{ #category : #accessing }
GtRrImageSyncEventsBuilder >> epLog [

	^ EpMonitor current log
]

{ #category : #initialization }
GtRrImageSyncEventsBuilder >> initialize [

	super initialize.
	events := OrderedCollection new.
	sessionHistory := GtRrChangesSync uniqueInstance sessionHistory.
]
