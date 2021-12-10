"
GtRrTaskAllocator is responsible for grouping job elements in to tasks to be performed by the workers.

The goal is typically to keep all workers busy, but have them finish at the same time.

A simplistic strategy is to hand each worker one test at a time, however this is inefficient as the communication overhead is often larger than the task time.  {{gtClass:GtRrOneAtATimeTestsTaskAllocator}} implements this strategy for testing the remote runner.

A good strategy is to know how long each test is expected to run, group elements in to tasks of at least a minimum time, e.g. 10 seconds, and hand them out that way.

Subclasses will implement the various strategies based on the information available.
"
Class {
	#name : #GtRrTaskAllocator,
	#superclass : #Object,
	#category : #'RemoteRunner-Tasks'
}

{ #category : #'as yet unclassified' }
GtRrTaskAllocator class >> remoteRunner: aGtRemoteRunner [

	^ self new remoteRunner: aGtRemoteRunner
]

{ #category : #allocating }
GtRrTaskAllocator >> allocateItems: aCollection [
	"Answer the collection of tasks to be submitted to the runner"
	<return: #SequenceableCollection>

	^ self subclassResponsibility
]
