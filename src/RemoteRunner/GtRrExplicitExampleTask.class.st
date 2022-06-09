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

{ #category : #converting }
GtRrExplicitExampleTask >> asExplicitTask [
	"Answer the receiver as a list of explicit examples / tasks"

	^ self
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples [

	^ examples
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples: aCollection [
	"aCollection is a collection of examples to run, in the form:
		ClassNameSymbol -> SelectorSymbol"

	examples := aCollection
]

{ #category : #'private - running' }
GtRrExplicitExampleTask >> group [

	^ GtExplicitExampleGroup new examples: (examples collect: [ :each | 
		(each key asSymbol asClass >> each value asSymbol) gtExample asExampleWithResult ]).
]
