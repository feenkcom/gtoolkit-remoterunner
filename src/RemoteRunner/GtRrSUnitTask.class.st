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
self halt.
	^ GtRrExplicitExampleTask examples: 
		(self testSuite collect: [ :each |
			each class name -> each selector ])
]

{ #category : #enumerating }
GtRrSUnitTask >> count: aBlockClosure [

	result ifNil: [ ^ 0 ].
	^ result 
		count: aBlockClosure
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> erroredExamples [
	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		self isErrorResult: pharoLinkTestCaseAnnouncement ]
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

	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isFailure ]
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> isErrorResult: aPharoLinkTestCaseResult [
	^ aPharoLinkTestCaseResult isError or: [
		aPharoLinkTestCaseResult isWarning ]
]

{ #category : #testing }
GtRrSUnitTask >> isSUnitTask [
	"Answer a boolean indicating whether the receiver is for running SUnit tests"

	^ true
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> isSuccessResult: aPharoLinkTestCaseResult [
	^ aPharoLinkTestCaseResult isSuccess "or: [ 
		aPharoLinkTestCaseResult isSkipped ]"
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> numberOfErrors [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		self isErrorResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> numberOfFailures [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isFailure ]
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> numberOfSkipps [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isSkipped ]
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> numberOfSuccesses [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		self isSuccessResult: pharoLinkTestCaseAnnouncement ]
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

{ #category : #enumerating }
GtRrSUnitTask >> select: aBlockClosure [

	result ifNil: [ ^ #() ].
	^ result select: aBlockClosure
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> skippedExamples [

	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isSkipped ]
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> successfulExamples [

	^ self select: [ :pharoLinkTestCaseAnnouncement | 
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
