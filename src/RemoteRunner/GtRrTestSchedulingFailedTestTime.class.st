Class {
	#name : #GtRrTestSchedulingFailedTestTime,
	#superclass : #GtRrTestSchedulingTestTime,
	#instVars : [
		'errorDetails'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingFailedTestTime >> expectedTime [

	^ GtRrTestScheduler defaultTaskDuration
]
