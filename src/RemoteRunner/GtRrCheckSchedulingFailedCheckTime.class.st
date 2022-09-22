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

{ #category : #printing }
GtRrCheckSchedulingFailedCheckTime >> gtDisplayOn: aStream [

	aStream << (errorDetails 
		ifNil: [ 'error during execution' ]
		ifNotNil: [ errorDetails errorMessage ]).
	aStream
		<< ' in ';
		print: duration
]

{ #category : #accessing }
GtRrCheckSchedulingFailedCheckTime >> gtTraceFor: aView [
	<gtView>

	errorDetails ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Trace';
		priority: 20;
		object: [ errorDetails ];
		view: #gtTraceFor:
]
