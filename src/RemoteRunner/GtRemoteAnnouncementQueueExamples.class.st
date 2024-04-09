Class {
	#name : #GtRemoteAnnouncementQueueExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRemoteAnnouncementQueueExamples >> queueGetsAnnouncements [
	<gtExample>
	| job jobSemaphore queue polled runner |

	runner := GtRemoteRunnerExamples new simpleRunner.
	queue := GtRemoteAnnouncementQueue onAnnouncingObject: runner.
	jobSemaphore := Semaphore new.
	self assert: queue poll size equals: 0.

	[ runner start.
	job := GtRemoteRunnerExamples new simpleJob.
	job when: GtRrJobCompletedAnnouncement
		do: [ :ann | jobSemaphore signal ].
	runner submitJob: job.

	jobSemaphore wait.
	polled := queue poll.
	self assert: polled size equals: 8.
	self assert: ((polled at: 6) isKindOf: GtRrTaskCompletedAnnouncement) description: 'Task is finished and announcement is in queue'.
	self assert: (polled last isKindOf: GtRrJobCompletedAnnouncement) description: 'Job is finished and announcement is in queue'.

	self assert: queue poll size equals: 0 ]
		ensure: [ runner stop ].

	self assert: queue poll size equals: 1.

	^ queue
]
