Class {
	#name : #GtRrCheckSchedulingFailedCheckTime,
	#superclass : #GtRrCheckSchedulingCheckTime,
	#instVars : [
		'errorDetails'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #lejsonv4 }
GtRrCheckSchedulingFailedCheckTime class >> leJsonV4Name [

	^ #gtRrCheckSchedulingFailedCheckTime
]

{ #category : #accessing }
GtRrCheckSchedulingFailedCheckTime >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrCheckSchedulingFailedCheckTime >> errorDetails: anObject [

	errorDetails := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingFailedCheckTime >> expectedTime [

	^ GtRrCheckScheduler defaultTaskDuration
]

{ #category : #printing }
GtRrCheckSchedulingFailedCheckTime >> gtDisplayOn: aStream [

	aStream << (errorDetails 
		ifNil: [ 'error during execution' ]
		ifNotNil: [ errorDetails errorMessage ])
]
