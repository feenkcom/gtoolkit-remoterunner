Class {
	#name : #GtRrAnnouncementQueueEventsCollector,
	#superclass : #Object,
	#instVars : [
		'logger',
		'eventsGrouper'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #callbacks }
GtRrAnnouncementQueueEventsCollector >> actOnQueueSignalFor: aSignal [
	eventsGrouper processQueueSignalFor: aSignal
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueEventsCollector >> gtOverviewFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Overview';
		priority: 5;
		items: [ self overviewData ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueEventsCollector >> gtViewBeaconSignalsFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Beacon Signals';
		priority: 25;
		object: [ logger ];
		view: #gtRecordingsFor:
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueEventsCollector >> gtViewUpdateCycleEventsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self queueUpdateEvents ];
		updateWhen: Announcement in: [ eventsGrouper announcer];
		children: #subEvents;
		column: 'Event Type' text: [ :anEvent | anEvent class eventLabel ];
		column: 'Timestamp' text: #timestamp;
		column: 'Duration' 
			text: [ :anEvent | anEvent duration ];
		column: 'Announcements' 
			text: [ :anEvent | anEvent numberOfAnnouncements ]
]

{ #category : #initialization }
GtRrAnnouncementQueueEventsCollector >> initialize [
	super initialize.
	
	eventsGrouper := GtRrAnnouncementQueueCycleEventsGrouper new
		notifyUpdates.
	
	logger := MemoryLogger new
		initializeInterestingSubscriptionsWith: GtRrAnnouncementQueueSignal.
	logger announcer
		when: GtRrAnnouncementQueueSignal 
		send: #actOnQueueSignalFor: 
		to: self
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> numberOfAnnouncements [
	^ self queueUpdateEvents 
		sumNumbers: [ :anEvent | anEvent numberOfAnnouncements]
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> numberOfUpdateEvents [
	^ self queueUpdateEvents size
]

{ #category : #'accessing - overview' }
GtRrAnnouncementQueueEventsCollector >> overviewData [
	^ {
		'Number of Updates' -> self numberOfUpdateEvents.
		'Number of Announcements' -> self numberOfAnnouncements.
		'Total Duration' -> self totalDuration.
		'Announcements Pool Duration' -> self totalPollDuration.
		'Announcements Delivery Duration' -> self totalDeliveryDuration
	} 
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> queueUpdateEvents [
	^ eventsGrouper queueUpdateEvents
]

{ #category : #actions }
GtRrAnnouncementQueueEventsCollector >> start [
	logger start
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> stop [
	logger stop
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> totalDeliveryDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent deliveryDuration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> totalDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent duration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> totalPollDuration [
^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent pollDuration ]
]
