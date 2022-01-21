Class {
	#name : #GtRrTrueConstraint,
	#superclass : #GtRrConstraint,
	#classInstVars : [
		'instance'
	],
	#category : #'RemoteRunner-Constraints'
}

{ #category : #accessing }
GtRrTrueConstraint class >> instance [

	^ instance ifNil: [ instance := self new ]
]

{ #category : #accessing }
GtRrTrueConstraint class >> leJsonV4Name [

	^ #gtRrTrueConstraint
]

{ #category : #testing }
GtRrTrueConstraint >> matches: aConnection [

	^ true
]
