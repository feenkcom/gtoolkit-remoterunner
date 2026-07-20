Class {
	#name : #GtRrAnnouncementQueueCycleCompositeEventsGrouper,
	#superclass : #Object,
	#instVars : [
		'eventsGrouperByQueueId',
		'announcer',
		'shouldNotifyUpdates'
	],
	#category : 'RemoteRunner-Logging-Events'
}

{ #category : #callbacks }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> actOnAnnouncementFromGrouperFor: anAnnouncement [
	self shouldNotifyUpdates ifTrue: [
		announcer announce: anAnnouncement ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> announcer [
	^ announcer
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> eventsGrouperForSignal: aSignal [ 
	^ eventsGrouperByQueueId 
		at: aSignal queueId 
		ifAbsentPut: [ 
			| eventsGrouper|
			eventsGrouper := GtRrAnnouncementQueueCycleEventsGrouper new.
			eventsGrouper shouldNotifyUpdates: self shouldNotifyUpdates.
			eventsGrouper announcer 
				when: Announcement 
				send: #actOnAnnouncementFromGrouperFor: 
				to: self.
			eventsGrouper ]
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> gtOverviewFor: aView [
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
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> gtViewQueuesListFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Queues';
		priority: 10;
		items: [ eventsGrouperByQueueId associations ];
		updateWhen: Announcement in: [ self announcer ];
		column: 'Id' text: [ :assoc | assoc key ];
		column: 'Cycle Update Events' text: [ :assoc | 
			assoc value numberOfUpdateEvents ];
		column: 'Announcements Count' text: [ :assoc | 
			assoc value numberOfAnnouncements ];
		send: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> gtViewRootEventsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 15;
		items: [ self rootEvents ];
		children: #subEvents;
		column: 'Event Type' text: [ :anEvent | anEvent eventLabel ];
		column: 'Timestamp' text: #timestamp;
		column: 'Duration' 
			text: [ :anEvent | anEvent duration ];
		column: 'Announcements' 
			text: [ :anEvent | anEvent numberOfAnnouncements ]
]

{ #category : #initialization }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> initialize [ 
	super initialize.
	
	self reset.
	announcer := Announcer new.
	shouldNotifyUpdates := false.
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> notifyUpdates [
	shouldNotifyUpdates := true.
	eventsGrouperByQueueId valuesDo: [ :anEventsGrouper |
		anEventsGrouper notifyUpdates ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> numberOfAnnouncements [
	^ eventsGrouperByQueueId sumNumbers: [ :anEventsGrouper | 
		anEventsGrouper numberOfAnnouncements ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> numberOfUpdateEvents [
	^ eventsGrouperByQueueId sumNumbers: [ :anEventsGrouper | 
		anEventsGrouper numberOfUpdateEvents ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> overviewData [
	^ {
		'Number of Queues' -> eventsGrouperByQueueId size.
		'Number of Updates' -> self numberOfUpdateEvents.
		'Number of Announcements' -> self numberOfAnnouncements.
		'Total Duration' -> self totalDuration.
		'Announcements Pool Duration' -> self totalPollDuration.
		'Announcements Delivery Duration' -> self totalDeliveryDuration
	} 
]

{ #category : #actions }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> processEventSignalFor: aSignal [
	(self eventsGrouperForSignal: aSignal)
		processEventSignalFor: aSignal
]

{ #category : #actions }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> processEventSignalsFor: aCollectionfSignals [
	aCollectionfSignals do: [ :aSignal |
		self processEventSignalFor: aSignal ]
]

{ #category : #actions }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> reset [
	eventsGrouperByQueueId := OrderedDictionary new.
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> rootEvents [ 
	| updateEvents  | 
	updateEvents := GtRrAnnouncementQueueEventsGroup new.
	
	eventsGrouperByQueueId valuesDo: [ :anEventsGrouper |
		updateEvents addAll: anEventsGrouper rootEvents ].
	
	^ updateEvents
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> shouldNotifyUpdates [
	^ shouldNotifyUpdates
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> sumGrouperDurations: aBlock [
	^ eventsGrouperByQueueId  
		inject: 0 seconds 
		into: [ :total  :anEventsGrouper | 
			total + (aBlock value: anEventsGrouper) ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> totalDeliveryDuration [
	^ self sumGrouperDurations: [ :anEventsGrouper | 
		anEventsGrouper totalDeliveryDuration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> totalDuration [
	^ self sumGrouperDurations: [ :anEventsGrouper | 
		anEventsGrouper totalDuration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleCompositeEventsGrouper >> totalPollDuration [
	^ self sumGrouperDurations: [ :anEventsGrouper | 
		anEventsGrouper totalPollDuration ]
]
