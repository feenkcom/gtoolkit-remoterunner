Class {
	#name : #GtRrAbstractExamplesTask,
	#superclass : #GtRrTask,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrAbstractExamplesTask class >> leJsonV4Name [

	^ nil
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> allExamples [
	"Answer all the examples that will be tested"

	^ self subclassResponsibility 
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> allMethods [
	"Answer all the methods that will be tested"

	^ self subclassResponsibility 
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> allowDebugger [

	^ GtRrCurrentWorkerExecutionContext value 
		ifNil: [ false ]
		ifNotNil: [ :context | context allowDebugger ]
]

{ #category : #converting }
GtRrAbstractExamplesTask >> asExplicitTask [
	"Answer the receiver as a list of explicit examples / tasks"

	^ self subclassResponsibility 
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> asJob [
	"Answer a GtRrChecksJob with the receiver as its single task"

	^ GtRrChecksJob tasks: { self }
]

{ #category : #private }
GtRrAbstractExamplesTask >> checkNames [

	^ self subclassResponsibility
]

{ #category : #tests }
GtRrAbstractExamplesTask >> checkNamesAndTimes [
	
	^ self subclassResponsibility
]

{ #category : #enumerating }
GtRrAbstractExamplesTask >> count: aBlockClosure [

	result ifNil: [ ^ 0 ].
	^ result 
		count: aBlockClosure
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> description [
	^ (String streamContents: [ :aStream |
		aStream 
			print: self totalCount;
			<< ' ';
			<< (self totalCount = 1 
				ifTrue: [ 'check' ] ifFalse: [ 'checks' ]);
			<< ' (';
			<< self stateDescription;
			<< ')  ' ])
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> erroredExamples [
	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		self isErrorResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> executedExamples [

	result ifNil: [ ^ #() ].
	^ result
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> failedExamples [

	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isFailure ]
]

{ #category : #ui }
GtRrAbstractExamplesTask >> gtChecksFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Checks';
		priority: 25;
		items: [ self checkNamesAndTimes ];
		column: 'Test' text: #first;
		column: 'Persistent Time' text: #second;
		send: #third.
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> isEmpty [

	^ self totalCount = 0
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> isErrorResult: aPharoLinkTestCaseResult [
	^ aPharoLinkTestCaseResult isError or: [
		aPharoLinkTestCaseResult isWarning ]
]

{ #category : #testing }
GtRrAbstractExamplesTask >> isExamplesTask [
	"Answer a boolean indicating whether the receiver is for running Gt examples"

	^ false
]

{ #category : #testing }
GtRrAbstractExamplesTask >> isSUnitTask [
	"Answer a boolean indicating whether the receiver is for running SUnit tests"

	^ false
]

{ #category : #testing }
GtRrAbstractExamplesTask >> isSuccessResult: aPharoLinkTestCaseResult [
	^ aPharoLinkTestCaseResult isSuccess "or: [ 
		aPharoLinkTestCaseResult isSkipped ]"
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> numberOfErrors [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		self isErrorResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> numberOfExecutedChecks [
	
	result ifNil: [ ^ 0 ].
	^ result size
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> numberOfFailures [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isFailure ]
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> numberOfSkips [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isSkipped ]
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> numberOfSuccesses [
	^ self count: [ :pharoLinkTestCaseAnnouncement | 
		self isSuccessResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> resultWithName: anAssociation [
	"Answer the test result with the specified name (Class Name -> selector)"

	^ result detect: [ :aTestResult | aTestResult checkName = anAssociation ]
]

{ #category : #enumerating }
GtRrAbstractExamplesTask >> select: aBlockClosure [

	result ifNil: [ ^ #() ].
	^ result select: aBlockClosure
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> setIgnoreNoTest [
]

{ #category : #'accessing - dynamic' }
GtRrAbstractExamplesTask >> skippedExamples [

	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		pharoLinkTestCaseAnnouncement isSkipped ]
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> splitTestsIn: aGtRrTaskContext [
	"Answer a collection of tasks which need to be retried and in which each task has only 1 check from the receiver.
	If the receiver has errors (the task overall failed), retry all unsuccessful checks.
	Once a definition of flaky tests has been added: If the receiver succeeded, retry failing flaky checks."

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> successfulExamples [
	"Answer the examples / tests that completed successfully"

	^ self select: [ :pharoLinkTestCaseAnnouncement | 
		self isSuccessResult: pharoLinkTestCaseAnnouncement ]
]

{ #category : #private }
GtRrAbstractExamplesTask >> taskNotExecutedResult [
	"Generate error results for each of the receiver's checks"

	^ self checkNames collect: [ :assoc |
		(PharoLinkTestCaseError
			className: assoc key asSymbol 
			selector: assoc value asSymbol
			startTimestamp: executionData startTime)
		  	initializeExceptionClass: GtRrUnableToCompleteTestError
		  	messageText: 'No Result'
		  	trace: ''
		  	additionalData:  executionData additionalData ]
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> totalCount [
	"Answer the total number of examples / tests in the receiver"

	^ self subclassResponsibility
]
