Class {
	#name : #GtRrErrorDetails,
	#superclass : #Object,
	#instVars : [
		'errorMessage',
		'trace'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrErrorDetails class >> leJsonV4Name [

	^ #taskErrorDetails
]

{ #category : #accessing }
GtRrErrorDetails >> errorMessage [

	^ errorMessage
]

{ #category : #accessing }
GtRrErrorDetails >> errorMessage: anObject [

	errorMessage := anObject
]

{ #category : #initialization }
GtRrErrorDetails >> setTrace [
	"Set the receiver's trace to the current stack trace"

	trace := (String streamContents: [ :stream |
		thisContext debugStackOn: stream ])
]

{ #category : #accessing }
GtRrErrorDetails >> trace [

	^ trace
]

{ #category : #accessing }
GtRrErrorDetails >> trace: aString [

	trace := aString
]
