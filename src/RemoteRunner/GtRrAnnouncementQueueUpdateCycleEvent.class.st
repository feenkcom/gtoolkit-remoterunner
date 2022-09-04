Class {
	#name : #GtRrAnnouncementQueueUpdateCycleEvent,
	#superclass : #Object,
	#instVars : [
		'subEvents'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent class >> eventLabel [
	^ 'Queue Update Cycle'
]

{ #category : #adding }
GtRrAnnouncementQueueUpdateCycleEvent >> addSubEvent: anEvent [
	self subEvents add: anEvent
]

{ #category : #adding }
GtRrAnnouncementQueueUpdateCycleEvent >> addSubEvents: aCollection [
	aCollection do: [ :each |
		self addSubEvent: each ]
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> allSignals [
	^ self subEvents allSignals
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> completedEvent [
	^ self subEvents last
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> duration [
	^ self completedEvent timestamp - self startedEvent timestamp
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueUpdateCycleEvent >> gtViewAllSignalsFor: aView [
	<gtView>
	
	^ aView forward
	 	title: 'Signals';
	 	priority: 33;
	 	object: [ self allSignals ];
	 	view: #gtItemsFor:
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> gtViewSubEventsFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Events';
		priority: 10;
		object: [ self subEvents ];
		view: #gtItemsFor:
]

{ #category : #initialization }
GtRrAnnouncementQueueUpdateCycleEvent >> initialize [ 
	super initialize.
	
	subEvents := GtRrAnnouncementQueueEventsGroup new. 
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> numberOfAnnouncements [
	^ self completedEvent numberOfAnnouncements
]

{ #category : #printing }
GtRrAnnouncementQueueUpdateCycleEvent >> printOn: aStream [
	super printOn: aStream.
	aStream parenthesize: [
		aStream 
			print: self timestamp;
			<< ', ';
			print: self numberOfAnnouncements;
			<< ' announcements,';
			print: self duration]
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> startTimestamp [
	^ self startedEvent timestamp
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> startedEvent [
	^ self subEvents first
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> subEvents [
	^ subEvents
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> timestamp [
	^ self startTimestamp
]
