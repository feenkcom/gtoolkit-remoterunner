"
GtRemoteRunner manages the running of tasks, such as tests or examples, in a distributed system across one or more machines.

The original scenarios used to design the  system were:

- Individual developer: A developer is working in an image and wants to run tasks in one or more worker images on their local machine.
- Internal team: A team of developers are working, and pool their worker images for common use.
- CI: An automated system runs all tasks on all supported platforms, e.g. linux, mac, windows, on each commit.

Features of the system (mostly not yet implemented) include:

- Handling of the scenarios described above.
- Support for running tests / examples across multiple platforms.
  - Initially a platform is an OS / hardware combination, but as it is just a name, it can be any set of desired attributes.
- If the current job has any failures or errors the next job can be started prior to the current job completing, maximising resource (worker) usage.
- Timeouts on:
  - Tasks
  - Workers
  - Jobs
### Main Components

The main components of the system are:

- GtRemoteRunner provides the primary interface to the system and the main control.
- A {{gtClass:GtRrWorker}} is created for each client image that will run tests or examples.
- A {{gtClass:GtRrJob}} is submitted by users for each collection or tests or examples to be executed.  The user will be notified of the progress of the job.
- {{gtClass:GtRrTaskAllocator}} is responsible for taking all the tests / examples in a job and ordering and grouping them for equitable distribution amongst the workers.
### Phases

The following phases are defined as part of the system.  Each of these phases is pluggable, so can be customised for individual scenarios:

- Manager Startup: this is run once when the manager starts.  It may be used to start worker machines, etc.
- Job Startup: this may include starting the worker images on the worker machines.
- Job Execution: the phase where tests / examples are being handed out to the workers.
- Job Shutdown: this may include stopping the worker images on the worker machines.
- Manager shutdown: this is run once when the manager is stopped.  It may be used to shut down worker machines, etc.

The worker images are assumed to be up to date when the Job Execution phase is run.

### Implementation Points

`sharedAccess` is a mutual exclusion semaphore used to control access to: `availableWorkers`, `jobQueue`, `currentlyExecutingJobs`, `taskPromises` and `registeredWorkers`.

### Futures

- Retry tasks if the worker disappears.
  - The retry is on the assumption that the worker crashed from an external cause, or the network was lost.
  - Only 1 or 2 retries should be attempted in case it is the test that is causing the crash.
