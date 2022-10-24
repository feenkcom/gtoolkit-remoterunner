Class {
	#name : #GtRrExplicitExampleTask,
	#superclass : #GtRrExamplesTask,
	#instVars : [
		'checkNames'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #'instance creation' }
GtRrExplicitExampleTask class >> checkNames: aCollection [
	"aCollection is a collection of examples to run, in the form:
		ClassNameSymbol -> SelectorSymbol"

	^ self new checkNames: aCollection
]

{ #category : #'instance creation' }
GtRrExplicitExampleTask class >> exampleNames: aCollectionOfGtExample [
	"aCollection is a collection of examples to run, in the form:
		ClassNameSymbol -> SelectorSymbol"

	^ self new examples: aCollectionOfGtExample 
]

{ #category : #'instance creation' }
GtRrExplicitExampleTask class >> examples: aCollectionOfGtExample [
	"aCollection is a collection of examples to run, in the form:
		ClassNameSymbol -> SelectorSymbol"

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
GtRrExplicitExampleTask >> checkNames [

	^ checkNames
]

{ #category : #accessing }
GtRrExplicitExampleTask >> checkNames: anObject [

	checkNames := anObject
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples [

	^ checkNames
]

{ #category : #accessing }
GtRrExplicitExampleTask >> examples: aCollection [
	"aCollection is a collection of examples to run, in the form:
		ClassNameSymbol -> SelectorSymbol"

	checkNames := aCollection asArray
]

{ #category : #'private - running' }
GtRrExplicitExampleTask >> group [

	^ GtExplicitExampleGroup new examples: (checkNames collect: [ :each | 
		((self classWithName: each key) >> each value asSymbol) gtExample asExampleWithResult ]).
]

{ #category : #accessing }
GtRrExplicitExampleTask >> splitTests [
	"Answer a collection of tasks in which each task has only 1 test from the receiver.
	If the receiver only has 1 test, answer the receiver."

	checkNames size = 1 ifTrue: [ ^ { self copy } ].
	^ checkNames collect: [ :example |
		self copy examples: { example } ].
]
