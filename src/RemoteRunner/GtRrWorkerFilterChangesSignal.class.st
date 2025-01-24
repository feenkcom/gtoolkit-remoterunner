Class {
	#name : #GtRrWorkerFilterChangesSignal,
	#superclass : #GtRrWorkerChangesSignal,
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerFilterChangesSignal class >> eventType [
	^GtRrWorkerFilterChangesLogEvent
]

{ #category : #accessing }
GtRrWorkerFilterChangesSignal >> signalTypeLabel [

	^ 'Worker Filter Changes Signal'
]