"
Class {
	#name : #GtRemoteRunner,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'port',
		'server',
		'jobStartupAndShutdown',
		'managerStartupAndShutdown',
		'availableWorkers',
		'jobQueue',
		'currentlyExecutingJobs',
		'currentlyExecutingTasks',
		'sharedAccess',
		'registeredWorkers',
		'taskTimeout',
		'workerTimeout',
		'jobTimeout',
		'timeoutManager',
		'announcer',
		'runnerStats',
		'log'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRemoteRunner >> addCurrentlyExecutingTask: aGtRrTaskContext [
	"Add the supplied task to the collection of currently executing tasks.
	Must be called within sharedAccess."

	currentlyExecutingTasks at: aGtRrTaskContext taskContextId put: aGtRrTaskContext
]

{ #category : #announcer }
GtRemoteRunner >> announceAndLog: aBeaconSignal [
	"Announce the supplied signal to the receiver's announcer and then emit the signal for logging"

	self announce: aBeaconSignal.
	aBeaconSignal emit.
]

{ #category : #announcer }
GtRemoteRunner >> announcer [

	^ announcer
]

{ #category : #private }
GtRemoteRunner >> assignTasksToWorkers [
	"Assign tasks to any available workers.
	Must be called within sharedAccess."
	| taskContext busyWorkers |

	(availableWorkers isEmpty or: [ currentlyExecutingJobs isEmpty ]) ifTrue: [ ^ self ].

	busyWorkers := OrderedCollection new.
	"Loop around assigning tasks to workers until there either no more workers or no more tasks available"
	availableWorkers do: [ :workerFuture |
		taskContext := self getNextTaskFor: workerFuture platform.
		taskContext ifNotNil:
			[ runnerStats incrementTaskCount.
			taskContext
				workerFuture: workerFuture;
				markTaskStarted.
			"Set the task in the workerFuture, this will signal the workerFuture's semaphore, waking up the workerFuture's process"
			workerFuture taskContext: taskContext.
			busyWorkers add: workerFuture.
			timeoutManager addContext: taskContext ] ].
	availableWorkers removeAll: busyWorkers.
]

{ #category : #accessing }
GtRemoteRunner >> availableWorkerCount [

	^ sharedAccess critical: [ availableWorkers size ]
]

{ #category : #private }
GtRemoteRunner >> checkJobCompleted: aGtRrContext [
	"After each task has been completed, check if the job has finished, and if so, signal it.
	Must be called within sharedAccess."
	| jobContext |

	jobContext := aGtRrContext jobContext.
	jobContext isFinished ifFalse: [ ^ self ].

	jobStartupAndShutdown shutdownJob: jobContext.

]

{ #category : #private }
GtRemoteRunner >> currentlyExecutingJobs [
	"Private: for testing internal state only"

	^ currentlyExecutingJobs
]

{ #category : #private }
GtRemoteRunner >> currentlyExecutingTasks [
	"Private: for testing internal state only"

	^ currentlyExecutingTasks
]

{ #category : #accessing }
GtRemoteRunner >> debugMode [
	"Answer a boolean indicating whether debug logging should be started.
	Always true during development.  Settings TBD."

	^ true.
]

{ #category : #accessing }
GtRemoteRunner >> defaultJobTimeout [

	^ (self taskTimeout asMilliSeconds * 3) milliSeconds
]

{ #category : #accessing }
GtRemoteRunner >> defaultTaskTimeout [

	^ 5 minutes
]

{ #category : #accessing }
GtRemoteRunner >> defaultWorkerTimeout [

	^ self taskTimeout + 1 minute
]

{ #category : #private }
GtRemoteRunner >> getNextTaskFor: aPlatform [
	"Answer the next task for the given platform, or nil.
	Must be called within sharedAccess."
	<return: #GtRrTaskContext>
	| platformContext taskContext |

	currentlyExecutingJobs valuesDo: [ :jobContext |
		platformContext := jobContext atPlatform: aPlatform.
		taskContext := platformContext nextTaskOrNil.
		taskContext ifNotNil: [ ^ taskContext ] ].
	^ nil

]

{ #category : #ui }
GtRemoteRunner >> gtExecutingJobsFor: aView [

	<gtView>
	^ aView list
		  title: 'Executing Jobs';
		  priority: 20;
		  items: [ sharedAccess critical: [ currentlyExecutingJobs values ] ];
		  send: [ :item | item job ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtExecutingTasksFor: aView [

	<gtView>
	^ aView list
		  title: 'Executing Tasks';
		  priority: 20;
		  items: [ 
			  sharedAccess critical: [ currentlyExecutingTasks values ] ];
		  send: [ :item | item task ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtJobQueueFor: aView [
	<gtView>

	^ aView list
		  title: 'Job Queue';
		  priority: 20;
		  items: [ jobQueue itemArray ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item third ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
			actionUpdateButton 
]

{ #category : #ui }
GtRemoteRunner >> gtWorkersFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Registered Workers';
		  priority: 50;
		  items: [ registeredWorkers values ];
		  column: 'IP Address' text: [ :item | 
			String streamContents: [ :stream |
				item remoteAddress do: [ :byte |
					stream print: byte ]
				separatedBy: [ stream nextPut: $. ] ] ];
		  column: 'Platform' text: [ :item | item platform ];
		  actionUpdateButton
]

{ #category : #'api - logger' }
GtRemoteRunner >> hasLog [
	"Answer a boolean indicating if the receiver has an active log available"

	^ log isNotNil
]

{ #category : #initialization }
GtRemoteRunner >> initialize [

	super initialize.
	announcer := Announcer new.
	port := 7042.
	jobQueue := SharedQueue new.
	runnerStats := GtRemoteRunnerStats new.
	"currentlyExecutingJobs is a dictionary of GtRrJobContext keyed by job uid.
	The keys are ordered to ensure that tasks are assigned to the job started first."
	currentlyExecutingJobs := OrderedDictionary new.
	currentlyExecutingTasks := Dictionary new.
	"Make sure you REALLY know what you're doing before changing sharedAccess to a Monitor.
	PharoLinkServer requests are handled in individual processes, so any deadlock is unlikely to be resolved by converting sharedAccess to a Monitor."
	sharedAccess := GtMutualExclusionSemaphore forMutualExclusion.
	"availableWorkers is a Set of GtRrFutureWorkerTask.
	The worker is represented by the connection and is waiting on the semaphore held by the GtRrFutureWorkerTask."
	availableWorkers := Set new.
	registeredWorkers := Dictionary new.
	timeoutManager := GtRrTimeoutManager remoteRunner: self.
	self 
		managerStartupAndShutdown: GtRrLocalManagerStartupAndShutdown new;
		jobStartupAndShutdown: GtRrLocalJobStartupAndShutdown new.

]

{ #category : #accessing }
GtRemoteRunner >> jobStartupAndShutdown [

	^ jobStartupAndShutdown
]

{ #category : #accessing }
GtRemoteRunner >> jobStartupAndShutdown: aGtDtsJobStartupAndShutdown [

	jobStartupAndShutdown := aGtDtsJobStartupAndShutdown.
	jobStartupAndShutdown remoteRunner: self
]

{ #category : #accessing }
GtRemoteRunner >> jobTimeout [

	^ jobTimeout ifNil: [ jobTimeout := self defaultJobTimeout ]
]

{ #category : #accessing }
GtRemoteRunner >> jobTimeout: anObject [

	jobTimeout := anObject
]

{ #category : #'api - logger' }
GtRemoteRunner >> log [
	"Answer the in-memory log"

	^ log
]

{ #category : #accessing }
GtRemoteRunner >> managerStartupAndShutdown [

	^ managerStartupAndShutdown
]

{ #category : #accessing }
GtRemoteRunner >> managerStartupAndShutdown: aGtRrManagerStartupAndShutdown [

	managerStartupAndShutdown := aGtRrManagerStartupAndShutdown.
	managerStartupAndShutdown remoteRunner: self.
]

{ #category : #'api - worker' }
GtRemoteRunner >> nextTaskFor: aPlatform [
	"Answer the next task allocated to the worker that is waiting on this method.
	The task is assigned in a separate process."
	| taskFuture |

	taskFuture := GtRrFutureWorkerTask new 
		connection: (registeredWorkers at: PharoLinkServerCurrentConnection value);
		platform: aPlatform.
	sharedAccess critical:
		[ availableWorkers add: taskFuture.
		self assignTasksToWorkers ].
	taskFuture wait.
	^ taskFuture taskContext.

]

{ #category : #'api - worker' }
GtRemoteRunner >> nextTaskSerializedFor: aPlatform [

	^ LeJsonV4 uniqueInstance serialize: (self nextTaskFor: aPlatform)
]

{ #category : #accessing }
GtRemoteRunner >> pendingJobCount [

	^ sharedAccess critical: [ jobQueue size ]
]

{ #category : #accessing }
GtRemoteRunner >> port [

	^ port
]

{ #category : #accessing }
GtRemoteRunner >> port: anObject [

	port := anObject
]

{ #category : #printing }
GtRemoteRunner >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		<< self state;
		nextPut: $).
]

{ #category : #'api - worker' }
GtRemoteRunner >> privateTaskFailed: aTaskContextId with: anGtRrTaskErrorDetails [
	"Mark the specified task as failed.
	Must be called within sharedAccess"
	| taskContext |

	taskContext := currentlyExecutingTasks removeKey: aTaskContextId.
	taskContext errorDetails: anGtRrTaskErrorDetails.
	taskContext markTaskCompleted.
	self checkJobCompleted: taskContext.
]

{ #category : #'api - worker' }
GtRemoteRunner >> registerWorkerWithPlatform: aPlatform [
	"Register the supplied worker and connection details.
	Register the connection for disconnection notification"
	| pharoLinkServerConnection workerConnection |

	pharoLinkServerConnection := PharoLinkServerCurrentConnection value.
	workerConnection := GtRrWorkerConnection connection: pharoLinkServerConnection.
	workerConnection platform: aPlatform.
	sharedAccess critical:
		[ registeredWorkers at: pharoLinkServerConnection put: workerConnection ].
	pharoLinkServerConnection
		when: PharoLinkServerConnectionDisconnectedAnnouncement
		send: #unregisterWorker:
		to: self.
	self announceAndLog: (GtRrWorkerRegisteredAnnouncement new
			worker: workerConnection).
	"Answer a PharoLink primitive so that a proxy isn't created for the runner (which is a global, anyway)"
	^ nil
]

{ #category : #accessing }
GtRemoteRunner >> registeredWorkerCount [

	^ sharedAccess critical: [ registeredWorkers size ]
]

{ #category : #'private - accessing' }
GtRemoteRunner >> removeCurrentlyExecutingJob: aJobContextId [
	"Remove the specified job from the collection of currently executing jobs.
	It's possible that the job was cancelled on the server and a worker disappears at the same time, resulting in two attempts to remove the current job.  Do nothing if the job isn't found."

	currentlyExecutingJobs removeKey: aJobContextId ifAbsent: []
]

{ #category : #phases }
GtRemoteRunner >> runManagerShutdown [
	"Perform any actions associated with stopping the DTS cluster"

	managerStartupAndShutdown shutdown
]

{ #category : #phases }
GtRemoteRunner >> runManagerStartup [
	"Perform any actions associated with starting the remote runners"

	managerStartupAndShutdown startup
]

{ #category : #accessing }
GtRemoteRunner >> server [

	^ server
]

{ #category : #accessing }
GtRemoteRunner >> server: anObject [

	server := anObject
]

{ #category : #accessing }
GtRemoteRunner >> sharedAccess [

	^ sharedAccess
]

{ #category : #'api - runner' }
GtRemoteRunner >> start [

	self runManagerStartup
]

{ #category : #private }
GtRemoteRunner >> startJob: aGtRrJob [
	"Start the supplied job.
	Must be called within sharedAccess"
	| context |

	runnerStats incrementJobCount.
	context := GtRrJobContext new 
		remoteRunner: self;
		job: aGtRrJob.
	currentlyExecutingJobs
		at: aGtRrJob id
		put: context.
	jobStartupAndShutdown startupJob: context.
	self assignTasksToWorkers.

]

{ #category : #'api - logger' }
GtRemoteRunner >> startLogging [
	"Start the receiver's in-memory log"

	log ifNotNil: [ self error: 'Logging already started' ].
	log := CircularMemoryLogger new startFor: GtRemoteRunnerAnnouncement.
]

{ #category : #ui }
GtRemoteRunner >> state [
	"Answer a label that represents the overall state of the runner.
	Must be called within sharedAccess"
	| availableWorkerCount jobCount currentJobCount currentTaskCount registeredWorkerCount |

	availableWorkerCount := availableWorkers size.
	jobCount := jobQueue size.
	currentJobCount := currentlyExecutingJobs size.
	currentTaskCount := currentlyExecutingTasks size.
	registeredWorkerCount := registeredWorkers size.
	(registeredWorkerCount = 0 and:
		[ jobCount > 0 or: [ currentJobCount > 0 ] ]) ifTrue: [ ^ #stuck ].
	(jobCount = 0 and: [ currentJobCount = 0 ]) ifTrue: [ ^ #idle ].
	(jobCount > 0 or: [ currentJobCount > 0 ]) ifTrue: [ ^ #busy ].
	self error: 'Unknown state'.
]

{ #category : #'api - runner' }
GtRemoteRunner >> stop [

	self runManagerShutdown
]

{ #category : #'api - jobs' }
GtRemoteRunner >> submitJob: aGtRrJob [
	"Add the supplied job to the queue.
	Start execution as soon as possible"

	sharedAccess critical:
		[ currentlyExecutingJobs ifEmpty:
			[ self announceAndLog: (GtRrJobSubmittedAnnouncement job: aGtRrJob).
			self startJob: aGtRrJob ]
		ifNotEmpty:
			[ "Multiple jobs may be allowed to run concurrently - functionality to be added"
			jobQueue nextPut: aGtRrJob.
			self announceAndLog: (GtRrJobSubmittedAnnouncement job: aGtRrJob). ] ].

]

{ #category : #ui }
GtRemoteRunner >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		sharedAccess critical:
			[ stream
				nextPut: { #State. self state. self state. };
				nextPut: { 'Total Job Count'. runnerStats totalJobCount. self. };
				nextPut: { 'Total Task Count'. runnerStats totalTaskCount. self. };
				nextPut: {'Job Queue Size'. jobQueue size. jobQueue. };
				nextPut: {'Registered Workers'. registeredWorkers size. registeredWorkers. };
				nextPut: {'Available Workers'. availableWorkers size. availableWorkers. };
				nextPut: {'Currently Executing Jobs'. currentlyExecutingJobs size. currentlyExecutingJobs. };
				nextPut: {'Currently Executing Tasks'. currentlyExecutingTasks size. currentlyExecutingTasks. };
				nextPut: { 'Default Worker Timeout'. self workerTimeout. self. };
				nextPut: { 'Default Job Timeout'. self jobTimeout. self. };
				nextPut: { 'Default Task Timeout'. self taskTimeout. self. };
				nextPut: {#Port. port. server. }
				 ].
		stream nextPut: { 'Shared Access Waiting'. sharedAccess size. sharedAccess. } ]
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskDone: aTaskContextId with: anObject [
	| taskContext |

	sharedAccess critical: 
		[ taskContext := currentlyExecutingTasks removeKey: aTaskContextId.
		taskContext result: anObject.
		taskContext markTaskCompleted.
		self checkJobCompleted: taskContext ].
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskFailed: aTaskContextId with: anGtRrTaskErrorDetails [
	"Mark the specified task as failed"

	sharedAccess critical: 
		[ self privateTaskFailed: aTaskContextId with: anGtRrTaskErrorDetails ].
]

{ #category : #accessing }
GtRemoteRunner >> taskTimeout [

	^ taskTimeout ifNil: [ taskTimeout := self defaultTaskTimeout ]
]

{ #category : #accessing }
GtRemoteRunner >> taskTimeout: anObject [

	taskTimeout := anObject
]

{ #category : #'api - jobs' }
GtRemoteRunner >> terminateJobId: aJobId [
	"Terminate the specified job.
	If the job has not yet been started, it is marked cancelled.
	If it has been started, it will be marked completed with errors."
	<return: #GtRrJob>

	^ sharedAccess critical:
		[ currentlyExecutingJobs 
			at: aJobId 
			ifPresent: [ :aJobContext | 
				currentlyExecutingJobs removeKey: aJobId.
				aJobContext terminateJob.
				self announceAndLog: (GtRrJobTerminatedAnnouncement job: aJobContext job).
				aJobContext job ]
			ifAbsent: 
				[ (jobQueue nextOrNilSuchThat: [ :jobContext | jobContext id = aJobId ])
				ifNotNil: [ :aJob |
					aJob cancelJob.
					self announceAndLog: (GtRrJobCancelledAnnouncement job: aJob).
					aJob ] ] ].
]

{ #category : #private }
GtRemoteRunner >> terminateTaskContextId: aTaskContextId [
	"Terminate the specified currently executing task"
	| taskContext  |

	"This should send a terminate command through the control channel.
	When the control channel is available...
	For now, close the connection, which should cause the worker to exit, terminating any associated task.  It will be auto-restarted if appropriate.
	The connection will announce it's closure, which will call back in to the remote runner, requiring sharedAccess.  A Monitor would handle this, but this is temporary.  Just fork for now."
	taskContext := currentlyExecutingTasks at: aTaskContextId.
	taskContext task state = #started ifFalse: [ ^ self ].
	[ taskContext connection stop ] fork.
]

{ #category : #accessing }
GtRemoteRunner >> timeoutManager [

	^ timeoutManager
]

{ #category : #'api - worker' }
GtRemoteRunner >> unregisterWorker: aPharoLinkServerConnectionDisconnectedAnnouncement [

	^ self
		unregisterWorker: aPharoLinkServerConnectionDisconnectedAnnouncement 
		reason: 'Worker connection lost'
]

{ #category : #'api - worker' }
GtRemoteRunner >> unregisterWorker: aPharoLinkServerConnectionDisconnectedAnnouncement reason: aString [
	| connection terminatedWorkers failedTasks errorDetails workerConnection |

	connection := aPharoLinkServerConnectionDisconnectedAnnouncement connection.
	sharedAccess critical:
		[ workerConnection := registeredWorkers removeKey: connection ifAbsent: [].
		terminatedWorkers := availableWorkers select: [ :workerFuture | 
			workerFuture connection = workerConnection ].
		terminatedWorkers	do: [ :workerFuture | workerFuture terminateProcess ].
		availableWorkers removeAll: terminatedWorkers.
		failedTasks := currentlyExecutingTasks select: [ :each |
			each connection = workerConnection ].
		failedTasks valuesDo: [ :taskContext |
			errorDetails := GtRrErrorDetails new
					errorMessage: 'Connection closed';
					setTrace.
			self privateTaskFailed: taskContext taskContextId with: errorDetails ]. ].
	self announceAndLog: (GtRrWorkerUnregisteredAnnouncement new
		worker: connection;
		reason: aString).
]

{ #category : #accessing }
GtRemoteRunner >> workerTimeout [

	^ workerTimeout ifNil: [ workerTimeout := self defaultWorkerTimeout ]
]

{ #category : #accessing }
GtRemoteRunner >> workerTimeout: anObject [

	workerTimeout := anObject
]
