"
GtRrCodeSync is responsible for listening to the Epicea Monitor ({{gtClass:EpMonitor}}) and submitting code sync tasks to each of the synced workers when any code change is made.
"
Class {
	#name : #GtRrCodeSync,
	#superclass : #Object,
	#instVars : [
		'events',
		'subscription',
		'flusher',
		'remoteRunner'
	],
	#category : #'RemoteRunner-Runner-CodeSync'
}

{ #category : #finalization }
GtRrCodeSync >> finalize [

	self stop.
	super finalize
]

{ #category : #accessing }
GtRrCodeSync >> flush [
	| buffer |

	buffer := OrderedCollection new.
	events flush: [ :event | buffer add: event ].
	buffer ifEmpty: [ "nothing to send, ignore" ^ self ].
	remoteRunner submitJob: (GtRrCodeSyncJob serializedChanges:
			 (LanguageLinkUtils base64Encode: buffer))
]

{ #category : #initialization }
GtRrCodeSync >> initialize [

	super initialize.
	events := WaitfreeQueue new.
	flusher := TKTNewProcessTaskRunner new
]

{ #category : #testing }
GtRrCodeSync >> isEmpty [

	^ events isEmpty
]

{ #category : #accessing }
GtRrCodeSync >> onEntryAdded: anEntryAddedEvent [

	anEntryAddedEvent entry content isCodeChange ifFalse: 
		[ "only capture code changes" 
		^ self ].
	events nextPut: anEntryAddedEvent entry content.
	flusher schedule: [ self flush ]
]

{ #category : #accessing }
GtRrCodeSync >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrCodeSync >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #accessing }
GtRrCodeSync >> start [

	subscription ifNil: [ 
		subscription := EpMonitor current log announcer
			                when: EpEntryAdded
			                send: #onEntryAdded:
			                to: self ].
]

{ #category : #accessing }
GtRrCodeSync >> stop [

	subscription ifNotNil: [ 
		subscription announcer removeSubscription: subscription.
		subscription := nil ]
]
