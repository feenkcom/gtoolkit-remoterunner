Class {
	#name : #GtRrCheckScheduler,
	#superclass : #Object,
	#instVars : [
		'schedulingTimes',
		'maxDuration'
	],
	#category : 'RemoteRunner-CheckScheduling'
}

{ #category : #accessing }
GtRrCheckScheduler class >> defaultTaskDuration [
	"Answer the target task duration in which tests will be grouped"

	^ 10 seconds
]

{ #category : #api }
GtRrCheckScheduler >> allocateEntries: entries to: taskAssociations [
	"Answer the collection of tasks to be submitted to the runner"
	<return: #SequenceableCollection of: #GtRrAbstractExamplesTask>
	| index checkGroup groupTime faster slower midPoint entriesSize addSlower next nextTime entry expectedTime |

	groupTime := Duration zero.
	checkGroup := OrderedCollection new.
	entriesSize := entries size.

	"Tests that take >= maxDuration are run 1 at a time"
	index := 1.
	[ index <= entriesSize and: 
		[ entry := entries at: index.
		expectedTime := entry expectedTime.
		expectedTime >= maxDuration ] ] whileTrue:
			[ taskAssociations add: expectedTime -> (entries at: index) asGtRrTask.
			index := index + 1 ].

	"Split the remaining tests in two and mix faster and slower tests in to groups < maxDuration"
	midPoint := (index + ((entriesSize - index) // 2)) min: entriesSize.
	slower := (entries copyFrom: index to: midPoint) readStream.
	faster := (entries copyFrom: midPoint+1 to: entriesSize) reversed readStream.
	addSlower := true.

	"Group and add the remaining tests, alternating from slower and faster so that we don't have
	1 task with many tests at the end"
	[ slower atEnd not or: [ faster atEnd not ] ] whileTrue:
		[ next := addSlower
			ifTrue: [ slower next ]
			ifFalse: [ faster next ].
		next ifNotNil:
			[ nextTime := next expectedTime.
			(groupTime + nextTime) < maxDuration ifFalse:
				[ taskAssociations add: groupTime -> (self taskFrom: checkGroup).
				groupTime := Duration zero.
				checkGroup := OrderedCollection new ].
			checkGroup add: next.
			groupTime := groupTime + nextTime ].
		addSlower := addSlower not ].
	checkGroup ifNotEmpty: [ taskAssociations add: groupTime -> (self taskFrom: checkGroup) ].
]

{ #category : #api }
GtRrCheckScheduler >> allocateTasks: aCollectionOfTasks [
	"Answer the collection of tasks to be submitted to the runner"
	| typedEntries entries explicitTask expectedTime totalTime |

	typedEntries := Dictionary new.
	totalTime := Duration zero.
	aCollectionOfTasks do: [ :task |
		explicitTask := task asExplicitTask.
		explicitTask checkNames do: [ :name |
			expectedTime := schedulingTimes
						timeForClassName: name key
						selector: name value.
			totalTime := totalTime + expectedTime.
			(typedEntries at: explicitTask class name ifAbsentPut: [ OrderedCollection new ])
				add: (GtRrCheckSchedulerEntry new
					name: name;
					taskClassName: explicitTask class name;
					expectedTime: expectedTime) ] ].
	entries := OrderedCollection new.
	maxDuration := totalTime / 30 min: self class defaultTaskDuration.
	typedEntries do: [ :anOC |
		self allocateEntries: (anOC sorted: [ :a :b | a hasLongerExpectedTimeThan: b ])
		to: entries ].
	^ (entries sorted: [ :a :b | a key > b key ]) collect: #value
]

{ #category : #accessing }
GtRrCheckScheduler >> initialize [

	super initialize.
	"Don't use the default scheduling times yet so it doesn't subscribe to the default runner"
	"schedulingTimes := GtRrCheckSchedulingTimes default."
]

{ #category : #accessing }
GtRrCheckScheduler >> maxDuration [

	^ maxDuration
]

{ #category : #accessing }
GtRrCheckScheduler >> maxDuration: anObject [

	maxDuration := anObject
]

{ #category : #accessing }
GtRrCheckScheduler >> schedulingTimes [

	^ schedulingTimes
]

{ #category : #accessing }
GtRrCheckScheduler >> schedulingTimes: anObject [

	schedulingTimes := anObject
]

{ #category : #accessing }
GtRrCheckScheduler >> taskFrom: testGroup [
	"Answer a task with the supplied tests.
	testGroup is a collection of {{gtClass:GtRrCheckSchedulerEntry}}."
	| taskClassName |

	taskClassName := testGroup first taskClassName.
	
	^ (self class environment at: taskClassName) checkNames: 
		(testGroup collect: #name).
]
