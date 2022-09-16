Class {
	#name : #GtRrTestSchedulingTimeLatestStrategy,
	#superclass : #GtRrTestSchedulingTimeStrategy,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #method }
GtRrTestSchedulingTimeLatestStrategy >> timeFor: aGtRrTestSchedulingTestTimes [

	^ aGtRrTestSchedulingTestTimes times last
]
