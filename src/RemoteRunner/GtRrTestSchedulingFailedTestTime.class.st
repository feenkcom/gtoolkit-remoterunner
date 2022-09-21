Class {
	#name : #GtRrTestSchedulingFailedTestTime,
	#superclass : #GtRrTestSchedulingTestTime,
	#instVars : [
		'errorDetails'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingFailedTestTime >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrTestSchedulingFailedTestTime >> errorDetails: anObject [

	errorDetails := anObject
]

{ #category : #accessing }
GtRrTestSchedulingFailedTestTime >> expectedTime [

	^ GtRrCheckScheduler defaultTaskDuration
]

{ #category : #printing }
GtRrTestSchedulingFailedTestTime >> gtDisplayOn: aStream [

	aStream << (errorDetails 
		ifNil: [ 'error during execution' ]
		ifNotNil: [ errorDetails errorMessage ])
]
