Class {
	#name : #GtRrAnnouncementQueuePullSignal,
	#superclass : #GtRrAnnouncementQueueSignal,
	#category : #'RemoteRunner-Logging-Signals'
}

{ #category : #accessing }
GtRrAnnouncementQueuePullSignal class >> eventType [
	^ GtRrAnnouncementQueuePullEvent
]
