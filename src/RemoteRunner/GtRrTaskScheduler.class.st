"
GtRrTaskScheduler is responsible for grouping tests in to tasks to be performed by the workers.

The goal is typically to keep all workers busy, but have them finish at the same time.

A simplistic strategy is to hand each worker one test at a time, however this is inefficient as the communication overhead is often larger than the test time.  {{gtClass:GtRrOneAtATimeTaskScheduler}} implements this strategy for testing the remote runner.

A slightlty better strategy is to group tests that are from the same class and have one or more resources defined together so that the resources are only initialised once.

A good strategy is to know how long each test is expected to run, group tests in to tasks of at least a minimum time, e.g. 10 seconds, and hand them out that way.

Subclasses will implement the various strategies based on the information available.
"
Class {
	#name : #GtRrTaskScheduler,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtRrTaskScheduler class >> remoteRunner: aGtRemoteRunner [

	^ self new remoteRunner: aGtRemoteRunner
]

{ #category : #accessing }
GtRrTaskScheduler >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrTaskScheduler >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #schedulling }
GtRrTaskScheduler >> schedule: aGtRrJobContext [
	"Group allTasks from the job in to tasks on the context's pending queue"

	self subclassResponsibility 
]
