"
A GtRrUnknownDurationValue instance answers the time to be allocated to a example / test when there is no recorded value.

The default value is to use the target scheduling task duration so new examples / tests are run by themselves until their duration is known

Subclasses can implement different strategies.
"
Class {
	#name : #GtRrUnknownDurationValue,
	#superclass : #Object,
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrUnknownDurationValue >> value [

	^ GtRrTestScheduler defaultTaskDuration 
]
