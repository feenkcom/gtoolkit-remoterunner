Class {
	#name : #GtRrNotConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'constraint'
	],
	#category : 'RemoteRunner-Constraints'
}

{ #category : #accessing }
GtRrNotConstraint class >> constraint: aConstraint [

	^ self new
		  constraint: aConstraint;
		  yourself
]

{ #category : #accessing }
GtRrNotConstraint class >> leJsonV4Name [

	^ #gtRrNotConstraint
]

{ #category : #accessing }
GtRrNotConstraint >> constraint [

	^ constraint
]

{ #category : #accessing }
GtRrNotConstraint >> constraint: aConstraint [

	constraint := aConstraint
]

{ #category : #testing }
GtRrNotConstraint >> matches: aDictionary [

	^ (constraint matches: aDictionary) not
]
