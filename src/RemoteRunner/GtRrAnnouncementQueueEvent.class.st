Class {
	#name : #GtRrAnnouncementQueueEvent,
	#superclass : #GtBeaconLogEvent,
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrAnnouncementQueueEvent class >> eventLabel [
	^ 'Announcement Queue'
]

{ #category : #testing }
GtRrAnnouncementQueueEvent class >> needComposition [
	^ false
]

{ #category : #initialization }
GtRrAnnouncementQueueEvent >> createDefaultEventsGroup [
	^ GtRrAnnouncementQueueEventsGroup new
]

{ #category : #printing }
GtRrAnnouncementQueueEvent >> descriptionOn: aStream [
	
	aStream 
		print: self timestamp;
		<< ', ';
		print: self numberOfAnnouncements;
		<< ' announcements,';
		print: self duration
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> numberOfAnnouncements [
	^ self signalCompletedEvent announcementsCount
]
