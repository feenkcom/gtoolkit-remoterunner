Class {
	#name : #GtRrAnnouncementQueueDynamicEventsCollector,
	#superclass : #GtRrAnnouncementQueueEventsCollector,
	#instVars : [
		'logger'
	],
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #callbacks }
GtRrAnnouncementQueueDynamicEventsCollector >> actOnQueueSignalFor: aSignal [
	self processQueueSignalFor: aSignal
]

{ #category : #initialization }
GtRrAnnouncementQueueDynamicEventsCollector >> initialize [
	super initialize.
	
	logger := MemoryLogger new
		initializeInterestingSubscriptionsWith: GtRrAnnouncementQueueAnnouncement.
	logger announcer
		when: GtRrAnnouncementQueueAnnouncement 
		send: #actOnQueueSignalFor: 
		to: self
]

{ #category : #actions }
GtRrAnnouncementQueueDynamicEventsCollector >> start [
	logger start
]

{ #category : #accessing }
GtRrAnnouncementQueueDynamicEventsCollector >> stop [
	logger stop
]
