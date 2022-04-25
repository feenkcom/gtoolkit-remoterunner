Class {
	#name : #GtRrExampleTestFactory,
	#superclass : #GtRrTaskFactory,
	#instVars : [
		'ignoreNoTest'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #adding }
GtRrExampleTestFactory >> addExampleClass: aClass [
	| task |
	
	(aClass isAbstract or: [ aClass isTrait ]) ifTrue: [ ^ self ].

	(aClass gtExamples isNotEmpty and: [ aClass isTrait not ]) ifTrue:
		[ task := GtRrClassExampleTask exampleClassName: aClass name.
		ignoreNoTest ifTrue: [ task setIgnoreNoTest ].
		self addTask: task ].
]

{ #category : #adding }
GtRrExampleTestFactory >> addExampleClassNames: aCollectionOfClassNames [
	| cls task |

	aCollectionOfClassNames do: [ :className |
		cls := self classWithName: className.
		cls gtExamples ifNotEmpty:
			[ task := GtRrClassExampleTask exampleClassName: className.
			ignoreNoTest ifTrue: [ task setIgnoreNoTest ].
			self addTask: task ] ].
]

{ #category : #adding }
GtRrExampleTestFactory >> addExampleClasses: aCollectionOfClasses [

	aCollectionOfClasses do: [ :cls |
		self addExampleClass: cls ].
]

{ #category : #adding }
GtRrExampleTestFactory >> addExamplePackages: aCollectionOfPackages [

	aCollectionOfPackages do: [ :package |
		self addExampleClasses: package classes ]
]

{ #category : #adding }
GtRrExampleTestFactory >> addExampleTestNames: aCollectionOfGtExample [

	self addTask: (GtRrExplicitExampleTask examples: aCollectionOfGtExample)
]

{ #category : #adding }
GtRrExampleTestFactory >> addSUnitClass: aClass [
	| task |

	((aClass inheritsFrom: TestCase) and: [ aClass isAbstract not ]) ifFalse: [ ^ self ].

	task := GtRrClassSUnitTask sunitClassName: aClass name.
	self addTask: task.
]

{ #category : #adding }
GtRrExampleTestFactory >> addSUnitClassNames: aCollectionOfClassNames [

	aCollectionOfClassNames do: [ :className |
		self addSUnitClass: (self classWithName: className) ].
]

{ #category : #adding }
GtRrExampleTestFactory >> addSUnitClasses: aCollectionOfClasses [

	aCollectionOfClasses do: [ :cls |
		self addSUnitClass: cls ].
]

{ #category : #adding }
GtRrExampleTestFactory >> addSUnitPackages: aCollectionOfPackages [

	aCollectionOfPackages do: [ :package |
		self addSUnitClasses: package classes ]
]

{ #category : #adding }
GtRrExampleTestFactory >> addSUnitTestNames: aCollection [

	self addTask: (GtRrExplicitSUnitTask sunitTestNames: aCollection)
]

{ #category : #adding }
GtRrExampleTestFactory >> addTask: aTask [

	aTask taskTimeout: taskTimeout.
	stream nextPut: aTask
]

{ #category : #initialization }
GtRrExampleTestFactory >> initialize [

	super initialize.
	ignoreNoTest := false.
]

{ #category : #initialization }
GtRrExampleTestFactory >> setIgnoreNoTest [ 

	ignoreNoTest := true.
]
