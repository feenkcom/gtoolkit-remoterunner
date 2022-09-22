Class {
	#name : #GtRrCheckSchedulingSuccessfulCheckTime,
	#superclass : #GtRrCheckSchedulingCheckTime,
	#instVars : [
		'duration'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #lejsonv4 }
GtRrCheckSchedulingSuccessfulCheckTime class >> leJsonV4Name [

	^ #gtRrCheckSchedulingSuccessfulCheckTime
]

{ #category : #accessing }
GtRrCheckSchedulingSuccessfulCheckTime >> duration [

	^ duration
]

{ #category : #accessing }
GtRrCheckSchedulingSuccessfulCheckTime >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingSuccessfulCheckTime >> expectedTime [

	^ duration
]

{ #category : #printing }
GtRrCheckSchedulingSuccessfulCheckTime >> gtDisplayOn: aStream [

	aStream print: duration
]
