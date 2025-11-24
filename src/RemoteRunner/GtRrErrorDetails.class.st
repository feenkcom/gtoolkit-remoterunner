Class {
	#name : #GtRrErrorDetails,
	#superclass : #Object,
	#instVars : [
		'errorMessage',
		'trace'
	],
	#category : 'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrErrorDetails class >> fromException: anException [

	anException ifNil: [ ^ nil ].
	^ self new
		errorMessage: anException messageText;
		trace: anException stackString.
]

{ #category : #accessing }
GtRrErrorDetails class >> leJsonV4Name [

	^ #taskErrorDetails
]

{ #category : #accessing }
GtRrErrorDetails >> errorMessage [

	^ errorMessage ifNil: [ '' ]
]

{ #category : #accessing }
GtRrErrorDetails >> errorMessage: anObject [

	errorMessage := anObject
]

{ #category : #ui }
GtRrErrorDetails >> gtTraceFor: aView [
	<gtView>

	trace ifNil: [ ^ aView empty ].
	^ aView textEditor
		title: 'Trace';
		priority: 10;
		text: [ trace ]
]

{ #category : #printing }
GtRrErrorDetails >> printOn: aStream [

	(errorMessage isNil or: [ errorMessage isEmpty ]) ifTrue:
		[ ^ super printOn: aStream ].
	aStream << errorMessage
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
