Class {
	#name : #GtRrExplicitExampleTask,
	#superclass : #GtRrExamplesTask,
	#instVars : [
		'checkNames'
	],
	#category : 'RemoteRunner-Tests'
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

	^ GtExplicitExampleGroup new examples: (checkNames 
		collect: [ :each | | providerClass method |
			providerClass := self class environment classOrTraitNamed: each key asSymbol.
			method := providerClass lookupSelector: each value asSymbol.
			method ifNil: [ KeyNotFound
				signalFor: each value asSymbol
				in: providerClass ].
			(GtExampleFactory new
				createExampleForMethod: method
				withProviderClass: providerClass) asExampleWithResult ]
		thenSelect: #isNotNil).
]

{ #category : #accessing }
GtRrExplicitExampleTask >> numberOfChecks [

	^ checkNames size
]

{ #category : #accessing }
GtRrExplicitExampleTask >> splitTestsIn: aGtRrTaskContext [
	"Answer a collection of tasks which need to be retried and in which each task has only 1 check from the receiver.
	If the receiver has errors (the task overall failed), retry all unsuccessful checks.
	Once a definition of flaky tests has been added: If the receiver succeeded, retry failing flaky checks."

	self hasErrors ifFalse: [ ^ #() ].
	checkNames size = 1 ifTrue: [ ^ { self copy } ].
	^ checkNames collect: [ :example |
		self copy examples: { example } ].
]
