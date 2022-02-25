Class {
	#name : #GtRrExplicitExampleTask,
	#superclass : #GtRrExamplesTask,
	#instVars : [
		'examples'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #'instance creation' }
GtRrExplicitExampleTask class >> examples: aCollectionOfGtExample [

	^ self new examples: aCollectionOfGtExample 
]

{ #category : #accessing }
GtRrExplicitExampleTask class >> leJsonV4Name [

	^ #gtRrExplicitExampleTask
]

{ #category : #visiting }
GtRrExplicitExampleTask >> acceptVisitor: aVisitor [

	^ aVisitor visitExplicitExampleTask: self
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples [

	^ examples
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples: anObject [

	examples := anObject
]

{ #category : #'private - running' }
GtRrExplicitExampleTask >> group [

	^ GtExplicitExampleGroup new examples: examples
]
