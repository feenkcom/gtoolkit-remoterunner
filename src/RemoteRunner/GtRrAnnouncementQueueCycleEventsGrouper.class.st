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

{ #category : #initialization }
GtRrAnnouncementQueueCycleEventsGrouper >> initialize [
	super initialize.
	
	self reset.
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> numberOfAnnouncements [
	^ self rootEvents 
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

{ #category : #actions }
GtRrAnnouncementQueueCycleEventsGrouper >> reset [ 
	super reset.
	
	rootEventsStack := OrderedCollection new.
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalDeliveryDuration [
	^ self rootEvents
		sumDurations: [ :anEvent | anEvent deliveryDuration ]
]

{ #category : #accessing }
GtRrAnnouncementQueueCycleEventsGrouper >> totalPollDuration [
	^ self rootEvents 
		sumDurations: [ :anEvent | anEvent pollDuration ]
]
