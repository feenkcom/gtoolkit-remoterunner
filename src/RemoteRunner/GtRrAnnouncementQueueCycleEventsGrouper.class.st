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
GtRrAnnouncementQueueCycleEventsGrouper >> gtOverviewFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Overview';
		priority: 5;
		items: [ self overviewData ];
		updateWhen: Announcement in: [ self announcer ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueCycleEventsGrouper >> gtViewUpdateCycleEventsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self queueUpdateEvents ];
		updateWhen: Announcement in: [ self announcer ];
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

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> numberOfAnnouncements [
	^ self queueUpdateEvents 
		sumNumbers: [ :anEvent | anEvent numberOfAnnouncements ] 
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> numberOfUpdateEvents [
	^ self queueUpdateEvents size
]

{ #category : #'accessing - overview' }
GtRrAnnouncementQueueCycleEventsGrouper >> overviewData [
	^ {
		'Number of Updates' -> self numberOfUpdateEvents.
		'Number of Announcements' -> self numberOfAnnouncements.
		'Total Duration' -> self totalDuration.
		'Announcements Pool Duration' -> self totalPollDuration.
		'Announcements Delivery Duration' -> self totalDeliveryDuration
	} 
]

{ #category : #actions }
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

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> shouldNotifyUpdates: aBoolean [

	shouldNotifyUpdates := aBoolean
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalDeliveryDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent deliveryDuration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent duration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalPollDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent pollDuration ]
]
