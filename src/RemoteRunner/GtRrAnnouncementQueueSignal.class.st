Class {
	#name : #GtRrAnnouncementQueueSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'queueId'
	],
	#category : #'RemoteRunner-Logging-Signals'
}

{ #category : #accessing }
GtRrAnnouncementQueueSignal class >> forLocalListener: aQueueListener [
	"Set the identify hash of the listener as the id of the queue. Could be improved later on if we need to change the listener of a queue."
	^ self new 
		queueId: aQueueListener identityHash
]

{ #category : #testing }
GtRrAnnouncementQueueSignal >> isEndSignalType [
	^ false
]

{ #category : #testing }
GtRrAnnouncementQueueSignal >> isStartSignalType [
	^ false
]

{ #category : #accessing }
GtRrAnnouncementQueueSignal >> queueId [

	^ queueId
]

{ #category : #accessing }
GtRrAnnouncementQueueSignal >> queueId: anId [

	queueId := anId
]
