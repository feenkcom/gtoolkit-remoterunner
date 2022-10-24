"
GtTestSchedulingTimeStrategy specifies how to calculate the expected test execution time for the supplied {{gtClass:GtRrCheckSchedulingCheckTimes}}.

Strategies include:

- Use the last time
- Use a moving average
"
Class {
	#name : #GtRrCheckSchedulingTimeStrategy,
	#superclass : #Object,
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #method }
GtRrCheckSchedulingTimeStrategy >> timeFor: aGtTestSchedulingTestTimes [

	^ self subclassResponsibility 
]
