Class {
	#name : #GtRrTestSchedulingSuccessfulTestTime,
	#superclass : #GtRrTestSchedulingTestTime,
	#instVars : [
		'duration'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingSuccessfulTestTime >> duration [

	^ duration
]

{ #category : #accessing }
GtRrTestSchedulingSuccessfulTestTime >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
GtRrTestSchedulingSuccessfulTestTime >> expectedTime [

	^ duration
]

{ #category : #printing }
GtRrTestSchedulingSuccessfulTestTime >> gtDisplayOn: aStream [

	aStream print: duration
]
