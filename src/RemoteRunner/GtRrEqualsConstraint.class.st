Class {
	#name : #GtRrEqualsConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'attribute',
		'value'
	],
	#category : #'RemoteRunner-Constraints'
}

{ #category : #'instance creation' }
GtRrEqualsConstraint class >> attribute: aSymbol value: anObject [

	^ self new
		  attribute: aSymbol;
		  value: anObject;
		  yourself
]

{ #category : #accessing }
GtRrEqualsConstraint class >> leJsonV4Name [

	^ #gtRrEqualsConstraint
]

{ #category : #accessing }
GtRrEqualsConstraint >> attribute [

	^ attribute
]

{ #category : #accessing }
GtRrEqualsConstraint >> attribute: anObject [

	attribute := anObject
]

{ #category : #testing }
GtRrEqualsConstraint >> matches: aDictionary [

	^ aDictionary
		  at: attribute
		  ifPresent: [ :e | e = value ]
		  ifAbsent: [ false ]
]

{ #category : #accessing }
GtRrEqualsConstraint >> value [

	^ value
]

{ #category : #accessing }
GtRrEqualsConstraint >> value: anObject [

	value := anObject
]
