Class {
	#name : #GtRrTestScheduler,
	#superclass : #Object,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestScheduler class >> defaultTaskDuration [
	"Answer the target task duration in which tests will be grouped"

	^ 10 seconds
]
