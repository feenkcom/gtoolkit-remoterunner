Class {
	#name : #GtRrCodeSync,
	#superclass : #Object,
	#instVars : [
		'events',
		'subscription',
		'flusher',
		'remoteRunner',
		'errors'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrCodeSync >> errors [

	^ errors
]

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
	(remoteRunner applyCodeChanges: buffer) ifNotEmpty: [ :e | 
		errors add: buffer -> e ]
]

{ #category : #initialization }
GtRrCodeSync >> initialize [

	super initialize.
	events := WaitfreeQueue new.
	errors := OrderedCollection new.
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
GtRrCodeSync >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrCodeSync >> remoteRunner: aRemoteRunner [

	remoteRunner := aRemoteRunner
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
