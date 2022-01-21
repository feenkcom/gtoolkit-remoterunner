Class {
	#name : #GtRrAndConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'left',
		'right'
	],
	#category : #'RemoteRunner-Constraints'
}

{ #category : #accessing }
GtRrAndConstraint class >> leJsonV4Name [

	^ #gtRrAndConstraint
]

{ #category : #'instance creation' }
GtRrAndConstraint class >> left: aConstraint right: anotherConstraint [

	^ self new
		  initializeLeft: aConstraint right: anotherConstraint;
		  yourself
]

{ #category : #initialization }
GtRrAndConstraint >> initializeLeft: aConstraint right: anotherConstraint [

	left := aConstraint.
	right := anotherConstraint
]

{ #category : #accessing }
GtRrAndConstraint >> left [

	^ left
]

{ #category : #accessing }
GtRrAndConstraint >> left: anObject [

	left := anObject
]

{ #category : #testing }
GtRrAndConstraint >> matches: aConnection [

	^ (left matches: aConnection) and: [ right matches: aConnection ]
]

{ #category : #accessing }
GtRrAndConstraint >> right [

	^ right
]

{ #category : #accessing }
GtRrAndConstraint >> right: anObject [

	right := anObject
]
