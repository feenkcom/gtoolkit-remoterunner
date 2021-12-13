Class {
	#name : #GtRrTaskErrorDetails,
	#superclass : #Object,
	#instVars : [
		'errorMessage',
		'trace'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #accessing }
GtRrTaskErrorDetails class >> leJsonV4Name [

	^ #taskErrorDetails
]

{ #category : #accessing }
GtRrTaskErrorDetails >> errorMessage [

	^ errorMessage
]

{ #category : #accessing }
GtRrTaskErrorDetails >> errorMessage: anObject [

	errorMessage := anObject
]

{ #category : #initialization }
GtRrTaskErrorDetails >> setTrace [
	"Set the receiver's trace to the current stack trace"

	trace := (String streamContents: [ :stream |
		thisContext debugStackOn: stream ])
]

{ #category : #accessing }
GtRrTaskErrorDetails >> trace [

	^ trace
]

{ #category : #accessing }
GtRrTaskErrorDetails >> trace: aString [

	trace := aString
]
