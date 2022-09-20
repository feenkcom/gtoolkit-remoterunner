Class {
	#name : #GtRrTestSchedulingTimeMovingAverageStrategy,
	#superclass : #GtRrTestSchedulingTimeStrategy,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingTimeMovingAverageStrategy class >> leJsonV4Name [ 

	^ #gtRrTestSchedulingTimeMovingAverageStrategy
]

{ #category : #method }
GtRrTestSchedulingTimeMovingAverageStrategy >> timeFor: aGtRrTestSchedulingTestTimes [
	| times |

	times := aGtRrTestSchedulingTestTimes times.
	^ ((times last: (times size min: 5))
		collect: #expectedTime) average
]
