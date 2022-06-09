Class {
	#name : #GtRrExplicitSUnitTask,
	#superclass : #GtRrSUnitTask,
	#instVars : [
		'sunitTestNames'
	],
	#category : #'RemoteRunner-Tests'
}

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
GtRrExplicitSUnitTask >> sunitTestNames [

	^ sunitTestNames
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> sunitTestNames: anObject [

	sunitTestNames := anObject
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> testSuite [
	| suite |

	suite := TestSuite named: taskId.
	sunitTestNames do: [ :assoc | | class |
		class := self class environment at: assoc key asSymbol.
		suite addTest: (class new setTestSelector: assoc value asSymbol) ].
	^ suite.
]

{ #category : #accessing }
GtRrExplicitSUnitTask >> totalCount [

	^ sunitTestNames size
]
