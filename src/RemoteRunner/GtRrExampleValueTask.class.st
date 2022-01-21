"
GtRrExampleValueTask is a simple task provided for testing and demonstrations that either answers the value given, or raises an error with the value as the message.
"
Class {
	#name : #GtRrExampleValueTask,
	#superclass : #GtRrTask,
	#instVars : [
		'value',
		'errorFlag'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrExampleValueTask class >> leJsonV4Name [

	^ #gtRrExampleValueTask
]

{ #category : #accessing }
GtRrExampleValueTask >> errorFlag [

	^ errorFlag
]

{ #category : #accessing }
GtRrExampleValueTask >> errorFlag: anObject [

	errorFlag := anObject
]

{ #category : #initialization }
GtRrExampleValueTask >> initialize [

	super initialize.
	errorFlag := false.
]

{ #category : #printing }
GtRrExampleValueTask >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	errorFlag ifTrue: [ aStream << 'error: ' ].
	aStream print: value.
	aStream nextPut: $).
]

{ #category : #initialization }
GtRrExampleValueTask >> setError [
	"Set the flag indicating that the receiver should raise an error when run"

	errorFlag := true.
]

{ #category : #accessing }
GtRrExampleValueTask >> value [

	errorFlag ifTrue: [ self error: value ].
	^ value
]

{ #category : #accessing }
GtRrExampleValueTask >> value: anObject [

	value := anObject
]
