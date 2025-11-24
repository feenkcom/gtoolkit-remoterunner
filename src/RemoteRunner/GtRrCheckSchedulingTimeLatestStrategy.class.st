Class {
	#name : #GtRrCheckSchedulingTimeLatestStrategy,
	#superclass : #GtRrCheckSchedulingTimeStrategy,
	#category : 'RemoteRunner-CheckScheduling'
}

{ #category : #accessing }
GtRrCheckSchedulingTimeLatestStrategy class >> leJsonV4Name [

	^ #gtRrTestSchedulingTimeLatestStrategy
]

{ #category : #method }
GtRrCheckSchedulingTimeLatestStrategy >> timeFor: aGtRrTestSchedulingTestTimes [

	^ aGtRrTestSchedulingTestTimes times last expectedTime
]
