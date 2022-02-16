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

	exampleClass := (exampleClassName endsWith: ' class')
		ifTrue: [ (exampleClassName copyFrom: 1 to: exampleClassName size - 6) asClass class ]
		ifFalse: [ exampleClassName asClass ].
	^ GtClassExampleGroup new exampleClass: exampleClass
]

{ #category : #ui }
GtRrClassExampleTask >> summaryAttributes [ 

	^ super summaryAttributes 
		add: #ClassName -> exampleClassName;
		yourself
]
