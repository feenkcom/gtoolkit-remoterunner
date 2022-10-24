Class {
	#name : #GtRrSUnitTask,
	#superclass : #GtRrAbstractExamplesTask,
	#category : #'RemoteRunner-Tests'
}

{ #category : #visiting }
GtRrSUnitTask >> acceptVisitor: aVisitor [

	^ aVisitor visitSUnitTask: self
]

{ #category : #accessing }
GtRrSUnitTask >> addEndAnnouncement: endAnnouncement to: events [ 
	"Add the supplied announcment to the collection of events, ensuring there is only one announcment for each test.
	An error announcement replaces an existing success announcement."

	events ifEmpty:
		[ events add: endAnnouncement ]
	ifNotEmpty:
		[ "endAnnouncement equality is only based on the identity of the test, not the result"
		events last = endAnnouncement ifTrue:
			[ events last isSuccess ifTrue:
				[ "Replace the pass announcement with the error announcement"
				events atLast: 1 put: endAnnouncement ] ]
			"ifFalse: discard the second error announcement and only report the first"
		ifFalse:
			[ events add: endAnnouncement ] ].
]

{ #category : #accessing }
GtRrSUnitTask >> allExamples [

	^ self testSuite tests.
]

{ #category : #accessing }
GtRrSUnitTask >> allMethods [
	^ self testSuite tests
		ifNil: [ {} ]
		ifNotNil: [ :tests | tests collect: #gtCompiledMethod ]
]

{ #category : #converting }
GtRrSUnitTask >> asExplicitTask [
	"Answer the receiver as a list of explicit examples / tasks"
	| testNames |

	testNames := OrderedCollection new.
	self testSuite testCasesDo: [ :each |
		testNames add: each class name -> each selector ].
	^ GtRrExplicitSUnitTask checkNames: testNames.
]

{ #category : #accessing }
GtRrSUnitTask >> checkNamesAndTimes [
	| times |

	times := OrderedCollection new.
	self testSuite testCasesDo: [ :testCase |
		times add: {
			(testCase class name asString, '>>', testCase selector).
			(GtRrCheckSchedulingTimes hasUniqueInstance ifTrue:
					[ GtRrCheckSchedulingTimes uniqueInstance
						timeForClassName: testCase class name
						selector: testCase selector
						ifAbsent: [ '<none>' ]]
				ifFalse:
					[ '<no times>' ]).
			testCase. } ].
	^ times sorted: #first descending.

]

{ #category : #accessing }
GtRrSUnitTask >> examples [

	^ self allExamples
]

{ #category : #testing }
GtRrSUnitTask >> isSUnitTask [
	"Answer a boolean indicating whether the receiver is for running SUnit tests"

	^ true
]

{ #category : #running }
GtRrSUnitTask >> run [
	| testResult |

	TestExecutionEnvironment new beActiveDuring:
		[ testResult :=  self runSuite: self testSuite ].
	^ testResult
]

{ #category : #running }
GtRrSUnitTask >> runSuite: suite [
	| events testResult |

	events := OrderedCollection new.
	testResult := PharoLinkTestResult new.
	testResult announcer
		when: PharoLinkTestCaseEndAnnouncement
		do: [ :e | self addEndAnnouncement: e to: events ].
	suite run: testResult.
	^ events asArray
]

{ #category : #accessing }
GtRrSUnitTask >> splitTests [
	"Answer a collection of tasks in which each task has only 1 test from the receiver.
	If the receiver only has 1 test, answer the receiver."
	| group |

	group := self allExamples.
	group size = 1 ifTrue: [ ^ { self copy } ].
	^ group collect: [ :testCase |
		(GtRrExplicitSUnitTask sunitTestNames: 
			{ testCase class name -> testCase selector })
				constraint: self constraint;
				taskTimeout: self taskTimeout ].
]

{ #category : #enumerating }
GtRrSUnitTask >> testCasesDo: aBlock [

	^ self testSuite testCasesDo: aBlock
]

{ #category : #accessing }
GtRrSUnitTask >> testSuite [
	"Answer the test suite defined by the receiver."

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrSUnitTask >> totalCount [

	^ self testSuite tests
		ifNil: [ 0 ]
		ifNotNil: [ :tests | tests size ]
]
