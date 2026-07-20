Class {
	#name : #GtRemoteAnnouncementQueueExamples,
	#superclass : #Object,
	#traits : 'TAssertable + TGtRrExampleHelp',
	#classTraits : 'TAssertable classTrait + TGtRrExampleHelp classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRemoteAnnouncementQueueExamples >> queueGetsAnnouncements [
	<gtExample>
	<return: #GtRemoteAnnouncementQueue>
	| job jobSemaphore queue polled runnerExamples runner |
	runnerExamples := GtRemoteRunnerExamples new.
	runnerExamples ignoreWorkerExamples ifTrue: [ ^ self ].
	runner := runnerExamples simpleRunner.
	queue := GtRemoteAnnouncementQueue onAnnouncingObject: runner.
	jobSemaphore := Semaphore new.
	self assert: queue poll size equals: 0.

	[ runner start.
	job := GtRemoteRunnerExamples new simpleJob.
	job 
		when: GtRrJobCompletedAnnouncement 
		do: [ :ann | jobSemaphore signal ]
		for: self.
	runner submitJob: job.

	self
		waitOn: jobSemaphore
		for: 30
		description: 'Job didn''t complete in time'.
	polled := queue poll.
	self assert: polled size equals: 8.
	self
		assert: ((polled at: 6) isKindOf: GtRrTaskCompletedAnnouncement)
		description: 'Task is finished and announcement is in queue'.
	self
		assert: (polled last isKindOf: GtRrJobCompletedAnnouncement)
		description: 'Job is finished and announcement is in queue'.

	self assert: queue poll size equals: 0 ] ensure: [ runner stop ].

	self assert: queue poll size equals: 1.

	^ queue
]
