Class {
	#name : #GtRrTestSchedulingTestTime,
	#superclass : #Object,
	#instVars : [
		'endTime'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingTestTime >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrTestSchedulingTestTime >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrTestSchedulingTestTime >> expectedTime [ 

	^ self subclassResponsibility 
]
