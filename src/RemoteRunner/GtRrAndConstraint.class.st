Class {
	#name : #GtRrAndConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'left',
		'right'
	],
	#category : 'RemoteRunner-Constraints'
}

{ #category : #'instance creation' }
GtRrAndConstraint class >> left: aConstraint right: anotherConstraint [

	^ self new
		  left: aConstraint;
		  right: anotherConstraint;
		  yourself
]

{ #category : #accessing }
GtRrAndConstraint class >> leJsonV4Name [

	^ #gtRrAndConstraint
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
GtRrAndConstraint >> matches: aDictionary [

	^ (left matches: aDictionary) and: [ right matches: aDictionary ]
]

{ #category : #accessing }
GtRrAndConstraint >> right [

	^ right
]

{ #category : #accessing }
GtRrAndConstraint >> right: anObject [

	right := anObject
]
