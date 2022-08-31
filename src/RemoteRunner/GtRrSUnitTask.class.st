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
			[ events last isPassAnnouncement ifTrue:
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
self halt.
	^ GtRrExplicitExampleTask examples: 
		(self testSuite collect: [ :each |
			each class name -> each selector ])
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> erroredExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 
			pharoLinkTestCaseAnnouncement shortName = #error or:
			[ pharoLinkTestCaseAnnouncement shortName = #warning ] ]

]

{ #category : #accessing }
GtRrSUnitTask >> examples [

	^ self allExamples
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> executedExamples [

	result ifNil: [ ^ #() ].
	^ result
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> failedExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 	pharoLinkTestCaseAnnouncement shortName = #failure ]

]

{ #category : #testing }
GtRrSUnitTask >> isSUnitTask [
	"Answer a boolean indicating whether the receiver is for running SUnit tests"

	^ true
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> isSuccessResult: aPharoLinkTestCaseResult [
	^ #(#pass #skip) includes: aPharoLinkTestCaseResult shortName
]

{ #category : #running }
GtRrSUnitTask >> run [

	^ self runSuite: self testSuite
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

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> skippedExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 	pharoLinkTestCaseAnnouncement shortName = #skip ]

]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> successfulExamples [

	result ifNil: [ ^ #() ].
	
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 
			self isSuccessResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> successfulExamplesCount [

	result ifNil: [ ^ 0 ].
	
	^ result
		count: [ :pharoLinkTestCaseAnnouncement | 
			self isSuccessResult: pharoLinkTestCaseAnnouncement ]
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
