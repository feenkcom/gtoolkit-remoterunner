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
			each providerClass name -> each selector ])
]

{ #category : #'as yet unclassified' }
GtRrExamplesTask >> checkNames [

	^ self group examples collect: [ :each | 
		each providerClass name -> each selector ]
]

{ #category : #accessing }
GtRrExamplesTask >> checkNamesAndTimes [
	| times exampleClassName |

	times := OrderedCollection new.
	self allExamples do: [ :example |
		exampleClassName := example providerClass name.
		times add: {
			(example providerClass name asString, '>>', example selector).
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
	| group exampleStartTime exampleEndTime announcement resourceReport exception exampleResult |

	group := self group.
	^ group examples collect: [ :exampleWithResult |
		resourceReport := nil.
		(ignoreNoTest or: [ exampleWithResult ignoreTest not ]) ifTrue: [ 
			GtRrWorkerCheckStartingSignal new
				example: exampleWithResult example;
				emit.
			resourceReport := GtRrCheckResourcesReport new.
			exampleStartTime := DateAndTime now.
			resourceReport recordSourceReport.
			self allowDebugger
				ifTrue: [ exampleWithResult debug ]
				ifFalse: [ exampleWithResult run ].
			resourceReport recordTargetReport.
			exampleEndTime := DateAndTime now ].
			GtRrWorkerCheckCompletedSignal new
				example: exampleWithResult example;
				emit.

		exampleResult := exampleWithResult result.
		announcement := exampleResult
			ifNil: [ PharoLinkTestCaseSkip new ]
			ifNotNil: [ exampleResult basicReturnValue gtRrResultHolderClass new ].
		announcement
			initializeTestCaseClassName: exampleWithResult providerClass name
				selector: exampleWithResult selector;
			testCaseStartTimestamp: exampleStartTime;
			testCaseEndTimestamp: exampleEndTime;
			shouldPass: true.
		announcement resourceReport: resourceReport.
		
		(exampleWithResult isSuccess or: [ exampleResult isNil ]) ifFalse: [ 
			exception := exampleResult basicReturnValue value.
			announcement 
				initializeExceptionClass: exception class
				messageText: (exception messageText ifEmpty: [ exception class name ])
				trace: exception stackString
				additionalData: exception pharoLinkAdditionalData ].
		announcement ] as: Array.
]

{ #category : #initialization }
GtRrExamplesTask >> setIgnoreNoTest [

	ignoreNoTest := true.
]

{ #category : #accessing }
GtRrExamplesTask >> splitTestsIn: aGtRrTaskContext [
	"Answer a collection of tasks which need to be retried and in which each task has only 1 check from the receiver.
	If the receiver has errors (the task overall failed), retry all unsuccessful checks.
	Once a definition of flaky tests has been added: If the receiver succeeded, retry failing flaky checks."
	| group |

	self hasErrors ifFalse: [ ^ #() ].
	group := self group.
	group size = 1 ifTrue: [ ^ { self copy } ].
	^ group collect: [ :example |
		(GtRrExplicitExampleTask examples: 
			{ example providerClass name -> example selector })
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
