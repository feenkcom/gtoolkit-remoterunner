Class {
	#name : #GtRemoteAnnouncementQueueExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRemoteAnnouncementQueueExamples >> simpleQueue [
	<gtExample>
	<noTest>
	| runner queue |
	runner := GtRemoteRunnerExamples new simpleRunner.
	
	queue := GtRemoteAnnouncementQueue onAnnouncingObject: runner.
	
	self assert: queue poll size equals: 0.
	
	^ queue
]

{ #category : #accessing }
GtRemoteAnnouncementQueueExamples >> simpleQueueWithAnnouncement [
	<gtExample>
	<noTest>
	| queue polled runner |
	queue := self simpleQueueWithStartedJobs.
	runner := queue object.
	
	5 seconds wait.
	polled := queue poll.
	self assert: polled size equals: 6.
	self assert: (polled allButLast last isKindOf: GtRrTaskCompletedAnnouncement) description: 'Task is finished and announcement is in queue'.
	self assert: (polled last isKindOf: GtRrJobCompletedAnnouncement) description: 'Job is finished and announcement is in queue'.
	
	self assert: queue poll size equals: 0.
	
	runner stop.
	
	self assert: queue poll size equals: 1.
	
	^ queue
]

{ #category : #accessing }
GtRemoteAnnouncementQueueExamples >> simpleQueueWithStartedJobs [
	<gtExample>
	<noTest>
	| queue runner |
	queue := self simpleQueue.
	runner := queue object.
	
	runner start.
	runner submitJob: GtRemoteRunnerExamples new simpleJob.
	
	self deny: runner state equals: #idle.
	
	^ queue
]
