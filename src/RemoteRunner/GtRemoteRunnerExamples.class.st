"
GtRemoteRunnerExamples demonstrates the use of GtRemoteRunner in various scenarios.

Note: Pharo appears to have problems when listening on a socket for connections, and then quickly closing and opening the socket again.  To avoid these, a different port is used in each example.
"
Class {
	#name : #GtRemoteRunnerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersTaskFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"
	<gtExample>
	<noTest>
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
	job := GtRrTasksJob new
		platforms: #(plat1 plat2);
		tasks: tasks.
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
			rrPlatform: 'plat', i asString;
			remoteRunner: remoteRunner;
			connection: PharoLinkServerConnection new;
			start ].

	semaphore wait.
	self assert: job results size equals: 12.
	self assert: taskCompletedCount equals: 10.
	self assert: taskFailedCount equals: 2.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> assignTasksToWorkersWorkerFirst [
	"Demonstrate assigning tasks to workers, with the tasks queued before the workers connect"
	<gtExample>
	<noTest>
	| remoteRunner workers job tasks taskCompletedCount taskFailedCount jobCompletedCount semaphore |

	jobCompletedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new.

	workers := (1 to: 2) collect: [ :i |
		GtRrInImageWorker new
			rrPlatform: 'plat', i asString;
			remoteRunner: remoteRunner;
			connection: PharoLinkServerConnection new;
			start ].

	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	tasks add: (GtRrExampleValueTask new
			value: 'error1';
			setError).
	job := GtRrTasksJob new
		platforms: #(plat1 plat2);
		tasks: tasks.
	job
		when: GtRrJobCompletedAnnouncement do: 
			[ jobCompletedCount := jobCompletedCount + 1.
			semaphore signal ];
		when: GtRrTaskCompletedAnnouncement 
			do: [ taskCompletedCount := taskCompletedCount + 1 ];
		when: GtRrTaskFailedAnnouncement 
			do: [ taskFailedCount := taskFailedCount + 1 ].
	remoteRunner submitJob: job.

	semaphore wait.
	self assert: job results size equals: 12.
	self assert: taskCompletedCount equals: 10.
	self assert: taskFailedCount equals: 2.
	self assert: jobCompletedCount equals: 1.

	workers do: #stop.
	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> controlChannelPing [
	"Demonstrate the ping operation using the worker's control channel"
	<gtExample>
	<noTest>
	| remoteRunner controlChannelSemaphore worker |

	controlChannelSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: 7089.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner when: GtRrWorkerControlChannelRegisteredAnnouncement do: [ :ann | 
		worker := ann worker.
		controlChannelSemaphore signal ].
	remoteRunner start.
	[ controlChannelSemaphore wait.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	self
		assert: worker commandPing
		equals: #ping.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	] ensure: [ remoteRunner stop ].

	^ worker
]

{ #category : #examples }
GtRemoteRunnerExamples >> controlChannelQuitSmalltalk [
	"Demonstrate the ping operation using the worker's control channel"
	"This currently locks the image.  To be fixed (or removed)"
	"<gtExample>"
	| remoteRunner controlChannelSemaphore worker |

	controlChannelSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: 7090.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner when: GtRrWorkerControlChannelRegisteredAnnouncement do: [ :ann | 
		worker := ann worker.
		controlChannelSemaphore signal ].
	remoteRunner when: GtRrWorkerUnregisteredAnnouncement do: [ :ann | 
		controlChannelSemaphore signal ].
	remoteRunner start.
	[ controlChannelSemaphore wait.
	self assert: remoteRunner registeredWorkerCount equals: 1.
	worker commandQuitSmalltalk.
	controlChannelSemaphore wait.
	self assert: remoteRunner registeredWorkerCount equals: 0.
	] ensure: [ remoteRunner stop ].

	^ worker
]

{ #category : #examples }
GtRemoteRunnerExamples >> getNextTaskFor [
	"Demonstrate getting the next task for a given platform from a Remote Runner"
	<gtExample>
	<noTest>
	| job tasks taskIds remoteRunner firstTask plat1Tasks plat2Tasks |

	tasks := (1 to: 5) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	taskIds := tasks collect: #taskId as: Set.
	job := GtRrTasksJob new
		platforms: #(plat1 plat2);
		tasks: tasks.
	remoteRunner := GtRemoteRunner new.
	"The remote runner has enough state to run this example without being started"
	remoteRunner startJob: job.
	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	firstTask := (remoteRunner currentlyExecutingJobs anyOne atPlatform: #plat2) pendingTasks itemArray first.

	plat1Tasks := OrderedCollection new.
	plat2Tasks := OrderedCollection new.
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).
	plat1Tasks add: (remoteRunner getNextTaskFor: #plat1).
	plat2Tasks add: (remoteRunner getNextTaskFor: #plat2).

	self assert: plat1Tasks first task class equals: GtRrExampleValueTask.
	self assert: (plat1Tasks collect: #taskId as: Set) equals: taskIds.
	self assert: (plat2Tasks collect: #taskId as: Set) equals: taskIds.
	self assert: (remoteRunner currentlyExecutingJobs anyOne atPlatform: #plat1) pendingTasks isEmpty.
	self assert: (remoteRunner currentlyExecutingJobs anyOne atPlatform: #plat2) pendingTasks isEmpty.
]

{ #category : #examples }
GtRemoteRunnerExamples >> handleWorkerDisconnection [
	"Demonstrate the runner handling worker disconnection"
	<gtExample>
	<noTest>
	| runner worker job startSemaphore endSemaphore retry |

	runner := GtRemoteRunner new
		port: 7086;
		managerStartupAndShutdown: GtRrManualManagerStartupAndShutdown new;
		startLogging;
		start.
	[ worker := GtRrWorker serverSocketAddress: 'localhost:7086'.
	worker start.
	startSemaphore := Semaphore new.
	endSemaphore := Semaphore new.
	job := GtRrTasksJob new
		tasks: { GtRrScriptTask script: 'Semaphore new wait' }.
	job
		when: GtRrJobStartedAnnouncement
			do: [ startSemaphore signal ];
		when: GtRrJobCompletedAnnouncement
			do: [ endSemaphore signal ].

	retry := 50.
	[ retry > 0 and: [ runner availableWorkerCount = 0 ] ] whileTrue:
		[ 500 milliSeconds wait ].
	retry = 0 ifTrue:
		[ self error: 'Worker didn''t connect' ].
	self assert: runner state equals: #idle.
	self assert: runner registeredWorkerCount equals: 1.
	self assert: runner availableWorkerCount equals: 1.

	runner submitJob: job.

	startSemaphore wait.
	self assert: runner state equals: #busy.
	self assert: runner registeredWorkerCount equals: 1.
	self assert: runner availableWorkerCount equals: 0.
	self assert: job state equals: #started.
	worker stop.
	endSemaphore wait.
	self assert: runner state equals: #idle.
	self assert: runner registeredWorkerCount equals: 0.
	self assert: runner availableWorkerCount equals: 0.
	self assert: job state equals: #completed.
	self assert: job hasErrors.

	] ensure:
		[ worker stop.
		runner stop ].
]

{ #category : #examples }
GtRemoteRunnerExamples >> multipleJobs [
	"Demonstrate executing a multiple jobs"
	<gtExample>
	<noTest>
	| remoteRunner job jobs completingTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: 7092.
	remoteRunner start.
	[ 
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
	2 timesRepeat: [ jobSemaphore wait ].

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.
	self assert: jobCompletedCount equals: 2.
	self assert: jobStartedCount equals: 2.
	self assert: taskCompletedCount equals: 2.
	self assert: taskFailedCount equals: 0.
	self assert: taskStartedCount equals: 2.
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> simpleTask [
	"Demonstrate executing a simple task"
	<gtExample>
	<noTest>
	| remoteRunner job completingTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7091.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner start.
	[ 
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
	jobSemaphore wait.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.
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
GtRemoteRunnerExamples >> terminateNotStartedJob [
	"Terminate a job that hasn't been started, ensuring that job is marked cancelled and has no results"
	<gtExample>
	<noTest>
	| remoteRunner job tasks |

	remoteRunner := GtRemoteRunner new.
	"Submit an empty job.  Since there are no workers, it will become the currently executing job, leaving the next not started"
	remoteRunner submitJob: (GtRrTasksJob new tasks: #()).

	tasks := (1 to: 3) collect: [ :i |
		GtRrExampleValueTask new
			value: i ] as: OrderedCollection.
	job := GtRrTasksJob new
		tasks: tasks.
	remoteRunner submitJob: job.

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 1.

	remoteRunner terminateJobId: job id.

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.

	self assert: job state equals: #cancelled.
	self assert: job results isEmpty.

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> terminateStartedJob [
	"Terminate a job that has been started, ensuring that all tasks have been marked as terminated (not yet started)"
	<gtExample>
	<noTest>
	| remoteRunner job tasks taskFailedCount taskCompletedCount jobCompletedCount semaphore jobStartedCount taskStartedCount times |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	semaphore := GtMutualExclusionSemaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7084.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner start.
	[ 
	"Create a set of tasks that never complete"
	tasks := (1 to: 3) collect: [ :i |
		GtRrScriptTask script: 'Semaphore new wait' ] as: OrderedCollection.
	job := GtRrTasksJob new
		tasks: tasks.
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
	semaphore wait.

	self assert: remoteRunner currentlyExecutingJobs size equals: 1.
	self assert: remoteRunner currentlyExecutingTasks size equals: 1.
	self assert: remoteRunner pendingJobCount equals: 0.

	remoteRunner terminateJobId: job id.
	semaphore wait.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.
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
GtRemoteRunnerExamples >> timeoutJob [
	"Demonstrate terminating a job due to it timing out"
	<gtExample>
	<noTest>
	| remoteRunner job tasks taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7087.
	remoteRunner start.
	[ 
	"Create a set of tasks that never complete"
	tasks := (1 to: 3) collect: [ :i |
		GtRrScriptTask script: 'Semaphore new wait' ] as: OrderedCollection.
	job := GtRrTasksJob new
		tasks: tasks;
		jobTimeout: 5 seconds.
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
			times add: 2 -> DateAndTime now ].
	remoteRunner submitJob: job.
	jobSemaphore wait.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 0.
	self assert: taskFailedCount equals: 3.
	self assert: taskStartedCount equals: 2.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: job errorDetails errorMessage equals: 'Job exceeded time limit'.
	self assert: (times collect: #key) asArray equals: #(0 1 1 2 2 2 4).
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutTask [
	"Demonstrate terminating a task due to it timing out"
	<gtExample>
	<noTest>
	"This is a copy of timeoutWorker, waiting on proper task termination to be integrated"
	| remoteRunner job completingTask timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	taskFailedSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7088.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	self assert: remoteRunner jobTimeout > 1 minute.
	self assert: remoteRunner workerTimeout > 1 minute.
	remoteRunner start.
	[ 
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
	taskFailedSemaphore wait.
	[ "Give the process time to die and be registered by the subprocess.
	If this isn't enough time, it will be caught on the next cycle (just take longer)."
		2 seconds wait.
		remoteRunner managerStartupAndShutdown signalWatchdog ] fork.
	jobSemaphore wait.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 1.
	self assert: taskStartedCount equals: 2.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: (times collect: #key) asArray equals: #(0 1 2 1 3 4).
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> timeoutWorker [
	"Demonstrate terminating a worker due to it timing out"
	<gtExample>
	<noTest>
	| remoteRunner job completingTask timeoutTask taskFailedCount taskCompletedCount jobCompletedCount jobSemaphore jobStartedCount taskStartedCount times taskFailedSemaphore |

	jobStartedCount := jobCompletedCount := taskStartedCount := taskCompletedCount := taskFailedCount := 0.
	jobSemaphore := GtMutualExclusionSemaphore new.
	taskFailedSemaphore := Semaphore new.
	times := OrderedCollection new.
	remoteRunner := GtRemoteRunner new port: 7085.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner workerTimeout: 3 seconds.
	self assert: remoteRunner jobTimeout > 1 minute.
	remoteRunner start.
	[ 
	"Create a set of tasks that never complete"
	timeoutTask := GtRrScriptTask script: 'Semaphore new wait'.
	timeoutTask taskTimeout: 1 minute.
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
	taskFailedSemaphore wait.
	[ "Give the process time to die and be registered by the subprocess"
		2 seconds wait.
		remoteRunner managerStartupAndShutdown signalWatchdog ] fork.
	jobSemaphore wait.

	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	self assert: remoteRunner pendingJobCount equals: 0.
	self assert: jobCompletedCount equals: 1.
	self assert: jobStartedCount equals: 1.
	self assert: taskCompletedCount equals: 1.
	self assert: taskFailedCount equals: 1.
	self assert: taskStartedCount equals: 2.
	self assert: job state equals: #completed.
	self assert: job hasErrors.
	self assert: (times collect: #key) asArray equals: #(0 1 2 1 3 4).
	] ensure: [ remoteRunner stop ].

	^ job
]

{ #category : #examples }
GtRemoteRunnerExamples >> workerDetails [
	"Demonstrate retrieving the remote worker's details"
	<gtExample>
	<noTest>
	| remoteRunner registeredSemaphore worker |

	registeredSemaphore := GtMutualExclusionSemaphore new.
	remoteRunner := GtRemoteRunner new port: 7091.
	remoteRunner managerStartupAndShutdown poolSize: 1.
	remoteRunner when: GtRrWorkerRegisteredAnnouncement do: [ :ann | 
		worker := ann worker.
		registeredSemaphore signal ].
	remoteRunner start.
	[ registeredSemaphore wait.
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
