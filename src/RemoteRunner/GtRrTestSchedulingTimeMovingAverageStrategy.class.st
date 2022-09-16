Class {
	#name : #GtRrTestSchedulingTimeMovingAverageStrategy,
	#superclass : #GtRrTestSchedulingTimeStrategy,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #method }
GtRrTestSchedulingTimeMovingAverageStrategy >> timeFor: aGtRrTestSchedulingTestTimes [
	| times |

	times := aGtRrTestSchedulingTestTimes times.
	^ (times last: (times size max: 5)) average
]
