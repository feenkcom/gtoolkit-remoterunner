Class {
	#name : #GtRrAnnouncementQueueEvent,
	#superclass : #Object,
	#instVars : [
		'signals',
		'subEvents'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrAnnouncementQueueEvent class >> eventLabel [
	^ 'Announcement Queue'
]

{ #category : #adding }
GtRrAnnouncementQueueEvent >> addSignal: aSignal [
	self signals add: aSignal
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> duration [
	^ self signalCompletedEvent timestamp - self signalStartedEvent timestamp
]

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueEvent >> gtViewLocalSignalsFor: aView [
	<gtView>
	
	^ aView forward
	 	title: 'Signals (local)';
	 	priority: 30;
	 	object: [ self signals ];
	 	view: #gtItemsFor:
]

{ #category : #initialization }
GtRrAnnouncementQueueEvent >> initialize [ 
	super initialize.
	signals := GtRrAnnouncementQueueSignalsGroup new. 
	subEvents := GtRrAnnouncementQueueEventsGroup new. 
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> numberOfAnnouncements [
	^ self signalCompletedEvent announcementsCount
]

{ #category : #printing }
GtRrAnnouncementQueueEvent >> printOn: aStream [
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
GtRrAnnouncementQueueEvent >> signalCompletedEvent [
	^ self signals last
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> signalStartedEvent [
	^ self signals first
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> signals [

	^ signals
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> startTimestamp [
	^ self signalStartedEvent timestamp
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> subEvents [
	^ subEvents
]

{ #category : #accessing }
GtRrAnnouncementQueueEvent >> timestamp [
	^ self startTimestamp
]
