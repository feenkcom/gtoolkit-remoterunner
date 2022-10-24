Class {
	#name : #GtRrOrConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'left',
		'right'
	],
	#category : #'RemoteRunner-Constraints'
}

{ #category : #'instance creation' }
GtRrOrConstraint class >> left: aConstraint right: anotherConstraint [

	^ self new
		  left: aConstraint;
		  right: anotherConstraint;
		  yourself
]

{ #category : #accessing }
GtRrOrConstraint class >> leJsonV4Name [

	^ #gtRrOrConstraint
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
GtRrOrConstraint >> matches: aDictionary [

	^ (left matches: aDictionary) or: [ right matches: aDictionary ]
]

{ #category : #accessing }
GtRrOrConstraint >> right [

	^ right
]

{ #category : #accessing }
GtRrOrConstraint >> right: anObject [

	right := anObject
]
