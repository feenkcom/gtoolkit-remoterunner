Class {
	#name : #GtRrCheckSchedulingSuccessfulCheckTime,
	#superclass : #GtRrCheckSchedulingCheckTime,
	#instVars : [
		'duration'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

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
