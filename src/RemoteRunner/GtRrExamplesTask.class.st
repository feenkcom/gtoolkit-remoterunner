Class {
	#name : #GtRrExamplesTask,
	#superclass : #GtRrAbstractExamplesTask,
	#instVars : [
		'ignoreNoTest'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #visiting }
GtRrExamplesTask >> acceptVisitor: aVisitor [

	^ aVisitor visitExampleTask: self
]

{ #category : #accessing }
GtRrExamplesTask >> allExamples [
	^ self group examples
]

{ #category : #accessing }
GtRrExamplesTask >> allMethods [
	^ self group examples collect: #method
]

{ #category : #converting }
GtRrExamplesTask >> asExplicitTask [
	"Answer the receiver as a list of explicit examples / tasks"

	^ GtRrExplicitExampleTask examples: 
		(self group examples collect: [ :each |
			each methodClass name -> each selector ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> erroredExamples [

	result ifNil: [ ^ #() ].
	^ result erroredExamples
]

{ #category : #accessing }
GtRrExamplesTask >> examples [
	^ self group examples
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> executedExamples [

	result ifNil: [ ^ #() ].
	^ result executedExamples
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> failedExamples [

	result ifNil: [ ^ #() ].
	^ result failedExamples
]

{ #category : #'private - running' }
GtRrExamplesTask >> group [

	^ self subclassResponsibility 
]

{ #category : #'private - accessing' }
GtRrExamplesTask >> ignoreNoTest [

	^ ignoreNoTest
]

{ #category : #'private - accessing' }
GtRrExamplesTask >> ignoreNoTest: anObject [

	ignoreNoTest := anObject
]

{ #category : #initialization }
GtRrExamplesTask >> initialize [

	super initialize.
	ignoreNoTest := false.
]

{ #category : #testing }
GtRrExamplesTask >> isExamplesTask [
	"Answer a boolean indicating whether the receiver is for running Gt examples"

	^ true
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> numberOfErrors [

	result ifNil: [ ^ 0 ].
	^ result numberOfErrors
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> numberOfFailures [

	result ifNil: [ ^ 0 ].
	^ result numberOfFailures
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> numberOfSkipps [

	result ifNil: [ ^ 0 ].
	^ result numberOfSkipps
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> numberOfSuccesses [

	result ifNil: [ ^ 0 ].
	^ result numberOfSuccesses
]

{ #category : #running }
GtRrExamplesTask >> run [
	| group exampleStartTime exampleEndTime announcement |

	group := self group.
	^ group examples collect: [ :exampleWithResult |
		exampleStartTime := DateAndTime now.
		exampleWithResult run.
		exampleEndTime := DateAndTime now.
		announcement := exampleWithResult result basicReturnValue gtRrResultHolderClass new.
		announcement
			initializeTestCaseClassName: exampleWithResult methodClass name
				selector: exampleWithResult selector;
			testCaseStartTimestamp: exampleStartTime;
			testCaseEndTimestamp: exampleEndTime;
			shouldPass: true.
		exampleWithResult isSuccess ifFalse:
			[ announcement halt ].
		announcement ].
]

{ #category : #initialization }
GtRrExamplesTask >> setIgnoreNoTest [

	ignoreNoTest := true.
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> skippedExamples [

	result ifNil: [ ^ #() ].
	^ result skippedExamples
]

{ #category : #accessing }
GtRrExamplesTask >> splitTests [
	"Answer a collection of tasks in which each task has only 1 test from the receiver.
	If the receiver only has 1 test, answer the receiver."
	| group |

	group := self group.
	group size = 1 ifTrue: [ ^ { self copy } ].
	^ group collect: [ :example |
		(GtRrExplicitExampleTask examples: 
			{ example methodClass name -> example selector })
				constraint: self constraint;
				taskTimeout: self taskTimeout ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesTask >> successfulExamples [

	result ifNil: [ ^ #() ].
	^ result successfulExamples
]

{ #category : #ui }
GtRrExamplesTask >> summaryAttributes [ 

	^ super summaryAttributes
		add: 'Ignore noTest' -> ignoreNoTest;
		yourself.
]

{ #category : #accessing }
GtRrExamplesTask >> totalCount [
	"Answer the total number of examples the receiver contains"

	^ self group examples size.
]
