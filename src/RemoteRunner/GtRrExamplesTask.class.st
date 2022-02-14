Class {
	#name : #GtRrExamplesTask,
	#superclass : #GtRrTask,
	#instVars : [
		'ignoreNoTest'
	],
	#category : #'RemoteRunner-Tests'
}

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

{ #category : #ui }
GtRrExamplesTask >> summaryAttributes [ 

	^ super summaryAttributes
		add: 'Ignore noTest' -> ignoreNoTest;
		yourself.
]
