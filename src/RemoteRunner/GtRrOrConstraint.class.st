Class {
	#name : #GtRrOrConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'left',
		'right'
	],
	#category : #'RemoteRunner-Constraints'
}

{ #category : #jsonV3 }
GtRrOrConstraint class >> leJsonV4AttributeMapping [

	^ OrderedCollection new
		  add: #left -> #left;
		  add: #right -> #right;
		  yourself
]

{ #category : #accessing }
GtRrOrConstraint class >> leJsonV4Name [

	^ #gtRrOrConstraint
]

{ #category : #'instance creation' }
GtRrOrConstraint class >> left: aConstraint right: anotherConstraint [

	^ self new
		  initializeLeft: aConstraint right: anotherConstraint;
		  yourself
]

{ #category : #initialization }
GtRrOrConstraint >> initializeLeft: aConstraint right: anotherConstraint [

	left := aConstraint.
	right := anotherConstraint
]

{ #category : #accessing }
GtRrOrConstraint >> left [

	^ left
]

{ #category : #accessing }
GtRrOrConstraint >> left: anObject [

	left := anObject
]

{ #category : #testing }
GtRrOrConstraint >> matches: aConnection [

	^ (left matches: aConnection) or: [ right matches: aConnection ]
]

{ #category : #accessing }
GtRrOrConstraint >> right [

	^ right
]

{ #category : #accessing }
GtRrOrConstraint >> right: anObject [

	right := anObject
]
