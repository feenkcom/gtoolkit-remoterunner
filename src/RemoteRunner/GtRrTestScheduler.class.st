Class {
	#name : #GtRrTestScheduler,
	#superclass : #Object,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #'as yet unclassified' }
GtRrTestScheduler class >> defaultTaskDuration [
	"Answer the target task duration in which tests will be grouped"

	^ 10 seconds
]
