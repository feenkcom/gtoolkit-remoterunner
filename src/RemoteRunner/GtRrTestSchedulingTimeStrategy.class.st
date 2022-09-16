"
GtTestSchedulingTimeStrategy specifies how to calculate the expected test execution time for the supplied {{gtClass:GtTestSchedulingTestTimes}}.

Strategies include:

- Use the last time
- Use a moving average
"
Class {
	#name : #GtRrTestSchedulingTimeStrategy,
	#superclass : #Object,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #method }
GtRrTestSchedulingTimeStrategy >> timeFor: aGtTestSchedulingTestTimes [

	^ self subclassResponsibility 
]
