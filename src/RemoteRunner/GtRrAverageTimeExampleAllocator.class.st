"
GtRrAverageTimeExampleAllocator allocates tasks based on an average example / test execution time.

If there are only a small number of tests then a task is created for each test (on the assumption that the advantage a parallel execution exceeds the communications overhead).

The communication overhead is assumed to be about 100mS, and that 1 second overhead for parallel execution doesn't matter, i.e. create up to 10 tasks and spread the examples evenly across them up to 100 seconds worth.
"
Class {
	#name : #GtRrAverageTimeExampleAllocator,
	#superclass : #Object,
	#instVars : [
		'totalExpectedTime'
	],
	#classVars : [
		'AverageTime'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #accessing }
GtRrAverageTimeExampleAllocator class >> averageTime [

	^ AverageTime
]

{ #category : #accessing }
GtRrAverageTimeExampleAllocator class >> averageTime: anObject [

	AverageTime := anObject
]

{ #category : #private }
GtRrAverageTimeExampleAllocator >> allocateExamplesTasks: exampleNames [

	^ (self groupNames: exampleNames) collect: [ :each |
		GtRrExplicitExampleTask examples: each ]
]

{ #category : #private }
GtRrAverageTimeExampleAllocator >> allocateSUnitTasks: exampleNames [

	^ (self groupNames: exampleNames) collect: [ :each |
		GtRrExplicitSUnitTask sunitTestNames: each ]
]

{ #category : #allocating }
GtRrAverageTimeExampleAllocator >> allocateTasks: aCollectionOfTasks [
	"Answer the collection of tasks to be submitted to the runner"
	| testNames exampleNames tasks |

	exampleNames := OrderedCollection new.
	testNames := OrderedCollection new.
	aCollectionOfTasks do: [ :task |
		task isExamplesTask ifTrue:
			[ exampleNames addAll: task asExplicitTask examples ].
		task isSUnitTask ifTrue:
			[ testNames addAll: task asExplicitTask sunitTestNames ] ].
	totalExpectedTime := self averageTime * (exampleNames size + testNames size).
	tasks := OrderedCollection withAll: (self allocateExamplesTasks: exampleNames).
	tasks addAll: (self allocateSUnitTasks: testNames).
	^ tasks.
]

{ #category : #accessing }
GtRrAverageTimeExampleAllocator >> averageTime [

	^ AverageTime ifNil: [ AverageTime := 1 second ].
]

{ #category : #private }
GtRrAverageTimeExampleAllocator >> groupNames: aCollection [

	^ self isSmallJob
		ifTrue: [ self smallJobGroupNames: aCollection ]
		ifFalse: [ self largeJobGroupNames: aCollection ]
]

{ #category : #testing }
GtRrAverageTimeExampleAllocator >> isSmallJob [
	"Answer a boolean indicating whether the receiver's job is considered small and should be just spread across up to 10 tasks"

	^ totalExpectedTime < 100 seconds.
]

{ #category : #private }
GtRrAverageTimeExampleAllocator >> largeJobGroupNames: aCollection [
	"Split the examples / tests across tasks with an expected time of less than 10 seconds"
	| allocationSize nameStream names |

	allocationSize := (10 / self averageTime asSeconds) floor.
	nameStream := aCollection readStream.
	^ Array streamContents: [ :stream |
		[ (names := nameStream next: allocationSize) isEmpty ] whileFalse:
			[ stream nextPut: names ] ].
]

{ #category : #private }
GtRrAverageTimeExampleAllocator >> smallJobGroupNames: aCollection [
	"Split the examples / tests across 10 tasks"
	| allocationSize nameStream names |

	allocationSize := (aCollection size / 10) roundUpTo: 1.
	nameStream := aCollection readStream.
	^ Array streamContents: [ :stream |
		[ (names := nameStream next: allocationSize) isEmpty ] whileFalse:
			[ stream nextPut: names ] ].
]
