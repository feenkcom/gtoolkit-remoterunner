Class {
	#name : #GtRrConstraint,
	#superclass : #Object,
	#category : #'RemoteRunner-Constraints'
}

{ #category : #'logical operations' }
GtRrConstraint >> & aConstraint [

	^ GtRrAndConstraint left: self right: aConstraint
]

{ #category : #testing }
GtRrConstraint >> matches: aDictionary [

	self subclassResponsibility
]

{ #category : #'logical operations' }
GtRrConstraint >> not [

	^ GtRrNotConstraint constraint: self
]

{ #category : #'logical operations' }
GtRrConstraint >> | aConstraint [

	^ GtRrOrConstraint left: self right: aConstraint
]
