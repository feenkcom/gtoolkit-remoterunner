Class {
	#name : #GtRrCheckSchedulingCheckTime,
	#superclass : #Object,
	#instVars : [
		'endTime'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

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

	^ self subclassResponsibility 
]
