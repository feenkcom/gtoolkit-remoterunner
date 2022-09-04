Class {
	#name : #GtRrAnnouncementQueueCycleEventsGrouper,
	#superclass : #Object,
	#instVars : [
		'queueUpdateEvents',
		'eventsStack',
		'shouldNotifyUpdates',
		'rootEvents',
		'announcer'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #adding }
GtRrAnnouncementQueueCycleEventsGrouper >> addQueueUpdateEvent: anEvent [
	self queueUpdateEvents add: anEvent.
	self shouldNotifyUpdates ifTrue: [
		self notifyUpdateEventAdded]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> announcer [
	^ announcer
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueCycleEventsGrouper >> gtViewUpdateCycleEventsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self queueUpdateEvents ];
		children: #subEvents;
		column: 'Event Type' text: [ :anEvent | anEvent class eventLabel ];
		column: 'Timestamp' text: #timestamp;
		column: 'Duration' 
			text: [ :anEvent | anEvent duration ];
		column: 'Announcements' 
			text: [ :anEvent | anEvent numberOfAnnouncements ]
]

{ #category : #initialization }
GtRrAnnouncementQueueCycleEventsGrouper >> initialize [
	super initialize.
	
	queueUpdateEvents := GtRrAnnouncementQueueEventsGroup new.
	eventsStack := Stack new.
	rootEvents := OrderedCollection new.
	shouldNotifyUpdates := false.
	announcer := Announcer new.
]

{ #category : #notifications }
GtRrAnnouncementQueueCycleEventsGrouper >> notifyUpdateEventAdded [
	announcer announce: Announcement
]

{ #category : #initialization }
GtRrAnnouncementQueueCycleEventsGrouper >> notifyUpdates [
	shouldNotifyUpdates := true
]

{ #category : #adding }
GtRrAnnouncementQueueCycleEventsGrouper >> processQueueEvent: anEvent [
	anEvent class = GtRrAnnouncementQueueDeliveryEvent ifTrue: [
		self addQueueUpdateEvent: (GtRrAnnouncementQueueUpdateCycleEvent new
			addSubEvents: rootEvents ;
			addSubEvent: anEvent).
		rootEvents removeAll.
		^ self ].
	
	rootEvents add: anEvent
]

{ #category : #actions }
GtRrAnnouncementQueueCycleEventsGrouper >> processQueueSignalFor: aSignal [
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
		self processQueueEvent: latestEvent ] 
]

{ #category : #actions }
GtRrAnnouncementQueueCycleEventsGrouper >> processQueueSignalsFor: aCollectionfSignals [
	aCollectionfSignals do: [ :aSignal |
		self processQueueSignalFor: aSignal ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> queueUpdateEvents [
	^ queueUpdateEvents
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> shouldNotifyUpdates [
	^ shouldNotifyUpdates
]
