Class {
	#name : #GtRrAnnouncementQueueCycleEventsGrouper,
	#superclass : #GtBeaconEventsGrouper,
	#instVars : [
		'rootEventsStack'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #initialization }
GtRrAnnouncementQueueCycleEventsGrouper >> createDefaultEventsGroup [
	^ GtRrAnnouncementQueueEventsGroup new
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueCycleEventsGrouper >> gtViewRootEventsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self rootEvents ];
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
	
	rootEventsStack := OrderedCollection new.
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> numberOfAnnouncements [
	^ self queueUpdateEvents 
		sumNumbers: [ :anEvent | anEvent numberOfAnnouncements ] 
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> numberOfUpdateEvents [
	^ self numberOfRootEvents
]

{ #category : #'accessing - overview' }
GtRrAnnouncementQueueCycleEventsGrouper >> overviewData [
	^ {
		'Number of Updates' -> self numberOfRootEvents.
		'Number of Announcements' -> self numberOfAnnouncements.
		'Total Duration' -> self totalDuration.
		'Announcements Pool Duration' -> self totalPollDuration.
		'Announcements Delivery Duration' -> self totalDeliveryDuration
	} 
]

{ #category : #actions }
GtRrAnnouncementQueueCycleEventsGrouper >> processEvent: anEvent [
	
	anEvent class = GtRrAnnouncementQueueDeliveryEvent ifTrue: [
		self addRootEvent: (GtRrAnnouncementQueueUpdateCycleEvent new
			addSubEvents: rootEventsStack;
			addSubEvent: anEvent).
		rootEventsStack removeAll.
		^ self ].
	
	rootEventsStack add: anEvent
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> queueUpdateEvents [
	^ self rootEvents
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalDeliveryDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent deliveryDuration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalPollDuration [
	^ self queueUpdateEvents
		inject: 0 seconds 
		into: [ :total  :anEvent | total + anEvent pollDuration ]
]
