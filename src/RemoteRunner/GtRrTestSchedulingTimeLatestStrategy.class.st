Class {
	#name : #GtRrTestSchedulingTimeLatestStrategy,
	#superclass : #GtRrTestSchedulingTimeStrategy,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingTimeLatestStrategy class >> leJsonV4Name [

	^ #gtRrTestSchedulingTimeLatestStrategy
]

{ #category : #method }
GtRrTestSchedulingTimeLatestStrategy >> timeFor: aGtRrTestSchedulingTestTimes [

	^ aGtRrTestSchedulingTestTimes times last
]
