Class {
	#name : #GtRrAnnouncementQueueUpdateCycleEvent,
	#superclass : #GtBeaconLogCompositeEvent,
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent class >> eventLabel [
	^ 'Queue Update Cycle'
]

{ #category : #initialization }
GtRrAnnouncementQueueUpdateCycleEvent >> createDefaultEventsGroup [
	^ GtRrAnnouncementQueueEventsGroup new. 
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> deliveryDuration [
	^ self completedEvent duration
]

{ #category : #printing }
GtRrAnnouncementQueueUpdateCycleEvent >> descriptionOn: aStream [
	
	aStream 
		print: self timestamp;
		<< ', ';
		print: self numberOfAnnouncements;
		<< ' announcements,';
		print: self duration
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> eventLabel [
	^ self class eventLabel
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> numberOfAnnouncements [
	^ self completedEvent numberOfAnnouncements
]

{ #category : #accessing }
GtRrAnnouncementQueueUpdateCycleEvent >> pollDuration [
	^ self startedEvent duration
]
