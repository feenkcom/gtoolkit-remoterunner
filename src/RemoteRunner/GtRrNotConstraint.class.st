Class {
	#name : #GtRrNotConstraint,
	#superclass : #GtRrConstraint,
	#instVars : [
		'constraint'
	],
	#category : #'RemoteRunner-Constraints'
}

{ #category : #accessing }
GtRrNotConstraint class >> constraint: aConstraint [

	^ self new
		  initializeConstraint: aConstraint;
		  yourself
]

{ #category : #jsonV3 }
GtRrNotConstraint class >> leJsonV4AttributeMapping [

	^ OrderedCollection new
		  add: #constraint -> #constraint;
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

{ #category : #initialization }
GtRrNotConstraint >> initializeConstraint: aConstraint [

	constraint := aConstraint
]
