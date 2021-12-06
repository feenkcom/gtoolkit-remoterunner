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

{ #category : #accessing }
GtRrTaskErrorDetails >> trace [

	^ trace
]

{ #category : #accessing }
GtRrTaskErrorDetails >> trace: aString [

	trace := aString
]
