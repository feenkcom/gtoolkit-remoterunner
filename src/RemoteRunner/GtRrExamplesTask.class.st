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

{ #category : #running }
GtRrExamplesTask >> run [
	| group |

	group := self group.
	group examples do: [ :exampleWithResult |
		(ignoreNoTest or: [ exampleWithResult ignoreTest not ]) ifTrue:
			[ exampleWithResult run ] ].
	^ group
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
