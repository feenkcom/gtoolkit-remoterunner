"
GtRrTestContext provides enough functionality to support the examples in {{gtClass:GtRrTimeoutManagerExamples}}. 
"
Class {
	#name : #GtRrTestContext,
	#superclass : #GtRrContext,
	#instVars : [
		'isFinished',
		'contextTimeoutTime'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrTestContext class >> finished: aBoolean timeoutTime: aDateAndTime [

	^ self new
		isFinished: aBoolean;
		contextTimeoutTime: aDateAndTime.
]

{ #category : #accessing }
GtRrTestContext >> contextTimeoutTime [
	^ contextTimeoutTime
]

{ #category : #accessing }
GtRrTestContext >> contextTimeoutTime: anObject [
	contextTimeoutTime := anObject
]

{ #category : #accessing }
GtRrTestContext >> isFinished [
	^ isFinished
]

{ #category : #accessing }
GtRrTestContext >> isFinished: anObject [
	isFinished := anObject
]

{ #category : #printing }
GtRrTestContext >> printOn: aStream [

	super printOn: aStream.
	aStream parenthesize:
		[ aStream
			print: isFinished;
			<< ', ';
			print: contextTimeoutTime ].
]
