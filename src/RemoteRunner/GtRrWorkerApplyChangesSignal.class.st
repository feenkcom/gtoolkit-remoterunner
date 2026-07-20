Class {
	#name : #GtRrWorkerApplyChangesSignal,
	#superclass : #GtRrWorkerChangesSignal,
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerApplyChangesSignal class >> eventType [
	^GtRrWorkerApplyChangesLogEvent
]

{ #category : #accessing }
GtRrWorkerApplyChangesSignal >> signalTypeLabel [

	^ 'Worker Apply Changes Signal'
]
