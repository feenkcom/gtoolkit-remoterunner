Class {
	#name : #GtRrTestSchedulingTestTime,
	#superclass : #Object,
	#instVars : [
		'endTime'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingTestTime >> expectedTime [ 

	^ self subclassResponsibility 
]
