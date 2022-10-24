Class {
	#name : #GtRrAverageTimeExampleAllocatorExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrAverageTimeExampleAllocatorExamples >> allocateLargeExamplesJob [
	"Demonstrate allocating examples to tasks for a small job (see {{gtClass:GtRrAverageTimeExampleAllocator}})"
	<gtExample>
	| exampleNames tasks |

	exampleNames := (1 to: 142) collect: [ :i |
		#ClassName -> ('testName', i asString) asSymbol ].
	tasks := GtRrAverageTimeExampleAllocator new allocateTasks: 
		{ (GtRrExplicitExampleTask examples: exampleNames) }.
	self assert: tasks size equals: 15.
	self assert: (tasks inject: 0 into: [ :s :v | s + v examples size])
			equals: 142.
	self assert: (tasks allSatisfy: [ :each | each examples size <= 10 ]).
	^ tasks
]

{ #category : #examples }
GtRrAverageTimeExampleAllocatorExamples >> allocateLargeSUnitTestsJob [
	"Demonstrate allocating examples to tasks for a small job (see {{gtClass:GtRrAverageTimeExampleAllocator}})"
	<gtExample>
	| testNames tasks |

	testNames := (1 to: 142) collect: [ :i |
		#ClassName -> ('testName', i asString) asSymbol ].
	tasks := GtRrAverageTimeExampleAllocator new allocateTasks: 
		{ (GtRrExplicitSUnitTask sunitTestNames: testNames) }.
	self assert: tasks size equals: 15.
	self assert: (tasks inject: 0 into: [ :s :v | s + v sunitTestNames size])
			equals: 142.
	self assert: (tasks allSatisfy: [ :each | each sunitTestNames size <= 10 ]).
	^ tasks
]

{ #category : #examples }
GtRrAverageTimeExampleAllocatorExamples >> allocateSmallExamplesJob [
	"Demonstrate allocating examples to tasks for a small job (see {{gtClass:GtRrAverageTimeExampleAllocator}})"
	<gtExample>
	| exampleNames tasks |

	exampleNames := (1 to: 42) collect: [ :i |
		#ClassName -> ('testName', i asString) asSymbol ].
	tasks := GtRrAverageTimeExampleAllocator new allocateTasks: 
		{ (GtRrExplicitExampleTask examples: exampleNames) }.
	self assert: tasks size equals: 9.
	self assert: (tasks inject: 0 into: [ :s :v | s + v examples size])
			equals: 42.
	self assert: (tasks allSatisfy: [ :each | each examples size <= 10 ]).
	^ tasks
]

{ #category : #examples }
GtRrAverageTimeExampleAllocatorExamples >> allocateSmallSUnitTestsJob [
	"Demonstrate allocating examples to tasks for a small job (see {{gtClass:GtRrAverageTimeExampleAllocator}})"
	<gtExample>
	| testNames tasks |

	testNames := (1 to: 42) collect: [ :i |
		#ClassName -> ('testName', i asString) asSymbol ].
	tasks := GtRrAverageTimeExampleAllocator new allocateTasks: 
		{ (GtRrExplicitSUnitTask sunitTestNames: testNames) }.
	self assert: tasks size equals: 9.
	self assert: (tasks inject: 0 into: [ :s :v | s + v sunitTestNames size])
			equals: 42.
	self assert: (tasks allSatisfy: [ :each | each sunitTestNames size <= 10 ]).
	^ tasks
]
