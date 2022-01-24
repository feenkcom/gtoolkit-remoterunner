Class {
	#name : #GtRrCodeSync,
	#superclass : #Object,
	#instVars : [
		'events',
		'subscription',
		'flusher',
		'scheduler'
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
	scheduler jobSchedule: (GtRrCodeSyncJob serializedChanges:
			 (LanguageLinkUtils base64Encode: buffer))
]

{ #category : #initialization }
GtRrCodeSync >> initialize [

	super initialize.
	events := WaitfreeQueue new.
	flusher := TKTWorker new
		           name: 'GtRrCodeSync flusher';
		           yourself
]

{ #category : #accessing }
GtRrCodeSync >> onEntryAdded: anEntryAddedEvent [

	anEntryAddedEvent entry content isCodeChange ifFalse: [ "only capture code changes" 
		^ self ].
	events nextPut: anEntryAddedEvent entry content.
	flusher schedule: [ self flush ]
]

{ #category : #accessing }
GtRrCodeSync >> scheduler [

	^ scheduler
]

{ #category : #accessing }
GtRrCodeSync >> scheduler: aRemoteRunner [

	scheduler := aRemoteRunner
]

{ #category : #accessing }
GtRrCodeSync >> start [

	subscription ifNil: [ 
		subscription := EpMonitor current log announcer
			                when: EpEntryAdded
			                send: #onEntryAdded:
			                to: self ].
	flusher start
]

{ #category : #accessing }
GtRrCodeSync >> stop [

	flusher stop.
	subscription ifNotNil: [ 
		subscription announcer removeSubscription: subscription.
		subscription := nil ]
]
