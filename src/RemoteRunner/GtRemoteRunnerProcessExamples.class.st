Class {
	#name : #GtRemoteRunnerProcessExamples,
	#superclass : #Object,
	#traits : 'TAssertable + TGtRrExampleHelp',
	#classTraits : 'TAssertable classTrait + TGtRrExampleHelp classTrait',
	#instVars : [
		'remoteRunner',
		'workers'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #testing }
GtRemoteRunnerProcessExamples class >> isAbstract [
	^ self name = #GtRemoteRunnerProcessExamples
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> changesSync [
	"Demonstrate getting changes to a worker from the server"
	<gtExample>
	<after: #stopRunnersAndWorkers>
	<return: #SubclassResponsibility>
	<shouldLogWithEpicea>
	| entry semaphore events job jobSemaphore |
	
	self setUp.
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self class removeSelector: #changesSyncTestMethod.
	entry := OmEntry
			content: (EpMethodAddition
					method: ((RGMethodDefinition named: #changesSyncTestMethod)
							parentName: self class name;
							isMetaSide: true;
							protocol: #toberemoved;
							sourceCode: 'changesSyncTestMethod  ^ true';
							stamp: 'StompExamples 2/19/2025 12:00';
							package: #RemoteRunner;
							yourself)).
	entry tags at: #self put: (OmReference globalName: 'test' localName: '1').
	events := GtRrImageSyncEvents new
			sessionHistory: GtRrChangesSync default sessionHistory;
			events: {entry}.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := self simpleRunner.
	remoteRunner managerStartupAndShutdown workerManager
		changesSync: true;
		poolSize: 1.
	remoteRunner
		changesSyncEvents: events;
		start.
	jobSemaphore := Semaphore new.
	job := (GtRrScriptTask
			script: self class name asString , ' includesSelector: #changesSyncTestMethod')
			asJob.
	job 
		when: GtRrJobCompletedAnnouncement 
		do: [ jobSemaphore signal ]
		for: self.
	remoteRunner submitJob: job.
	self
		waitOn: jobSemaphore
		for: 30
		description: 'Job didn''t complete in time'.
	self assert: job results first result
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> changesSyncRetrieval [
	"Demonstrate getting changes to a worker from the server"
	<gtExample>
	<after: #stopRunnersAndWorkers>
	<return: #SubclassResponsibility>
	| entry semaphore worker events receivedEvents |

	self setUp.
	self ignoreWorkerExamples ifTrue: [ ^ nil ].
	entry := OmEntry content: (EpExpressionEvaluation expression: '4+3').
	entry tags at: #self put: (OmReference globalName: 'test' localName: '1').
	events := GtRrImageSyncEvents new
			sessionHistory: GtRrChangesSync default sessionHistory;
			events: {entry}.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := self simpleRunner.
	remoteRunner managerStartupAndShutdown workerManager poolSize: 0.
	remoteRunner
		changesSyncEvents: events;
		start.

	worker := self workerForRunner: remoteRunner.
	worker start.
	workers := {worker}.
	worker attributes at: #changesSync put: true.
	worker connectionStrategy
		connectDuring: [ :application | receivedEvents := worker syncChangesWith: application ].
	self assert: receivedEvents equals: events events
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> commandLineRemoteRunnerServer [
	<gtExample>
	<return: #GtRemoteRunnerProcessExamples>
	| commandLine |
	commandLine := GtRemoteRunner commandLineCommand
			match: {'remoteRunnerServer'.
					'--listenOn'.
					'7042'}.

	self assert: (commandLine at: #log) value equals: false.
	self assert: ((commandLine at: #listenOn) at: #address) value isNotNil
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> controlChannelPing [
	"Demonstrate the ping operation using the worker's control channel"
	<gtExample>
	<return: #SubclassResponsibility>
	| controlChannelSemaphore worker |
	
	self setUp.
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	controlChannelSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := self simpleRunner.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerControlChannelRegisteredAnnouncement
		do: [ :ann | 
			worker := ann worker.
			controlChannelSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: controlChannelSemaphore
		for: 20
		description: 'Control channel didn''t register in time'.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	self assert: worker commandPing equals: #ping.
	self assert: remoteRunner registeredWorkerCount equals: 1 ]
		ensure: [ remoteRunner stop ].

	^ worker
]

{ #category : #private }
GtRemoteRunnerProcessExamples >> ignoreWorkerExamples [
	"Answer a boolean indicating whether examples that require a subprocess should be run.
	Convenience in case the CI decides it doesn't want to be nice."

	^ [ (NetNameResolver localHostName endsWith: 'hosting.net') and:
		[ Smalltalk vm architectureName = 'x86_64' ] ]
		on: Error
		do: [ :ex | false ]

]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> multipleJobs [
	"Demonstrate executing a multiple jobs"
	<gtExample>
	<return: #SubclassResponsibility>
	| job jobs completingTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := self simpleRunner.
	remoteRunner managerStartupAndShutdown workerManager poolSize: 2.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 20
		description: 'Worker didn''t register in time'.
	jobs := (1 to: 2) collect: [ :i | 
		completingTask := GtRrScriptTask script: '#done'.
		job := GtRrTasksJob new tasks: {completingTask}.
		job
			when: GtRrJobStartedAnnouncement
				do: [ jobStartedCount := jobStartedCount + 1 ]
				for: self;
			when: GtRrJobCompletedAnnouncement
				do: [ jobCompletedCount := jobCompletedCount + 1.
					jobSemaphore signal ]
				for: self;
			when: GtRrJobCancelledAnnouncement
				do: [ jobCompletedCount := jobCompletedCount + 1 ]
				for: self;
			when: GtRrTaskStartedAnnouncement
				do: [ taskStartedCount := taskStartedCount + 1 ]
				for: self;
			when: GtRrTaskCompletedAnnouncement
				do: [ taskCompletedCount := taskCompletedCount + 1 ]
				for: self;
			when: GtRrTaskFailedAnnouncement
				do: [ taskFailedCount := taskFailedCount + 1 ]
				for: self.
		job ].
	jobs do: [ :aJob | remoteRunner submitJob: aJob ].
	2 timesRepeat: [ self
		waitOn: jobSemaphore
		for: 30
		description: 'Job didn''t complete in time' ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 2.
	self assert: jobStartedCount equals: 2.
	self assert: taskCompletedCount equals: 2.
	self assert: taskFailedCount equals: 0.
	self assert: taskStartedCount equals: 2 ] 
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> multipleJobsSimultaneously [
	"Demonstrate executing multiple jobs started simultaneously"
	<gtExample>
	<noTest>
	| job jobs semaphore workerConnections retryCount currentTask workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := self simpleRunner.
	remoteRunner managerStartupAndShutdown workerManager poolSize: 2.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
		do: [ :ann | 
			workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	jobs := (1 to: 2) collect: [  :i |
		job := GtRrJob script: 'Semaphore new waitTimeoutSeconds: 60'.
		job 
			when: GtRrTaskStartedAnnouncement 
			do: [ semaphore signal ]
			for: self.
		job ].
	jobs do: [ :aJob | remoteRunner submitJob: aJob ].
	2 timesRepeat: [ self waitOn: semaphore for: 10 description: 'Job didn''t start in time' ].

	workerConnections := remoteRunner registeredWorkers values.
	workerConnections do: [ :workerConnection |
		retryCount := 10.
		[ currentTask := workerConnection commandCurrentTaskContextIdTimeout: 10.
		retryCount := retryCount - 1.
		currentTask isNil and: [ retryCount > 0 ] ] whileTrue:
			[ 500 milliSeconds wait ].
		currentTask ifNil:
			[ self error: 'Task never started on worker' ] ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 2.
	self assert: remoteRunner currentlyExecutingTasks size equals: 2.
	self assert: remoteRunner taskQueue size equals: 0.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> retryTaskFirst [
	"Demonstrate that a retried task is placed at the front of the queue, 
	and so is executed ASAP."
	<gtExample>
	<noTest>
	| tasks job jobSemaphore workerRegisteredSemaphore taskStartedSemaphore jobContext results |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	taskStartedSemaphore := Semaphore new.
	remoteRunner := self simpleRunner.
	"We want a single runner so that tasks are in the queue when the high priority task is added."
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner managerStartupAndShutdown workerManager changesSync: false.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
			do: [ :ann | 
				workerRegisteredSemaphore signal ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ :ann |
				taskStartedSemaphore signal ]
			for: self.
	remoteRunner
		startLogging;
		start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	tasks := (1 to: 4) collect: [ :i |
		GtRrScriptTask script: '1 second wait. ', i asString ].
	job := GtRrTasksJob tasks: tasks.
	job 
		when: GtRrJobCompletedAnnouncement 
		do: [ jobSemaphore signal ]
		for: self.
	remoteRunner submitJob: job.
	jobContext := remoteRunner currentlyExecutingJobs anyOne.
	"Ensure that the worker has retrieved at least 1 task from the queue."
	self waitOn: taskStartedSemaphore for: 20
		description: 'Task didn''t start in time'.
	remoteRunner addTaskContextFirst: (GtRrTaskContext new 
			task: (GtRrScriptTask script: '#high');
			jobContext: jobContext).
	self waitOn: jobSemaphore for: 240 description: 'Job didn''t complete in time'.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: job state equals: #completed.
	self deny: job hasErrors.
	results := job results collect: #result.
	self assert: results size equals: 5.
	self assert: ((results indexOf: #high) between: 2 and: 4).
	] ensure: 
		[ remoteRunner stop ].

	^ job
]

{ #category : #'private - helpers' }
GtRemoteRunnerProcessExamples >> setUp [
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> simpleJob [
	<gtExample>
	<return: #GtRrTasksJob>
	| completingTask |
	completingTask := GtRrScriptTask script: '#done'.
	^ GtRrTasksJob new tasks: {completingTask}
]

{ #category : #'private - helpers' }
GtRemoteRunnerProcessExamples >> simpleRunner [

	^ self subclassResponsibility
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> simpleTask [
	"Demonstrate executing a simple task"
	<gtExample>
	<noTest>
	| job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
		do: [ :ann | 
			workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	job := self simpleJob.
	job
		when: GtRrJobStartedAnnouncement 
			do: [ 
				jobStartedCount := jobStartedCount + 1.
				times add: 0 -> DateAndTime now. ]
			for: self;
		when: GtRrJobCompletedAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 4 -> DateAndTime now.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 5 -> DateAndTime now ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ 
				taskStartedCount := taskStartedCount + 1.
				times add: 1 -> DateAndTime now ]
			for: self;
		when: GtRrTaskCompletedAnnouncement 
			do: [ 
				taskCompletedCount := taskCompletedCount + 1.
				times add: 3 -> DateAndTime now. ]
			for: self;
		when: GtRrTaskFailedAnnouncement 
			do: [ 
				taskFailedCount := taskFailedCount + 1.
				times add: 2 -> DateAndTime now. ]
			for: self.
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time'.

	self assert: remoteRunner tasksRemainingCount equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 0.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #completed.
	self deny: job hasErrors.
	self assert: (times collect: #key) asArray equals: #(0 1 3 4).
	self assert: job results first result equals: #done.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> simpleTaskFailure [
	"Demonstrate executing a simple task that fails"
	<gtExample>
	<noTest>
	| job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
			do: [ :ann | 
				workerRegisteredSemaphore signal ]
			for: self.
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	job := (GtRrScriptTask script: 'self error: ''fail''') asJob.
	job
		when: GtRrJobStartedAnnouncement 
			do: [ 
				jobStartedCount := jobStartedCount + 1.
				times add: 0 -> DateAndTime now. ]
			for: self;
		when: GtRrJobCompletedAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 4 -> DateAndTime now.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 5 -> DateAndTime now ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ 
				taskStartedCount := taskStartedCount + 1.
				times add: 1 -> DateAndTime now ]
			for: self;
		when: GtRrTaskCompletedAnnouncement 
			do: [ 
				taskCompletedCount := taskCompletedCount + 1.
				times add: 3 -> DateAndTime now. ]
			for: self;
		when: GtRrTaskFailedAnnouncement 
			do: [ 
				taskFailedCount := taskFailedCount + 1.
				times add: 2 -> DateAndTime now. ]
			for: self.
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time'.

	self assert: remoteRunner tasksRemainingCount equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: taskFailedCount equals: 1.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: (times collect: #key) asArray equals: #(0 1 2 4).
	self assert: job results first result isNil.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> simpleTestRetryTask [
	"Demonstrate retrying a task that 'crashes' the worker.
	This will take approximately 4 times the worker heartbeat timeout time to execute (3 or 4 minutes)."
	<gtExample>
	<noTest>
	| factory job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	GtRrSampleTest compile: 
'testCrash
	Stdio stdout
		<< Time now printString;
		<< '' testCrash quitting image'';
		lf; flush.
	Smalltalk snapshot: false andQuit: true.'
			classified: #tests.
	remoteRunner := self simpleRunner.
	"At least 4 workers are needed, 3 will fail on the bad task, the last will run all remaining tests"
	remoteRunner managerStartupAndShutdown poolSize: 4.
	remoteRunner managerStartupAndShutdown workerManager changesSync: true.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
		do: [ :ann | 
			workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner
		startLogging;
		start.
	[ 4 timesRepeat:
			[ self waitOn: workerRegisteredSemaphore for: 20
				description: 'Worker didn''t register in time' ].
	factory := GtRrChecksFactory new.
	factory addSUnitTestNames: 
		{ #GtRrSampleTest -> #testPass.
		#GtRrSampleTest -> #testCrash. }.
	job := factory job.
	job
		when: GtRrJobStartedAnnouncement 
			do: [ 
				jobStartedCount := jobStartedCount + 1. ]
			for: self;
		when: GtRrJobCompletedAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1 ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ 
				taskStartedCount := taskStartedCount + 1 ]
			for: self;
		when: GtRrTaskCompletedAnnouncement 
			do: [ 
				taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement 
			do: [ 
				taskFailedCount := taskFailedCount + 1 ]
			for: self.
	job tasks do: [ :task |
		task retryStrategy: GtRrTaskTestRetry new ].
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 240 description: 'Job didn''t complete in time'.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: jobStartedCount equals: 1.
	self assert: jobCompletedCount equals: 1.
	self assert: taskStartedCount equals: 4.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 1.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	] ensure: 
		[ remoteRunner stop.
		GtRrSampleTest removeSelector: #testCrash. ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> simpleTestTask [
	"Demonstrate executing a simple test task"
	<gtExample>
	| factory job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 30
		description: 'Worker didn''t register in time'.
	factory := GtRrChecksFactory new.
	factory addSUnitTestNames: {#GtRrSampleTest -> #testPass}.
	job := factory job.
	job
		when: GtRrJobStartedAnnouncement
			do: [ jobStartedCount := jobStartedCount + 1.
				times add: 0 -> DateAndTime now ]
			for: self;
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				times add: 4 -> DateAndTime now.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				times add: 5 -> DateAndTime now ]
			for: self;
		when: GtRrTaskStartedAnnouncement
			do: [ taskStartedCount := taskStartedCount + 1.
				times add: 1 -> DateAndTime now ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1.
				times add: 3 -> DateAndTime now ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ taskFailedCount := taskFailedCount + 1.
				times add: 2 -> DateAndTime now ]
			for: self.
	remoteRunner submitJob: job.
	self
		waitOn: jobSemaphore
		for: 30
		description: 'Job didn''t complete in time'.

	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: jobStartedCount equals: 1.
	self assert: jobCompletedCount equals: 1.
	self assert: taskStartedCount equals: 1.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 0.
	self assert: job state equals: #completed.
	self deny: job hasErrors.
	self assert: (times collect: #key) asArray equals: #(0 1 3 4) ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #'private - helpers' }
GtRemoteRunnerProcessExamples >> stopRunnersAndWorkers [

	workers ifNotNil:
		[ workers do: #stop.
		workers := nil ].
	remoteRunner ifNotNil:
		[ remoteRunner stop.
		remoteRunner := nil ].
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> terminateStartedJobWithControlChannel [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated"
	<gtExample>
	<noTest>
	| job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount times workerConnection currentTask retryCount workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
		do: [ :ann | 
			workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	"Create a set of tasks that never complete"
	tasks := (1 to: 3) collect: [ :i |
		GtRrScriptTask script: 'Semaphore new wait' ].
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobStartedAnnouncement 
			do: [ 
				jobStartedCount := jobStartedCount + 1.
				times add: 0 -> DateAndTime now. ]
			for: self;
		when: GtRrJobCompletedAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 4 -> DateAndTime now.
				semaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 5 -> DateAndTime now.
				semaphore signal ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ 
				taskStartedCount := taskStartedCount + 1.
				times add: 1 -> DateAndTime now.
				semaphore signal ]
			for: self;
		when: GtRrTaskCompletedAnnouncement 
			do: [ 
				taskCompletedCount := taskCompletedCount + 1.
				times add: 3 -> DateAndTime now. ]
			for: self;
		when: GtRrTaskFailedAnnouncement 
			do: [ 
				taskFailedCount := taskFailedCount + 1.
				times add: 2 -> DateAndTime now ]
			for: self.

	remoteRunner submitJob: job.
	self waitOn: semaphore for: 10 description: 'Task didn''t start in time'.
	workerConnection := remoteRunner registeredWorkers anyOne.
	retryCount := 10.
	[ currentTask := workerConnection commandCurrentTaskContextId.
	retryCount := retryCount - 1.
	currentTask isNil and: [ retryCount > 0 ] ] whileTrue.
	currentTask ifNil:
		[ self error: 'Task never started on worker' ].
	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner tasksRemainingCount equals: 2.
	remoteRunner terminateJobId: job jobId.
	self waitOn: semaphore for: 10 description: 'Job didn''t terminate in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: taskFailedCount equals: 3.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: (job results allSatisfy: [ :task | task hasErrors ]).
	self assert: (times collect: #key) asArray equals: #(0 1 2 2 2 4).
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> terminateStartedJobWithoutControlChannel [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated"
	<gtExample>
	<noTest>
	| job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount waitForTaskCompletion taskWaitTime workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	"Waiting for the task to complete is slow and may fail if the processor is very busy,
	so this is normally only set true for manual testing."
	waitForTaskCompletion := false.
	taskWaitTime := 15. "seconds"
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := self simpleRunner.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
			do: [ :ann | 
				workerRegisteredSemaphore signal ]
			for: self.
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	"Create a set of tasks that never complete"
	tasks := (1 to: 3) collect: [ :i |
		(GtRrScriptTask script: taskWaitTime asString, ' seconds wait')
			taskTimeout: 5 minutes;
			yourself ].
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobStartedAnnouncement 
			do: [ 
				jobStartedCount := jobStartedCount + 1 ]
			for: self;
		when: GtRrJobCompletedAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ 
				taskStartedCount := taskStartedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskCompletedAnnouncement 
			do: [ 
				taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement 
			do: [ 
				taskFailedCount := taskFailedCount + 1 ]
			for: self.

	remoteRunner submitJob: job.
	self waitOn: semaphore for: 10 description: 'Task didn''t start in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner tasksStartedCount equals: 1.
	self assert: remoteRunner tasksRemainingCount equals: 2.

	remoteRunner terminateJobId: job jobId.
	self waitOn: semaphore for: 10 description: 'Job didn''t terminate in time'.

	waitForTaskCompletion ifTrue:
		[ (taskWaitTime + 5) seconds wait.
		"After the task has completed on the worker it should become available again"
		self assert: remoteRunner availableWorkerCount equals: 1.
		 ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: taskFailedCount equals: 3.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: (job results allSatisfy: [ :task | task hasErrors ]).
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> timeoutJob [
	"Demonstrate terminating a job due to it timing out"
	<gtExample>
	<return: #SubclassResponsibility>
	| job tasks failedTasks taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |
	
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := 0.
	failedTasks := OrderedCollection new.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := self simpleRunner.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 30
		description: 'Worker didn''t register in time'.	"Create a set of tasks that never complete"
	tasks := (1 to: 3)
			collect: [ :i | GtRrScriptTask script: 'Semaphore new wait' ]
			as: OrderedCollection.
	job := GtRrTasksJob new
			tasks: tasks;
			jobTimeout: 5 seconds.
	job
		when: GtRrJobStartedAnnouncement
			do: [ jobStartedCount := jobStartedCount + 1 ]
			for: self;
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1 ]
			for: self;
		when: GtRrTaskStartedAnnouncement
			do: [ taskStartedCount := taskStartedCount + 1 ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ :announcement | failedTasks add: announcement task ]
			for: self.
	remoteRunner submitJob: job.
	self
		waitOn: jobSemaphore
		for: 30
		description: 'Job didn''t complete in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: failedTasks size equals: 3.
	self
		assert: (taskStartedCount between: 1 and: 3)
		description: [ 'Unexpected taskStartedCount: ' , taskStartedCount asString ].
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: job errorDetails errorMessage equals: 'Job exceeded time limit' ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> timeoutTask [
	"Demonstrate terminating a task due to it timing out"
	<gtExample>
	<noTest>
	| job completingTask timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	taskFailedSemaphore := Semaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.
	self assert: remoteRunner workerTimeout > 1 minute.
	remoteRunner startLogging.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
			do: [ :ann | 
				workerRegisteredSemaphore signal ]
			for: self.
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 30
		description: 'Worker didn''t register in time'.
	"Create a task that never completes"
	timeoutTask := GtRrScriptTask script: 'Semaphore new wait'.
	timeoutTask taskTimeout: 200 milliSeconds.
	completingTask := GtRrScriptTask script: '#done'.
	job := GtRrTasksJob new
		tasks: { timeoutTask. completingTask }.
	job
		when: GtRrJobStartedAnnouncement 
			do: [ 
				jobStartedCount := jobStartedCount + 1.
				times add: 0 -> DateAndTime now. ]
			for: self;
		when: GtRrJobCompletedAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 4 -> DateAndTime now.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement 
			do: [ 
				jobCompletedCount := jobCompletedCount + 1.
				times add: 5 -> DateAndTime now ]
			for: self;
		when: GtRrTaskStartedAnnouncement 
			do: [ 
				taskStartedCount := taskStartedCount + 1.
				times add: 1 -> DateAndTime now ]
			for: self;
		when: GtRrTaskCompletedAnnouncement 
			do: [ 
				taskCompletedCount := taskCompletedCount + 1.
				times add: 3 -> DateAndTime now. ]
			for: self;
		when: GtRrTaskFailedAnnouncement 
			do: [ 
				taskFailedCount := taskFailedCount + 1.
				times add: 2 -> DateAndTime now.
				taskFailedSemaphore signal. ]
			for: self.
	remoteRunner submitJob: job.
	"When the task has failed, trigger the watchdog to start a new worker, which will run the second task"
	self waitOn: taskFailedSemaphore for: 30 description: 'Task didn''t fail in time'.
	[ "Give the process time to die and be registered by the subprocess.
	If this isn't enough time, it will be caught on the next cycle (just take longer)."
		2 seconds wait.
		remoteRunner ifNotNil: [ :rr |
			rr managerStartupAndShutdown workerManager signalWatchdog ] ] fork.
	self waitOn: jobSemaphore for: 40 description: 'Job didn''t complete in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 1.
	self assert: taskStartedCount equals: 2.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: (times collect: #key) asBag equals: #(0 1 2 1 3 4) asBag.
	] ensure: [ self stopRunnersAndWorkers ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> timeoutWorker [
	"Demonstrate terminating a worker due to it timing out"
	<gtExample>
	<return: #SubclassResponsibility>
	| job timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore workerRegisteredSemaphore |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	taskFailedSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.
	remoteRunner managerStartupAndShutdown workerManager poolSize: 1.
	remoteRunner workerTimeout: 3 seconds.
	remoteRunner startLogging.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 30
		description: 'Worker didn''t register in time'.	"Create a set of tasks that never complete"
	timeoutTask := GtRrScriptTask script: 'Semaphore new wait'.
	timeoutTask taskTimeout: 1 minute.
	job := GtRrTasksJob new tasks: {timeoutTask}.
	job
		when: GtRrJobStartedAnnouncement
			do: [ jobStartedCount := jobStartedCount + 1.
				times add: 0 -> DateAndTime now ]
			for: self;
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				times add: 4 -> DateAndTime now.
				jobSemaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				times add: 5 -> DateAndTime now ]
			for: self;
		when: GtRrTaskStartedAnnouncement
			do: [ taskStartedCount := taskStartedCount + 1.
				times add: 1 -> DateAndTime now ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1.
				times add: 3 -> DateAndTime now ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ taskFailedCount := taskFailedCount + 1.
				times add: 2 -> DateAndTime now.
				taskFailedSemaphore signal ]
			for: self.
	remoteRunner submitJob: job.
	self
		waitOn: taskFailedSemaphore
		for: 30
		description: 'Task didn''t fail in time'.
	self
		waitOn: jobSemaphore
		for: 40
		description: 'Job didn''t complete in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: taskFailedCount equals: 1.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self
		assert: timeoutTask errorDetails errorMessage
		equals: 'Worker exceeded time limit' ] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> workerChangesFile [
	<gtExample>
	<return: #SubclassResponsibility>
	| semaphore changesFile task job |

	self setUp.
	remoteRunner := self simpleRunner.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	semaphore := Semaphore new.
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
		do: [ semaphore signal ]
		for: self.
	remoteRunner 
		when: GtRrJobCompletedAnnouncement 
		do: [ semaphore signal ]
		for: self.
	changesFile := FileReference
			newTempFilePrefix: 'workerChangesFile'
			suffix: '.ombu'.
	self writeChangesSyncFileTestMethodTo: changesFile.
	remoteRunner managerStartupAndShutdown workerManager
		addArguments: {'--changesFile'.
				changesFile fullName}.
	[ remoteRunner start.
	self
		waitOn: semaphore
		for: 30
		description: 'Worker didn''t register in time'.
	semaphore := Semaphore new.
	task := GtRrScriptTask
			script: 'self assert: GtRemoteRunnerExamples new changesSyncFileTestMethod equals: 1. true'.
	job := remoteRunner submitJob: task asJob.
	self
		waitOn: semaphore
		for: 20
		description: 'Job didn''t complete in time'.
	self deny: job hasErrors.
	self assert: job results first result ]
		ensure: [ remoteRunner ifNotNil: #stop.
			changesFile ifNotNil: #ensureDelete ]
]

{ #category : #examples }
GtRemoteRunnerProcessExamples >> workerDetails [
	"Demonstrate retrieving the remote worker's details"
	<gtExample>
	<return: #SubclassResponsibility>
	| registeredSemaphore worker |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	self setUp.
	registeredSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := self simpleRunner.
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | 
			worker := ann worker.
			registeredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: registeredSemaphore
		for: 20
		description: 'Worker didn''t register in time'.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	self
		assert: (worker attributes at: #workingDirectory)
		equals: FileLocator workingDirectory resolve fullName.
	self assert: (worker attributes at: #platform) equals: OSPlatform current name ]
		ensure: [ remoteRunner stop ].

	^ worker
]

{ #category : #'private - helpers' }
GtRemoteRunnerProcessExamples >> workerForRunner: aGtRemoteRunner [

	^ self subclassResponsibility
]

{ #category : #'private - helpers' }
GtRemoteRunnerProcessExamples >> writeChangesSyncFileTestMethodTo: changesFile [ 

	changesFile writeStreamDo: [ :stream | stream <<
'[OmEntry {
	#tags : {
		#author : ''AlistairGrant'',
		#time : DateAndTime [ ''2024-05-23T14:55:58.440449+02:00'' ],
		#prior : OmReference [ ''Pharo11-SNAPSHOT-64bit-aece1b5.30B6DC2CBE88'', ''10'' ],
		#self : OmReference [ ''Pharo11-SNAPSHOT-64bit-aece1b5.30B6DC2CBE89'', ''1'' ]
	},
	#content : EpMethodAddition {
		#method : RGMethodDefinition {
			#annotations : IdentityDictionary {
				#className : #GtRemoteRunnerExamples,
				#isMetaSide : false
			},
			#name : #changesSyncFileTestMethod,
			#protocol : #auto-generated,
			#sourceCode : ''changesSyncFileTestMethod\r\r\t^ 1'',
			#stamp : '''',
			#package : #RemoteRunner
		}
	}
}
]
' ]
]
