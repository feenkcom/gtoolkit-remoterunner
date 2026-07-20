Class {
	#name : #GtRrTrueConstraint,
	#superclass : #GtRrConstraint,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#classInstVars : [
		'instance'
	],
	#category : 'RemoteRunner-Constraints'
}

{ #category : #accessing }
GtRrTrueConstraint class >> leJsonV4Name [

	^ #gtRrTrueConstraint
]

{ #category : #testing }
GtRrTrueConstraint >> matches: aDictionary [

	^ true
]
