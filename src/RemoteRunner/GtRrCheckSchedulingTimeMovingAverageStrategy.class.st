Class {
	#name : #GtRrCheckSchedulingTimeMovingAverageStrategy,
	#superclass : #GtRrCheckSchedulingTimeStrategy,
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #accessing }
GtRrCheckSchedulingTimeMovingAverageStrategy class >> leJsonV4Name [ 

	^ #gtRrTestSchedulingTimeMovingAverageStrategy
]

{ #category : #method }
GtRrCheckSchedulingTimeMovingAverageStrategy >> timeFor: aGtRrTestSchedulingTestTimes [
	| times |

	times := aGtRrTestSchedulingTestTimes times.
	(times isNil or: [ times isEmpty ]) ifTrue: [ ^ Duration zero ].
	^ ((times last: (times size min: 5))
		collect: #expectedTime) average
]
