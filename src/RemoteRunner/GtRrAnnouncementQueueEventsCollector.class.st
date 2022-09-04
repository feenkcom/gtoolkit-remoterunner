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
		initializeInterestingSubscriptionsWith: GtRrAnnouncementQueueAnnouncement.
	logger announcer
		when: GtRrAnnouncementQueueAnnouncement 
		send: #actOnQueueSignalFor: 
		to: self
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
