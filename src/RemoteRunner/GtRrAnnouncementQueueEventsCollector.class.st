Class {
	#name : #GtRrAnnouncementQueueEventsCollector,
	#superclass : #Object,
	#instVars : [
		'queueUpdateEvents',
		'eventsStack'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #adding }
GtRrAnnouncementQueueEventsCollector >> addQueueUpdateEvent: anEvent [
	self queueUpdateEvents add: anEvent 
]

{ #category : #initialization }
GtRrAnnouncementQueueEventsCollector >> initialize [
	super initialize.
	
	queueUpdateEvents := GtRrAnnouncementQueueEventsGroup new.
]

{ #category : #actions }
GtRrAnnouncementQueueEventsCollector >> processQueueSignalFor: aSignal [
	| latestEvent |
	
	aSignal class isStartSignalType ifTrue: [ 
		| newEvent topEvent |
		newEvent := aSignal class eventType new.
		topEvent := eventsStack size > 0 
			ifTrue: [ eventsStack top ]
			ifFalse: [ nil ] .
		topEvent ifNotNil: [ 
			topEvent addSubEvent: newEvent ].
		newEvent addSignal: aSignal.
		eventsStack push: newEvent.
		^ self ].
		
	aSignal class isEndSignalType ifTrue: [ 
		eventsStack top addSignal: aSignal.
		latestEvent := eventsStack pop.
		self addQueueUpdateEvent: latestEvent ] 
]

{ #category : #actions }
GtRrAnnouncementQueueEventsCollector >> processQueueSignalsFor: aCollectionfSignals [
	aCollectionfSignals do: [ :aSignal |
		self processQueueSignalFor: aSignal]
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> queueUpdateEvents [
	^ queueUpdateEvents
]
