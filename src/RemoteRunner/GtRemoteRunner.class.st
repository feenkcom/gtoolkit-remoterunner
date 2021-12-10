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
  - Tests
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
		'registeredWorkers'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRemoteRunner >> addCurrentlyExecutingTask: aGtRrTaskContext [
	"Add the supplied task to the collection of currently executing tasks.
	Must be called within sharedAccess."

	currentlyExecutingTasks at: aGtRrTaskContext taskContextId put: aGtRrTaskContext
]

{ #category : #private }
GtRemoteRunner >> assignTasksToWorkers [
	"Assign tasks to any available workers.
	Must be called within sharedAccess."
	| taskContext busyWorkers |

	(availableWorkers isEmpty or: [ currentlyExecutingJobs isEmpty ]) ifTrue: [ ^ self ].

	busyWorkers := OrderedCollection new.
	"Loop around assigning tasks to workers until there either no more workers or no more tasks available"
	availableWorkers do: [ :worker |
		taskContext := self getNextTaskFor: worker platform.
		taskContext ifNotNil:
			[ taskContext
				workerFuture: worker;
				markTaskStarted.
			"Set the task in the worker, this will signal the worker's semaphore, waking up the worker's process"
			worker taskContext: taskContext.
			busyWorkers add: worker ] ].
	availableWorkers removeAll: busyWorkers.
]

{ #category : #accessing }
GtRemoteRunner >> availableWorkerCount [

	^ sharedAccess critical: [ availableWorkers size ]
]

{ #category : #private }
GtRemoteRunner >> checkJobFinished: aGtRrContext [
	"After each task has been completed, check if the job has finished, and if so, signal it.
	Must be called within sharedAccess."
	| jobContext job |

	jobContext := aGtRrContext jobContext.
	jobContext isFinished ifFalse: [ ^ self ].

	currentlyExecutingJobs removeKey: jobContext id.
	job := jobContext job.
	job state: #completed.
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
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtJobQueueFor: aView [
	<gtView>

	^ aView list
		  title: 'Job Queue';
		  priority: 20;
		  items: [ jobQueue itemArray ];
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
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtWorkersFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Registered Workers';
		  priority: 50;
		  items: [ registeredWorkers associations ];
		  column: 'IP Address' text: [ :item | 
			String streamContents: [ :stream |
				item key remoteAddress do: [ :byte |
					stream print: byte ]
				separatedBy: [ stream nextPut: $. ] ] ];
		  column: 'Platform' text: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #initialization }
GtRemoteRunner >> initialize [

	super initialize.
	port := 7042.
	jobQueue := SharedQueue new.
	"currentlyExecutingJobs is a dictionary of GtRrJobContext keyed by job uid.
	The keys are ordered to ensure that tasks are assigned to the job started first."
	currentlyExecutingJobs := OrderedDictionary new.
	currentlyExecutingTasks := Dictionary new.
	sharedAccess := GtMutualExclusionSemaphore forMutualExclusion.
	"availableWorkers is a Set of GtRrFutureWorkerTask.
	The worker is represented by the connection and is waiting on the semaphore held by the GtRrFutureWorkerTask."
	availableWorkers := Set new.
	registeredWorkers := Dictionary new.
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
		connection: PharoLinkServerCurrentConnection value;
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
	self checkJobFinished: taskContext.
]

{ #category : #'api - worker' }
GtRemoteRunner >> registerWorkerWithPlatform: aPlatform [
	"Register the supplied worker and connection details.
	Register the connection for disconnection notification"
	| pharoLinkServerConnection |

	pharoLinkServerConnection := PharoLinkServerCurrentConnection value.
	sharedAccess critical:
		[ registeredWorkers at: pharoLinkServerConnection put: aPlatform ].
	pharoLinkServerConnection
		when: PharoLinkServerConnectionDisconnectedAnnouncement
		send: #unregisterWorker:
		to: self.
	"Answer a PharoLink primitive so that a proxy isn't created for the runner (which is a global, anyway)"
	^ nil
]

{ #category : #accessing }
GtRemoteRunner >> registeredWorkerCount [

	^ sharedAccess critical: [ registeredWorkers size ]
]

{ #category : #phases }
GtRemoteRunner >> runJobShutdown [
	"Perform any actions associated with finishing the current job"

	jobStartupAndShutdown shutdown
]

{ #category : #phases }
GtRemoteRunner >> runJobStartup [
	"Perform any actions associated with starting a new job"

	jobStartupAndShutdown startup
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

{ #category : #'api - runner' }
GtRemoteRunner >> start [

	self runManagerStartup
]

{ #category : #private }
GtRemoteRunner >> startJob: aGtRrJob [
	"Start the supplied job.
	Must be called within sharedAccess"
	| context |

	context := GtRrJobContext new 
		remoteRunner: self;
		job: aGtRrJob.
	currentlyExecutingJobs
		at: aGtRrJob id
		put: context.
	jobStartupAndShutdown startupForJob: context.
	aGtRrJob state: #started.
	self assignTasksToWorkers.
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
			[ self startJob: aGtRrJob ]
		ifNotEmpty:
			[ jobQueue nextPut: aGtRrJob.
			"If the current job has an error, the next one can be started,
				but maybe not always.
				To be implemented" ] ]
]

{ #category : #ui }
GtRemoteRunner >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ sharedAccess critical:
		[ Array streamContents: [ :stream |
			stream
				nextPut: { #State. self state. self state. };
				nextPut: {'Job Queue Size'. jobQueue size. jobQueue. };
				nextPut: {'Registered Workers'. registeredWorkers size. registeredWorkers. };
				nextPut: {'Available Workers'. availableWorkers size. availableWorkers. };
				nextPut: {'Currently Executing Jobs'. currentlyExecutingJobs size. currentlyExecutingJobs. };
				nextPut: {'Currently Executing Tasks'. currentlyExecutingTasks size. currentlyExecutingTasks. };
				nextPut: {#Port. port. server. }
				 ] ]
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskDone: aTaskContextId with: anObject [
	| taskContext |

	sharedAccess critical: 
		[ taskContext := currentlyExecutingTasks removeKey: aTaskContextId.
		taskContext result: anObject.
		taskContext markTaskCompleted.
		self checkJobFinished: taskContext ].
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskFailed: aTaskContextId with: anGtRrTaskErrorDetails [
	"Mark the specified task as failed"

	sharedAccess critical: 
		[ self privateTaskFailed: aTaskContextId with: anGtRrTaskErrorDetails ].
]

{ #category : #'api - worker' }
GtRemoteRunner >> unregisterWorker: aPharoLinkServerConnectionDisconnectedAnnouncement [
	| connection terminatedWorkers failedTasks errorDetails |

	connection := aPharoLinkServerConnectionDisconnectedAnnouncement connection.
	sharedAccess critical:
		[ registeredWorkers removeKey: connection ifAbsent: [].
		terminatedWorkers := availableWorkers select: [ :worker | worker connection = connection ].
		terminatedWorkers	do: [ :worker | worker terminateProcess ].
		availableWorkers removeAll: terminatedWorkers.
		failedTasks := currentlyExecutingTasks select: [ :each |
			each connection = connection ].
		failedTasks valuesDo: [ :taskContext |
			errorDetails := GtRrTaskErrorDetails new
					errorMessage: 'Connection closed';
					trace: (String streamContents: [ :stream |
						thisContext debugStackOn: stream ]).
			self privateTaskFailed: taskContext taskContextId with: errorDetails ]. ].
]
