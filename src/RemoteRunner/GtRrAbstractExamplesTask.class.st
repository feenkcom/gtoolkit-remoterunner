Class {
	#name : #GtRrAbstractExamplesTask,
	#superclass : #GtRrTask,
	#category : #'RemoteRunner-Tests'
}

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

{ #category : #accessing }
GtRrAbstractExamplesTask >> skippedExamples [
	"Answer the examples / tests that were skipped"

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
