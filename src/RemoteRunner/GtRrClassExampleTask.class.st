Class {
	#name : #GtRrClassExampleTask,
	#superclass : #GtRrExamplesTask,
	#instVars : [
		'exampleClassName'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #'instance creation' }
GtRrClassExampleTask class >> exampleClassName: aSymbol [

	^ self new exampleClassName: aSymbol
]

{ #category : #accessing }
GtRrClassExampleTask class >> leJsonV4Name [

	^ #gtRrClassExampleTask
]

{ #category : #visiting }
GtRrClassExampleTask >> acceptVisitor: aVisitor [

	^ aVisitor visitClassExampleTask: self
]

{ #category : #accessing }
GtRrClassExampleTask >> exampleClassName [

	^ exampleClassName
]

{ #category : #accessing }
GtRrClassExampleTask >> exampleClassName: anObject [

	exampleClassName := anObject
]

{ #category : #'private - running' }
GtRrClassExampleTask >> group [
	| exampleClass |

	exampleClass := self classWithName: exampleClassName.
	^ GtClassExampleGroup new exampleClass: exampleClass
]

{ #category : #printing }
GtRrClassExampleTask >> printSupplementalOn: aStream [

	aStream
		<< (exampleClassName ifNil: [ '<none>' ]);
		<< ', ';
		<< self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #ui }
GtRrClassExampleTask >> summaryAttributes [ 

	^ super summaryAttributes 
		add: #ClassName -> exampleClassName;
		yourself
]
