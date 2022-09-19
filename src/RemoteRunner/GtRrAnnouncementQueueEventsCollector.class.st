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
	
	^ aView forward
		title: 'Overview';
		priority: 5;
		object:  [ eventsGrouper];
		view: #gtOverviewFor:
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
GtRrAnnouncementQueueEventsCollector >> gtViewQueuesListFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Queues';
		priority: 10;
		object: [ eventsGrouper ];
		view: #gtViewQueuesListFor:
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueEventsCollector >> gtViewUpdateCycleEventsFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Events';
		priority: 15;
		object: [ eventsGrouper ];
		view: #gtViewUpdateCycleEventsFor:
]

{ #category : #initialization }
GtRrAnnouncementQueueEventsCollector >> initialize [
	super initialize.
	
	eventsGrouper := GtRrAnnouncementQueueCycleCompositeEventsGrouper new
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
	^ eventsGrouper numberOfAnnouncements
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> numberOfUpdateEvents [
	^ eventsGrouper numberOfUpdateEvents
]

{ #category : #'accessing - overview' }
GtRrAnnouncementQueueEventsCollector >> overviewData [
	^ eventsGrouper overviewData
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
	^ eventsGrouper totalDeliveryDuration
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> totalDuration [
	^ eventsGrouper totalDuration
]

{ #category : #accessing }
GtRrAnnouncementQueueEventsCollector >> totalPollDuration [
	^ eventsGrouper totalPollDuration
]
