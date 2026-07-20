Class {
	#name : #GtRrExplicitSUnitTask,
	#superclass : #GtRrSUnitTask,
	#instVars : [
		'checkNames'
	],
	#category : 'RemoteRunner-Tests'
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
GtRrExplicitSUnitTask >> splitTestsIn: aGtRrTaskContext [
	"Answer a collection of tasks which need to be retried and in which each task has only 1 check from the receiver.
	If the receiver has errors (the task overall failed), retry all unsuccessful checks.
	Once a definition of flaky tests has been added: If the receiver succeeded, retry failing flaky checks."

	self hasErrors ifFalse: [ ^ #() ].
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

	suite := GtRrTestSuite named: taskId.
	checkNames do: [ :assoc | | class |
		class := self class environment at: assoc key asSymbol.
		suite addTest: (class new setTestSelector: assoc value asSymbol) ].
	^ suite.
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> totalCount [

	^ checkNames size
]
