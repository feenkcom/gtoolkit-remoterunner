Class {
	#name : #GtRrError,
	#superclass : #Object,
	#instVars : [
		'trace',
		'message'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrError class >> leJsonV4Name [

	^ #taskErrorDetails
]

{ #category : #ui }
GtRrError >> gtTraceFor: aView [
	<gtView>

	trace ifNil: [ ^ aView empty ].
	^ aView textEditor
		title: 'Trace';
		priority: 10;
		text: [ trace ]
]

{ #category : #accessing }
GtRrError >> message [

	^ message
]

{ #category : #accessing }
GtRrError >> message: anObject [

	message := anObject
]

{ #category : #printing }
GtRrError >> printOn: aStream [

	(message isNil or: [ message isEmpty ]) ifTrue:
		[ ^ super printOn: aStream ].
	aStream << message
]

{ #category : #initialization }
GtRrError >> setTrace [
	"Set the receiver's trace to the current stack trace"

	trace := (String streamContents: [ :stream |
		thisContext debugStackOn: stream ])
]

{ #category : #accessing }
GtRrError >> trace [

	^ trace
]

{ #category : #accessing }
GtRrError >> trace: aString [

	trace := aString
]
