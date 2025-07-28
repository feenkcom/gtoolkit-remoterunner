"
GtRemoteRunnerExamples demonstrates the use of GtRemoteRunner in various scenarios.

Note: Pharo appears to have problems when listening on a socket for connections, and then quickly closing and opening the socket again.  To avoid these, a different port is used in each example.
"
Class {
	#name : #GtRemoteRunnerExamples,
	#superclass : #GtRemoteRunnerProcessExamples,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersTaskFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"

	<gtExample>
	<return: #GtRrTasksJob>
	| job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |
	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: #none.
	tasks := (1 to: 5)
			collect: [ :i | GtRrExampleValueTask new value: i ]
			as: OrderedCollection.
	tasks
		add: (GtRrExampleValueTask new
				value: 'error1';
				setError).
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ taskFailedCount := taskFailedCount + 1 ]
			for: self.
	remoteRunner submitJob: job.

	[ workers := (1 to: 2)
			collect: [ :i | 
				GtRrInImageWorker new
					remoteRunner: remoteRunner;
					exceptionHandlingStrategy: GtRrTaskHeadlessExceptionStrategy new;
					start ].

	self
		waitOn: semaphore
		for: 10
		description: 'Job never completed'.
	self assert: job results size equals: 6.
	self assert: taskCompletedCount equals: 5.
	self assert: taskFailedCount equals: 1.
	self assert: jobCompletedCount equals: 1 ] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersWorkerFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"

	<gtExample>
	<return: #GtRrTasksJob>
	| job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |
	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.

	workers := (1 to: 2)
			collect: [ :i | 
				GtRrInImageWorker new
					remoteRunner: remoteRunner;
					exceptionHandlingStrategy: GtRrTaskHeadlessExceptionStrategy new;
					start ].

	tasks := (1 to: 5)
			collect: [ :i | GtRrExampleValueTask new value: i ]
			as: OrderedCollection.
	tasks
		add: (GtRrExampleValueTask new
				value: 'error1';
				setError).
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ taskFailedCount := taskFailedCount + 1 ]
			for: self.
	remoteRunner submitJob: job.

	self
		waitOn: semaphore
		for: 30
		description: 'Job didn''t complete in time'.
	self assert: job results size equals: 6.
	self assert: taskCompletedCount equals: 5.
	self assert: taskFailedCount equals: 1.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> getNextTaskFor [
	"Demonstrate getting the next task for a worker from a Remote Runner.
	Tasks are created with a test constraint with a boolean value."

	<gtExample>
	<return: #GtRrTasksJob>
	| job tasks evenWorker oddWorker evenTasks oddTasks |
	tasks := (1 to: 5)
			collect: [ :i | 
				GtRrExampleValueTask new
					value: i;
					constraint: (GtRrEqualsConstraint attribute: #testConstraint value: i even) ].
	job := GtRrTasksJob new tasks: tasks.
	evenWorker := GtRrFutureWorkerTask new
			connection: (GtRrWorkerConnection new details: {#testConstraint -> true} asDictionary).
	oddWorker := GtRrFutureWorkerTask new
			connection: (GtRrWorkerConnection new details: {#testConstraint -> false} asDictionary).
	remoteRunner := GtRemoteRunner new.	"The remote runner has enough state to run this example without being started"
	remoteRunner submitJob: job.
	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 5.

	evenTasks := OrderedCollection new.
	oddTasks := OrderedCollection new.
	evenTasks add: (remoteRunner getNextTaskFor: evenWorker).
	oddTasks add: (remoteRunner getNextTaskFor: oddWorker).
	oddTasks add: (remoteRunner getNextTaskFor: oddWorker).
	evenTasks add: (remoteRunner getNextTaskFor: evenWorker).
	oddTasks add: (remoteRunner getNextTaskFor: oddWorker).

	self assert: evenTasks size equals: 2.
	self assert: oddTasks size equals: 3.
	self assert: evenTasks first task class equals: GtRrExampleValueTask.
	self assert: evenTasks first task constraint value equals: true.
	self assert: remoteRunner taskQueue size equals: 0.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> multipleJobs [
	"Demonstrate executing a multiple jobs"

	<gtExample>
	<return: #Error>
	| job jobs completingTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown
		autoRestart: false;
		poolSize: 2.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
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
	jobs := (1 to: 2)
			collect: [ :i | 
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
	2
		timesRepeat: [ self
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
	self assert: taskStartedCount equals: 2 ] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> multipleJobsSimultaneously [
	"Demonstrate executing multiple jobs started simultaneously"

	<gtExample>
	<return: #Error>
	| job jobs semaphore workerConnections retryCount currentTask workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown: GtRrLocalManagerStartupAndShutdown new.	"This example relies on the control channel, so force a single connection."
	remoteRunner managerStartupAndShutdown
		poolSize: 2;
		autoRestart: false;
		connectionStrategyId: #single.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
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
	jobs := (1 to: 2)
			collect: [ :i | 
				job := GtRrJob script: 'Semaphore new wait'.
				job tasks do: [ :task | task constraint: GtRrInImageConstraint new not ].
				job 
					when: GtRrTaskStartedAnnouncement 
					do: [ semaphore signal ]
					for: self.
				job ].
	jobs do: [ :aJob | remoteRunner submitJob: aJob ].
	2
		timesRepeat: [ self
				waitOn: semaphore
				for: 10
				description: 'Job didn''t start in time' ].

	workerConnections := remoteRunner registeredWorkers values.
	workerConnections
		do: [ :workerConnection | 
			500 milliSeconds wait.
			retryCount := 10.
			[ currentTask := workerConnection commandCurrentTaskContextId.
			retryCount := retryCount - 1.
			currentTask isNil and: [ retryCount > 0 ] ] whileTrue.
			currentTask ifNil: [ self error: 'Task never started on worker' ] ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 2.
	self assert: remoteRunner currentlyExecutingTasks size equals: 2.
	self assert: remoteRunner taskQueue size equals: 0 ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> registerObject [
	"Demonstrate registering a job and getting back the appropriate proxy."
	<gtExample>
	<noTest>
	| runner job proxy proc semaphore result |

	job := GtRrJob script: '42'.

	runner := GtRemoteRunner new port: #none.
	proxy := runner registerJob: job.
	self assert: proxy identicalTo: job.
	semaphore := Semaphore new.

	[ proc := GtRemoteRunner newHeadlessRunnerProcess run.
	runner := GtRemoteRunner headlessOnPort: 7042 codeSync: false.
	runner managerStartupAndShutdown startInImageWorker.
	proxy := runner registerJob: job.
	proxy announcer
		when: GtRrTaskCompletedAnnouncement
		do: [ semaphore signal ]
		for: self.
	self assert: proxy isLanguageLinkProxyObject
		description: 'Expected a proxy object back'.
	runner submitJob: proxy.
	self waitOn: semaphore for: 10 description:
		'Task didn''t complete'.
	result := proxy newCommandFactory
		<< 'self tasks first result';
		sendAndWait.
	self assert: result equals: 42. ]
			ensure: 
				[ self stopRunnersAndWorkers.
				proc ifNotNil: [ proc clearErrorBlock kill ].
				proc := nil. ].
]

{ #category : #'private - helpers' }
GtRemoteRunnerExamples >> simpleRunner [
	"Answer a started RemoteRunner.
	It is up to the caller to stop the runner (and thus the workers)."
	| newRemoteRunner  |

	newRemoteRunner := GtRemoteRunner new.
	newRemoteRunner managerStartupAndShutdown 
		autoRestart: false;
		poolSize: 1.

	self assert: newRemoteRunner taskQueue size equals: 0.
	self assert: newRemoteRunner currentlyExecutingJobs size equals: 0.
	self assert: newRemoteRunner currentlyExecutingTasks size equals: 0.
	^ newRemoteRunner
]

{ #category : #examples }
GtRemoteRunnerExamples >> simpleTask [
	"Demonstrate executing a simple task"

	<gtExample>
	<return: #GtRrTasksJob>
	| job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := self simpleRunner.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
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
	job := self simpleJob.
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
		for: 10
		description: 'Job didn''t complete in time'.

	self assert: remoteRunner taskQueue size equals: 0.
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
	self assert: job results first result equals: #done ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> simpleTestRetryTask [
	"Demonstrate retrying a task that 'crashes' the worker.
	This will take approximately 4 times the worker heartbeat timeout time to execute (3 or 4 minutes)."

	<gtExample>
	<return: #Error>
	| factory job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	GtRrSampleTest
		compile: 'testCrash
	Stdio stdout
		<< Time now printString;
		<< '' testCrash quitting image'';
		lf; flush.
	Smalltalk snapshot: false andQuit: true.'
		classified: #tests.
	remoteRunner := self simpleRunner.	"At least 4 workers are needed, 3 will fail on the bad task, the last will run all remaining tests"
	remoteRunner managerStartupAndShutdown poolSize: 4.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner
		startLogging;
		start.
	[ 4
		timesRepeat: [ self
				waitOn: workerRegisteredSemaphore
				for: 20
				description: 'Worker didn''t register in time' ].
	factory := GtRrChecksFactory new.
	factory
		addSUnitTestNames: {#GtRrSampleTest -> #testPass.
				#GtRrSampleTest -> #testCrash}.
	job := factory job.
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
	job tasks do: [ :task | task retryStrategy: GtRrTaskTestRetry new ].
	remoteRunner submitJob: job.
	self
		waitOn: jobSemaphore
		for: 240
		description: 'Job didn''t complete in time'.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: jobStartedCount equals: 1.
	self assert: jobCompletedCount equals: 1.
	self assert: taskStartedCount equals: 4.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 1.
	self assert: job state equals: #completed.
	self assert: job hasErrors ]
		ensure: [ remoteRunner stop.
			GtRrSampleTest removeSelector: #testCrash ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> simpleTestTask [
	"Demonstrate executing a simple test task"

	<gtExample>
	<return: #Error>
	| factory job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
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

{ #category : #examples }
GtRemoteRunnerExamples >> terminateStartedJobWithControlChannel [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated"

	<gtExample>
	<return: #Error>
	| job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount workerConnection currentTask retryCount workerRegisteredSemaphore notStarted |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new startLogging.	"This example relies on the control channel, so force a single connection."
	remoteRunner managerStartupAndShutdown
		poolSize: 1;
		autoRestart: false;
		connectionStrategyId: #single.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 20
		description: 'Worker didn''t register in time'.	"Create a set of tasks that never complete"
	tasks := (1 to: 3)
			collect: [ :i | GtRrScriptTask script: 'Semaphore new wait' ].
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobStartedAnnouncement
			do: [ jobStartedCount := jobStartedCount + 1 ]
			for: self;
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskStartedAnnouncement
			do: [ taskStartedCount := taskStartedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ taskFailedCount := taskFailedCount + 1 ]
			for: self.

	remoteRunner submitJob: job.
	self
		waitOn: semaphore
		for: 10
		description: 'Task didn''t start in time'.
	workerConnection := remoteRunner registeredWorkers anyOne.
	retryCount := 10.
	[ currentTask := workerConnection commandCurrentTaskContextId.
	retryCount := retryCount - 1.
	currentTask isNil and: [ retryCount > 0 ] ] whileTrue.
	currentTask ifNil: [ self error: 'Task never started on worker' ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 1.
	self assert: remoteRunner taskQueue size equals: 2.

	remoteRunner terminateJobId: job jobId.
	self
		waitOn: semaphore
		for: 10
		description: 'Job didn''t terminate in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	notStarted := tasks select: #isNotStarted.
	self assert: notStarted size + taskFailedCount equals: 3.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #cancelled.
	self assert: job hasErrors.
	self assert: (job results allSatisfy: [ :task | task hasErrors ]) ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> terminateStartedJobWithoutControlChannel [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated"

	<gtExample>
	<return: #Error>
	| job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount waitForTaskCompletion taskWaitTime workerRegisteredSemaphore notStarted |
	self ignoreWorkerExamples ifTrue: [ ^ self ].	"Waiting for the task to complete is slow and may fail if the processor is very busy,
	so this is normally only set true for manual testing."
	waitForTaskCompletion := false.
	taskWaitTime := 15.	"seconds"
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new startLogging.
	remoteRunner managerStartupAndShutdown
		autoRestart: false;
		poolSize: 1.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 20
		description: 'Worker didn''t register in time'.	"Create a set of tasks that never complete"
	tasks := (1 to: 3)
			collect: [ :i | 
				(GtRrScriptTask script: taskWaitTime asString , ' seconds wait')
					taskTimeout: 5 minutes;
					yourself ].
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobStartedAnnouncement
			do: [ jobStartedCount := jobStartedCount + 1 ]
			for: self;
		when: GtRrJobCompletedAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrJobCancelledAnnouncement
			do: [ jobCompletedCount := jobCompletedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskStartedAnnouncement
			do: [ taskStartedCount := taskStartedCount + 1.
				semaphore signal ]
			for: self;
		when: GtRrTaskCompletedAnnouncement
			do: [ taskCompletedCount := taskCompletedCount + 1 ]
			for: self;
		when: GtRrTaskFailedAnnouncement
			do: [ taskFailedCount := taskFailedCount + 1 ]
			for: self.

	remoteRunner submitJob: job.
	self
		waitOn: semaphore
		for: 10
		description: 'Task didn''t start in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 1.
	self assert: remoteRunner taskQueue size equals: 2.

	remoteRunner terminateJobId: job jobId.
	self
		waitOn: semaphore
		for: 10
		description: 'Job didn''t terminate in time'.

	waitForTaskCompletion
		ifTrue: [ (taskWaitTime + 5) seconds wait.	"After the task has completed on the worker it should become available again"
			self assert: remoteRunner availableWorkerCount equals: 1 ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	notStarted := tasks select: #isNotStarted.
	self assert: notStarted size + taskFailedCount equals: 3.
	self assert: taskStartedCount equals: 1.
	self assert: job state equals: #cancelled.
	self assert: job hasErrors.
	self assert: (job results allSatisfy: [ :task | task hasErrors ]) ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutJob [
	"Demonstrate terminating a job due to it timing out"

	<gtExample>
	<return: #Error>
	| job tasks failedTasks taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore notStarted |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := 0.
	failedTasks := OrderedCollection new.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown
		autoRestart: false;
		poolSize: 1.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
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
	notStarted := tasks select: #isNotStarted.
	self assert: notStarted size + failedTasks size equals: 3.
	self
		assert: (taskStartedCount between: 1 and: 3)
		description: [ 'Unexpected taskStartedCount: ' , taskStartedCount asString ].
	self assert: job state equals: #cancelled.
	self assert: job hasErrors.
	self assert: job errorDetails errorMessage equals: 'Job exceeded time limit' ]
		ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutTaskInImage [
	"Demonstrate terminating a task due to it timing out"

	<gtExample>
	<return: #GtRrTasksJob>
	| job completingTask timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount taskFailedSemaphore workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	taskFailedSemaphore := Semaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new
			startLogging;
			port: #none.
	self assert: remoteRunner workerTimeout > 1 minute.	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :ann | workerRegisteredSemaphore signal ]
		for: self.
	remoteRunner start.
	remoteRunner managerStartupAndShutdown startInImageWorker.
	[ self
		waitOn: workerRegisteredSemaphore
		for: 20
		description: 'Worker didn''t register in time'.	"Create a task that never completes"
	timeoutTask := GtRrScriptTask script: 'Semaphore new wait'.
	timeoutTask taskTimeout: 200 milliSeconds.
	completingTask := GtRrScriptTask script: '#done'.
	job := GtRrTasksJob new
			tasks: {timeoutTask.
					completingTask}.
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
			do: [ taskFailedCount := taskFailedCount + 1.
				taskFailedSemaphore signal ]
			for: self.
	remoteRunner submitJob: job.	"When the task has failed, trigger the watchdog to start a new worker, which will run the second task"
	self
		waitOn: taskFailedSemaphore
		for: 10
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
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 1.
	self assert: taskStartedCount equals: 2.
	self assert: job state equals: #completed.
	self assert: job hasErrors ] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutWorker [
	"Demonstrate terminating a worker due to it timing out"

	<gtExample>
	<return: #Error>
	| job timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore workerRegisteredSemaphore |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	taskFailedSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown
		autoRestart: false;
		poolSize: 1.
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
GtRemoteRunnerExamples >> workerChangesFile [
	<gtExample>
	<return: #Error>
	| settings semaphore args workerProcess changesFile logFile processBuilder task job rrIndex |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown
		autoRestart: false;
		poolSize: 0.
	semaphore := Semaphore new.
	remoteRunner 
		when: GtRrWorkerRegisteredAnnouncement 
		do: [ semaphore signal ]
		for: self.
	remoteRunner 
		when: GtRrJobCompletedAnnouncement 
		do: [ semaphore signal ]
		for: self.
	remoteRunner start.
	settings := LanguageLinkSettings pharoDefaultSettings.
	changesFile := FileReference
			newTempFilePrefix: 'workerChangesFile'
			suffix: '.ombu'.
	self writeChangesSyncFileTestMethodTo: changesFile.
	args := (GtRrWorkerManager new
			remoteRunner: remoteRunner;
			changesSync: true;
			remoteIpAddress: remoteRunner port asString)
			newWorkerLocalProcessArgumentsFor: settings.	"clap arguments must be grouped together prior to the global arguments"
	rrIndex := args indexOf: 'remoteRunnerWorker'.
	self
		assert: rrIndex > 0
		description: 'Unable to find remoteRunnerWorker argument'.
	args
		add: '--changesFile' beforeIndex: rrIndex + 1;
		add: changesFile fullName beforeIndex: rrIndex + 2.
	'workerLogs' asFileReference ensureCreateDirectory.
	logFile := 'workerLogs/workerChangesFile.log' asFileReference.
	processBuilder := GtExternalProcessBuilder new
			command: settings serverExecutable fullName;
			args: args;
			fileStdout: logFile;
			fileStderr: logFile;
			workingDirectory: settings workingDirectory resolve fullName.
	[ workerProcess := processBuilder createNativeCommand spawn.
	workerProcess terminateOnShutdown.
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
		ensure: [ workerProcess ifNotNil: #kill.
			remoteRunner ifNotNil: #stop.
			changesFile ifNotNil: #ensureDelete ]
]

{ #category : #examples }
GtRemoteRunnerExamples >> workerDetails [
	"Demonstrate retrieving the remote worker's details"

	<gtExample>
	<return: #Error>
	| registeredSemaphore worker |
	self ignoreWorkerExamples ifTrue: [ ^ self ].
	registeredSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown
		autoRestart: false;
		poolSize: 1.
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
		assert: (worker details at: #workingDirectory)
		equals: FileLocator workingDirectory resolve fullName.
	self assert: (worker details at: #platform) equals: OSPlatform current name ]
		ensure: [ remoteRunner stop ].

	^ worker
]

{ #category : #'private - helpers' }
GtRemoteRunnerExamples >> workerForRunner: aGtRemoteRunner [

	^ GtRrWorker serverSocketAddress: 'localhost:', aGtRemoteRunner port asString.
]
