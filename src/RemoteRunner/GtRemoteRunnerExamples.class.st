"
GtRemoteRunnerExamples demonstrates the use of GtRemoteRunner in various scenarios.

Note: Pharo appears to have problems when listening on a socket for connections, and then quickly closing and opening the socket again.  To avoid these, a different port is used in each example.
"
Class {
	#name : #GtRemoteRunnerExamples,
	#superclass : #Object,
	#traits : 'TAssertable + TGtRrExampleHelp',
	#classTraits : 'TAssertable classTrait + TGtRrExampleHelp classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersTaskFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"
	<gtExample>
	| remoteRunner workers job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |

	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.
	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	tasks add: (GtRrExampleValueTask new
			value: 'error1';
			setError).
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement 
			do: [ taskCompletedCount := taskCompletedCount + 1 ];
		when: GtRrTaskFailedAnnouncement 
			do: [ taskFailedCount := taskFailedCount + 1 ].
	remoteRunner submitJob: job.

	workers := (1 to: 2) collect: [ :i |
		GtRrInImageWorker new
			remoteRunner: remoteRunner;
			start ].

	self waitOn: semaphore for: 10 
		description: 'Job never completed'.
	self assert: job results size equals: 6.
	self assert: taskCompletedCount equals: 5.
	self assert: taskFailedCount equals: 1.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersWorkerFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"
	<gtExample>
	| remoteRunner workers job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |

	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.

	workers := (1 to: 2) collect: [ :i |
		GtRrInImageWorker new
			remoteRunner: remoteRunner;
			start ].

	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	tasks add: (GtRrExampleValueTask new
			value: 'error1';
			setError).
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement 
			do: [ taskCompletedCount := taskCompletedCount + 1 ];
		when: GtRrTaskFailedAnnouncement 
			do: [ taskFailedCount := taskFailedCount + 1 ].
	remoteRunner submitJob: job.

	self waitOn: semaphore for: 10
		description: 'Job never completed'.
	self assert: job results size equals: 6.
	self assert: taskCompletedCount equals: 5.
	self assert: taskFailedCount equals: 1.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> controlChannelPing [
	"Demonstrate the ping operation using the worker's control channel"
	<gtExample>
	| remoteRunner controlChannelSemaphore worker |

	controlChannelSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: 7089.
	remoteRunner managerStartupAndShutdown 
		poolSize: 1;
		connectionStrategyId: #single.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerControlChannelRegisteredAnnouncement do: [ :ann | 
		worker := ann worker.
		controlChannelSemaphore signal ].
	remoteRunner start.
	[ self waitOn: controlChannelSemaphore for: 20
		description: 'Control channel didn''t register in time'.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	self
		assert: worker commandPing
		equals: #ping.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	] ensure: [ remoteRunner stop ].

	^ worker
]

{ #category : #examples }
GtRemoteRunnerExamples >> getNextTaskFor [
	"Demonstrate getting the next task for a worker from a Remote Runner.
	Tasks are created with a test constraint with a boolean value."
	<gtExample>
	| job tasks remoteRunner evenWorker oddWorker evenTasks oddTasks |

	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i;
			constraint: (GtRrEqualsConstraint attribute: #testConstraint value: i even) ].
	job := GtRrTasksJob new tasks: tasks.
	evenWorker := GtRrFutureWorkerTask new connection: 
		(GtRrWorkerConnection new details: { #testConstraint -> true } asDictionary).
	oddWorker := GtRrFutureWorkerTask new connection: 
		(GtRrWorkerConnection new details: { #testConstraint -> false } asDictionary).
	remoteRunner := GtRemoteRunner new.
	"The remote runner has enough state to run this example without being started"
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
	| remoteRunner job jobs completingTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new port: 7092.
	remoteRunner managerStartupAndShutdown poolSize: 2.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	jobs := (1 to: 2) collect: [  :i |
		completingTask := GtRrScriptTask script: '#done'.
		job := GtRrTasksJob new tasks: { completingTask }.
		job
			when: GtRrJobStartedAnnouncement do: 
				[ jobStartedCount := jobStartedCount + 1 ];
			when: GtRrJobCompletedAnnouncement do: 
				[ jobCompletedCount := jobCompletedCount + 1.
				jobSemaphore signal ];
			when: GtRrJobCancelledAnnouncement do: 
				[ jobCompletedCount := jobCompletedCount + 1 ];
			when: GtRrTaskStartedAnnouncement do: 
				[ taskStartedCount := taskStartedCount + 1 ];
			when: GtRrTaskCompletedAnnouncement do: 
				[ taskCompletedCount := taskCompletedCount + 1 ];
			when: GtRrTaskFailedAnnouncement do: 
				[ taskFailedCount := taskFailedCount + 1 ].
		job ].
	jobs do: [ :aJob | remoteRunner submitJob: aJob ].
	2 timesRepeat: [ self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time' ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 2.
	self assert: jobStartedCount equals: 2.
	self assert: taskCompletedCount equals: 2.
	self assert: taskFailedCount equals: 0.
	self assert: taskStartedCount equals: 2.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> multipleJobsSimultaneously [
	"Demonstrate executing multiple jobs started simultaneously"
	<gtExample>

	| remoteRunner job jobs semaphore workerConnections retryCount currentTask workerRegisteredSemaphore |

	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new port: 7084.
	"This example relies on the control channel, so force a single connection."
	remoteRunner managerStartupAndShutdown 
		poolSize: 2;
		connectionStrategyId: #single.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	jobs := (1 to: 2) collect: [  :i |
		job := GtRrJob script: 'Semaphore new wait'.
		job when: GtRrTaskStartedAnnouncement do: [ semaphore signal ].
		job ].
	jobs do: [ :aJob | remoteRunner submitJob: aJob ].
	2 timesRepeat: [ self waitOn: semaphore for: 10 description: 'Job didn''t start in time' ].

	workerConnections := remoteRunner registeredWorkers values.
	workerConnections do: [ :workerConnection |
		500 milliSeconds wait.
		retryCount := 10.
		[ currentTask := workerConnection commandCurrentTaskContextId.
		retryCount := retryCount - 1.
		currentTask isNil and: [ retryCount > 0 ] ] whileTrue.
		currentTask ifNil:
			[ self error: 'Task never started on worker' ] ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 2.
	self assert: remoteRunner currentlyExecutingTasks size equals: 2.
	self assert: remoteRunner taskQueue size equals: 0.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> simpleTask [
	"Demonstrate executing a simple task"
	<gtExample>
	| remoteRunner job completingTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7091.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	completingTask := GtRrScriptTask script: '#done'.
	job := GtRrTasksJob new tasks: { completingTask }.
	job
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1.
			times add: 0 -> DateAndTime now. ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 4 -> DateAndTime now.
			jobSemaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 5 -> DateAndTime now ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1.
			times add: 1 -> DateAndTime now ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1.
			times add: 3 -> DateAndTime now. ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1.
			times add: 2 -> DateAndTime now. ].
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time'.

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
	self assert: job results first result equals: #done.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> simpleTestTask [
	"Demonstrate executing a simple test task"
	<gtExample>
	| remoteRunner job taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7093.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	job := GtRrTestsJob new testNames: { #GtRrSampleTest -> #testPass }.
	job
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1.
			times add: 0 -> DateAndTime now. ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 4 -> DateAndTime now.
			jobSemaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 5 -> DateAndTime now ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1.
			times add: 1 -> DateAndTime now ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1.
			times add: 3 -> DateAndTime now. ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1.
			times add: 2 -> DateAndTime now. ].
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time'.

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
	self assert: (times collect: #key) asArray equals: #(0 1 3 4).
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> terminateStartedJobWithControlChannel [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated"
	<gtExample>
	| remoteRunner job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount times workerConnection currentTask retryCount workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new 
		port: 7084;
		startLogging.
	"This example relies on the control channel, so force a single connection."
	remoteRunner managerStartupAndShutdown 
		poolSize: 1;
		connectionStrategyId: #single.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	"Create a set of tasks that never complete"
	tasks := (1 to: 3) collect: [ :i |
		GtRrScriptTask script: 'Semaphore new wait' ].
	job := GtRrTasksJob new tasks: tasks.
	job
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1.
			times add: 0 -> DateAndTime now. ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 4 -> DateAndTime now.
			semaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 5 -> DateAndTime now.
			semaphore signal ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1.
			times add: 1 -> DateAndTime now.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1.
			times add: 3 -> DateAndTime now. ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1.
			times add: 2 -> DateAndTime now ].

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
	self assert: remoteRunner currentlyExecutingTasks size equals: 1.
	self assert: remoteRunner taskQueue size equals: 2.

	remoteRunner terminateJobId: job id.
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
GtRemoteRunnerExamples >> terminateStartedJobWithoutControlChannel [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated"
	<gtExample>
	| remoteRunner job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount waitForTaskCompletion taskWaitTime workerRegisteredSemaphore |

	"Waiting for the task to complete is slow and may fail if the processor is very busy,
	so this is normally only set true for manual testing."
	waitForTaskCompletion := false.
	taskWaitTime := 15. "seconds"
	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new 
		port: 7084;
		startLogging.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
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
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1 ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1 ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1 ].

	remoteRunner submitJob: job.
	self waitOn: semaphore for: 10 description: 'Task didn''t start in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 1.
	self assert: remoteRunner taskQueue size equals: 2.

	remoteRunner terminateJobId: job id.
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
GtRemoteRunnerExamples >> timeoutJob [
	"Demonstrate terminating a job due to it timing out"
	<gtExample>
	| remoteRunner job tasks taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	remoteRunner := GtRemoteRunner new port: 7087.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	"Create a set of tasks that never complete"
	tasks := (1 to: 3) collect: [ :i |
		GtRrScriptTask script: 'Semaphore new wait' ] as: OrderedCollection.
	job := GtRrTasksJob new
		tasks: tasks;
		jobTimeout: 5 seconds.
	job
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1. ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			jobSemaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1. ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1. ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1. ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1. ].
	remoteRunner submitJob: job.
	self waitOn: jobSemaphore for: 10 description: 'Job didn''t complete in time'.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner taskQueue size equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: taskFailedCount equals: 3.
	self assert: (taskStartedCount between: 1 and: 3)
		description: [ 'Unexpected taskStartedCount: ', taskStartedCount asString ].
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: job errorDetails errorMessage equals: 'Job exceeded time limit'.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutTask [
	"Demonstrate terminating a task due to it timing out"
	<gtExample>
	| remoteRunner job completingTask timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	taskFailedSemaphore := Semaphore new.
	workerRegisteredSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7088.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	self assert: remoteRunner workerTimeout > 1 minute.
	remoteRunner startLogging.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	"Create a task that never completes"
	timeoutTask := GtRrScriptTask script: 'Semaphore new wait'.
	timeoutTask taskTimeout: 200 milliSeconds.
	completingTask := GtRrScriptTask script: '#done'.
	job := GtRrTasksJob new
		tasks: { timeoutTask. completingTask }.
	job
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1.
			times add: 0 -> DateAndTime now. ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 4 -> DateAndTime now.
			jobSemaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 5 -> DateAndTime now ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1.
			times add: 1 -> DateAndTime now ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1.
			times add: 3 -> DateAndTime now. ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1.
			times add: 2 -> DateAndTime now.
			taskFailedSemaphore signal. ].
	remoteRunner submitJob: job.
	"When the task has failed, trigger the watchdog to start a new worker, which will run the second task"
	self waitOn: taskFailedSemaphore for: 10 description: 'Task didn''t fail in time'.
	[ "Give the process time to die and be registered by the subprocess.
	If this isn't enough time, it will be caught on the next cycle (just take longer)."
		2 seconds wait.
		remoteRunner managerStartupAndShutdown signalWatchdog ] fork.
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
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutWorker [
	"Demonstrate terminating a worker due to it timing out"
	<gtExample>
	| remoteRunner job timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore workerRegisteredSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	workerRegisteredSemaphore := Semaphore new.
	taskFailedSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7085.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner workerTimeout: 3 seconds.
	remoteRunner startLogging.
	"Worker processes can be slow to start up if the machine is busy or the image is large (multi GB).
	Wait for the worker to register before proceeding with tests."
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		workerRegisteredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: workerRegisteredSemaphore for: 20
		description: 'Worker didn''t register in time'.
	"Create a set of tasks that never complete"
	timeoutTask := GtRrScriptTask script: 'Semaphore new wait'.
	timeoutTask taskTimeout: 1 minute.
	job := GtRrTasksJob new tasks: { timeoutTask. }.
	job
		when: GtRrJobStartedAnnouncement do: 
			[ jobStartedCount := jobStartedCount + 1.
			times add: 0 -> DateAndTime now. ];
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 4 -> DateAndTime now.
			jobSemaphore signal ];
		when: GtRrJobCancelledAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			times add: 5 -> DateAndTime now ];
		when: GtRrTaskStartedAnnouncement do: 
			[ taskStartedCount := taskStartedCount + 1.
			times add: 1 -> DateAndTime now ];
		when: GtRrTaskCompletedAnnouncement do: 
			[ taskCompletedCount := taskCompletedCount + 1.
			times add: 3 -> DateAndTime now. ];
		when: GtRrTaskFailedAnnouncement do: 
			[ taskFailedCount := taskFailedCount + 1.
			times add: 2 -> DateAndTime now.
			taskFailedSemaphore signal. ].
	remoteRunner submitJob: job.
	self waitOn: taskFailedSemaphore for: 10 description: 'Task didn''t fail in time'.
	self waitOn: jobSemaphore for: 40 description: 'Job didn''t complete in time'.

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
	self assert: timeoutTask errorDetails errorMessage equals: 'Worker exceeded time limit'.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> workerDetails [
	"Demonstrate retrieving the remote worker's details"
	<gtExample>
	| remoteRunner registeredSemaphore worker |

	registeredSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: 7083.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		worker := ann worker.
		registeredSemaphore signal ].
	remoteRunner start.
	[ self waitOn: registeredSemaphore for: 20 description: 'Worker didn''t register in time'.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	self
		assert: (worker details at: #workingDirectory)
		equals: FileLocator workingDirectory resolve fullName.
	self 
		assert: (worker details at: #platform)
		equals: OSPlatform current name.
	] ensure: [ remoteRunner stop ].

	^ worker
]
