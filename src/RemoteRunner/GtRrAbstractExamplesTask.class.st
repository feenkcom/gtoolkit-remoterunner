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

{ #category : #converting }
GtRrAbstractExamplesTask >> asExplicitTask [
	"Answer the receiver as a list of explicit examples / tasks"

	^ self subclassResponsibility 
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

{ #category : #accessing }
GtRrAbstractExamplesTask >> erroredExamples [
	"Answer the examples / tests that finished with an error"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> executedExamples [
	"Answer the examples / tests that have been executed"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> failedExamples [
	"Answer the examples / tests that have an assertion failure"

	^ self subclassResponsibility
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

{ #category : #accessing }
GtRrAbstractExamplesTask >> setIgnoreNoTest [
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> skippedExamples [
	"Answer the examples / tests that were skipped"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> splitTests [
	"Answer a collection of tasks in which each task has only 1 test from the receiver.
	If the receiver only has 1 test, answer the receiver."

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> successfulExamples [
	"Answer the examples / tests that completed successfully"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrAbstractExamplesTask >> totalCount [
	"Answer the total number of examples / tests in the receiver"

	^ self subclassResponsibility
]
