Class {
	#name : #GtRrAnnouncementQueueSignal,
	#superclass : #BeaconSignal,
	#category : #'RemoteRunner-Logging-Signals'
}

{ #category : #testing }
GtRrAnnouncementQueueSignal class >> isEndSignalType [
	^ false
]

{ #category : #testing }
GtRrAnnouncementQueueSignal class >> isStartSignalType [
	^ false
]
