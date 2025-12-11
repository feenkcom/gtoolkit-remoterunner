Class {
	#name : #GtRrWorkerRetrieveChangesSignal,
	#superclass : #GtRrWorkerChangesSignal,
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerRetrieveChangesSignal class >> eventType [
	^GtRrWorkerRetrieveChangesLogEvent
]

{ #category : #accessing }
GtRrWorkerRetrieveChangesSignal >> signalTypeLabel [

	^ 'Worker Retrieve Changes Signal'
]
