Class {
	#name : #GtRrCheckSchedulingCheckTime,
	#superclass : #Object,
	#instVars : [
		'endTime',
		'duration'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #accessing }
GtRrCheckSchedulingCheckTime >> duration [

	^ duration
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTime >> duration: anObject [

	self assert: [ anObject isNotNil ]
		description: [ 'duration must be non-nil' ].

	duration := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTime >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTime >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTime >> expectedTime [

	^ duration
]

{ #category : #printing }
GtRrCheckSchedulingCheckTime >> gtDisplayOn: aStream [

	aStream print: duration
]
