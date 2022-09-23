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

{ #category : #accessing }
GtRrExamplesTask >> checkNamesAndTimes [
	| times exampleClassName |

	times := OrderedCollection new.
	self allExamples do: [ :example |
		exampleClassName := example methodClass name.
		times add: {
			(example methodClass name asString, '>>', example selector).
			(GtRrCheckSchedulingTimes hasUniqueInstance ifTrue:
					[ GtRrCheckSchedulingTimes uniqueInstance
						timeForClassName: exampleClassName
						selector: example selector
						ifAbsent: [ '<none>' ]]
				ifFalse:
					[ '<no times>' ]).
			example } ].
	^ times sorted: #first descending.

]

{ #category : #accessing }
GtRrExamplesTask >> examples [
	^ self group examples
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

{ #category : #running }
GtRrExamplesTask >> run [
	| group exampleStartTime exampleEndTime announcement exception exampleResult |

	group := self group.
	^ group examples collect: [ :exampleWithResult |
		(ignoreNoTest or: [ exampleWithResult ignoreTest not ]) ifTrue:
			[ exampleStartTime := DateAndTime now.
			exampleWithResult run.
			exampleEndTime := DateAndTime now ].
		exampleResult := exampleWithResult result.
		announcement := exampleResult
			ifNil: [ PharoLinkTestCaseSkip new ]
			ifNotNil: [ exampleResult basicReturnValue gtRrResultHolderClass new ].
		announcement
			initializeTestCaseClassName: exampleWithResult methodClass name
				selector: exampleWithResult selector;
			testCaseStartTimestamp: exampleStartTime;
			testCaseEndTimestamp: exampleEndTime;
			shouldPass: true.
		(exampleWithResult isSuccess or: [ exampleResult isNil ]) ifFalse:
			[ exception := exampleResult basicReturnValue value.
			announcement 
				initializeExceptionClass: exception class
				messageText: (exception messageText ifEmpty: [ exception class name ])
				trace: exception stackString ].
		announcement ].
]

{ #category : #initialization }
GtRrExamplesTask >> setIgnoreNoTest [

	ignoreNoTest := true.
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
