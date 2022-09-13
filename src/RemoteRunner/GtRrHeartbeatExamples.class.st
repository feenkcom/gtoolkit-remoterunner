Class {
	#name : #GtRrHeartbeatExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrHeartbeatExamples >> assert: actual equals: expected description: description [
	^ self
		assert: actual = expected
		description: [description, ': ', (self comparingStringBetween: actual and: expected)]
]

{ #category : #accessing }
GtRrHeartbeatExamples >> simpleRunnerPoolSize: anInteger [
	"Answer a RemoteRunner with the specified pool size"
	| remoteRunner  |

	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown 
		autoRestart: false;
		poolSize: anInteger.

	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	^ remoteRunner
]

{ #category : #accessing }
GtRrHeartbeatExamples >> waitOn: aSemaphore for: anInteger description: descriptionString [

	(aSemaphore waitTimeoutSeconds: anInteger)
		ifTrue: [ self error: descriptionString ]
]

{ #category : #examples }
GtRrHeartbeatExamples >> workerHeartbeatTimeout [
	"Demonstrate executing a simple task"
	<gtExample>
	<noTest>
	| remoteRunner job successTask timeoutTask jobSemaphore workerRegisteredSemaphore timeout |

	GtRemoteRunnerExamples new ignoreWorkerExamples ifTrue: [ ^ self ].
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := self simpleRunnerPoolSize: 2.
	timeout := GtRrWorker heartbeatDelay totalSeconds.
	self assert: timeout equals: 20.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi    GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	successTask := GtRrScriptTask script: (timeout * 3) asString, ' seconds wait'.
	timeoutTask := GtRrScriptTask script: 'GtRrWorker allInstancesDo: #stopHeartbeat. ', (timeout * 10) asString, ' seconds wait'.
	job := GtRrTasksJob tasks: { successTask. timeoutTask }.
	job
		when: GtRrJobCompletedAnnouncement do: 
			[ jobSemaphore signal ].

	[ 2 timesRepeat:
		[ self waitOn: workerRegisteredSemaphore for: 20
			description: 'Worker didn''t register in time' ].

	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 180 description: 'Job didn''t complete in time'.

	self assert: remoteRunner taskQueue size equals: 0
		description: 'Expected empty task queue'.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0
		description: 'Expected no currently executing jobs'.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0
		description: 'Expected no currently executing tasks'.
	self assert: job state equals: #completed
		description: 'Expected job to be completed'.
	self deny: successTask hasErrors
		description: 'successTask should not have errors'.
	self assert: timeoutTask hasErrors
		description: 'timeoutTask should have errors'.
	self assert: (timeoutTask errorDetails errorMessage = 'Worker Heartbeat Lost')
		description: 'Expected Worker Unregistered error'.
	self assert: ((successTask duration totalSeconds - (timeout * 3)) abs < 5)
		description: 'successTask duration outside acceptable bounds'.
	self assert: (timeoutTask serverDuration totalSeconds between: (timeout * 1.5) and: (timeout * 1.5 + 10))
		description: 'timeoutTask duration outside acceptable bounds'.
	] ensure: [ remoteRunner stop ].

	^ job
]
