Class {
	#name : #GtRrAnnouncementQueueEventsCollector,
	#superclass : #GtBeaconEventsCollector,
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #initialization }
GtRrAnnouncementQueueEventsCollector >> createDefaultEventsGrouper [
	^ GtRrAnnouncementQueueCycleCompositeEventsGrouper new
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

{ #category : #initialization }
GtRrAnnouncementQueueEventsCollector >> relevantSignalType [
	^ GtRrAnnouncementQueueSignal
]
