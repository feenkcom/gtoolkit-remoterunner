Class {
	#name : #GtRrExplicitSUnitTask,
	#superclass : #GtRrSUnitTask,
	#instVars : [
		'checkNames'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #'instance creation' }
GtRrExplicitSUnitTask class >> checkNames: aCollection [
	"aCollection is a collection of examples to run, in the form:
		ClassNameSymbol -> SelectorSymbol"

	^ self new checkNames: aCollection
]

{ #category : #accessing }
GtRrExplicitSUnitTask class >> leJsonV4Name [

	^ #gtRrExplicitSUnitTask
]

{ #category : #'instance creation' }
GtRrExplicitSUnitTask class >> sunitTestNames: aCollection [

	^ self new sunitTestNames: aCollection
]

{ #category : #visiting }
GtRrExplicitSUnitTask >> acceptVisitor: aVisitor [

	^ aVisitor visitExplicitSUnitTask: self
]

{ #category : #converting }
GtRrExplicitSUnitTask >> asExplicitTask [
	"Answer the receiver as a list of explicit examples / tasks"

	^ self
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> checkNames [

	^ checkNames
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> checkNames: anObject [

	checkNames := anObject
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> splitTests [
	"Answer a collection of tasks in which each task has only 1 test from the receiver.
	If the receiver only has 1 test, answer the receiver."

	checkNames size = 1 ifTrue: [ ^ { self copy } ].
	^ checkNames collect: [ :testName |
		self copy sunitTestNames: { testName } ].
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> sunitTestNames [

	^ checkNames
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> sunitTestNames: aCollection [

	checkNames := aCollection asArray
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> testSuite [
	| suite |

	suite := TestSuite named: taskId.
	checkNames do: [ :assoc | | class |
		class := self class environment at: assoc key asSymbol.
		suite addTest: (class new setTestSelector: assoc value asSymbol) ].
	^ suite.
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> totalCount [

	^ checkNames size
]
