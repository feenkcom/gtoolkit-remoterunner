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
	#instVars : [
		'port',
		'server',
		'jobStartupAndShutdown',
		'managerStartupAndShutdown',
		'availableWorkers',
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
		'log',
		'taskQueue'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #cleanup }
GtRemoteRunner class >> cleanUniqueInstance [

	uniqueInstance ifNotNil: [ :anInstance | 
		self onRemoveUniqueInstance: anInstance ].
	uniqueInstance := nil.
]

{ #category : #cleanup }
GtRemoteRunner class >> cleanUp [

	self cleanUniqueInstance
]

{ #category : #accessing }
GtRemoteRunner class >> default [

	^ self uniqueInstance
]

{ #category : #testing }
GtRemoteRunner class >> hasUniqueInstance [

	^ uniqueInstance isNotNil.
]

{ #category : #accessing }
GtRemoteRunner class >> instance [
	"Override the default which makes this an example.
	Starting multiple servers on the default port is a bad idea."

	^ self uniqueInstance
]

{ #category : #'private - hooks' }
GtRemoteRunner class >> onRemoveUniqueInstance: anInstance [
	"Classes may perform some activities on a singleton that is about to be released"

	uniqueInstance stop.
]

{ #category : #printing }
GtRemoteRunner class >> printIpAddress: aByteArray [
	"Answer the usual dot notation of the supplied IPv4 address"

	aByteArray ifNil: [ ^ '<none>' ].

	self assert: aByteArray size equals: 4.

	^ String streamContents: [ :stream |
		aByteArray printOn: stream delimiter: '.' ]
]

{ #category : #'headless remote runner' }
GtRemoteRunner class >> setDefaultHeadless [
	"Make the default remote runner a proxy to an existing headless runner"

	^ self setDefaultHeadlessOnPort: 7042 codeSync: true
]

{ #category : #'headless remote runner' }
GtRemoteRunner class >> setDefaultHeadlessOnPort: aNumber codeSync: aBoolean [
	"Make the default remote runner a proxy to an existing headless runner"
	| settings plApplication runner |

	self hasUniqueInstance ifTrue: [ GtRemoteRunner cleanUp ].
	settings := LanguageLinkSettings pharoDefaultSettings.
	settings
		serverProcessClass: LanguageLinkManualProcess;
		serverSocketAddress: (LanguageLinkSocketAddress
			ipOrName: 'localhost' port: 7042).
	plApplication := PharoLinkApplication newWith: settings.
	plApplication start.
	runner := plApplication newCommandFactory
		sendAndWait: 'GtAssignedRemoteRunner'.
	self setUniqueInstance: runner.

	aBoolean ifTrue: [ runner startCodeSync ].

	^ runner.
]

{ #category : #initialization }
GtRemoteRunner class >> setUniqueInstance: aGtRemoteRunner [

	self hasUniqueInstance ifTrue: 
		[ self error: 'GtRemoteRunner already running' ].
	uniqueInstance := aGtRemoteRunner.
]

{ #category : #accessing }
GtRemoteRunner class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new start startLogging ]
]

{ #category : #accessing }
GtRemoteRunner >> addCurrentlyExecutingTask: aGtRrTaskContext [
	"Add the supplied task to the collection of currently executing tasks.
	Must be called within sharedAccess."

	currentlyExecutingTasks at: aGtRrTaskContext taskContextId put: aGtRrTaskContext
]

{ #category : #'api - worker' }
GtRemoteRunner >> addObserver: aBlock [
	| worker |

	worker := registeredWorkers at: PharoLinkServerCurrentConnection value.
	worker addObserver: aBlock.
	self announceAndLog: (GtRrWorkerControlChannelRegisteredAnnouncement worker: worker).
	worker observerWait.
]

{ #category : #adding }
GtRemoteRunner >> addTaskContext: taskContext [
	"Add the supplied taskContext to the task queue.
	Can be called from anywhere since a SharedQueue is used."

	taskQueue nextPut: taskContext.
]

{ #category : #announcer }
GtRemoteRunner >> announce: anAnnouncement [

	^ self announcer announce: anAnnouncement
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
	Must be called within sharedAccess.
	
	Note that we are using a SharedQueue for the taskQueue, so a simpler architecture would be for each worker to wait directly on the taskQueue.  However workers can disconnect at any time, which would terminate the process that is waiting on the taskQueue... and that can crash the VM."
	| taskContext busyWorkers |

	(availableWorkers isEmpty or: [ currentlyExecutingJobs isEmpty ]) ifTrue: [ ^ self ].

	busyWorkers := OrderedCollection new.
	"Loop around assigning tasks to workers until there either no more workers or no more tasks available"
	availableWorkers do: [ :workerFuture |
		taskContext := self getNextTaskFor: workerFuture.
		taskContext ifNotNil:
			[ runnerStats incrementTaskCount.
			taskContext
				workerFuture: workerFuture;
				markTaskStarted.
			self addCurrentlyExecutingTask: taskContext.
			"Set the task in the workerFuture, this will signal the workerFuture's semaphore, waking up the workerFuture's process"
			workerFuture taskContext: taskContext.
			busyWorkers add: workerFuture.
			timeoutManager addContext: taskContext.
			self announceAndLog: (GtRrTaskStartedAnnouncement task: taskContext) ] ].
	availableWorkers removeAll: busyWorkers.
]

{ #category : #accessing }
GtRemoteRunner >> availableWorkerCount [

	^ sharedAccess critical: [ availableWorkers size ]
]

{ #category : #'private - accessing' }
GtRemoteRunner >> availableWorkers [

	^ availableWorkers 
]

{ #category : #private }
GtRemoteRunner >> checkJobCompleted: aGtRrContext [
	"After each task has been completed, check if the job has finished, and if so, signal it.
	Must be called within sharedAccess."
	| jobContext |
"self halt."
	jobContext := aGtRrContext jobContext.
	jobContext isFinished ifFalse: [ ^ self ].

	jobStartupAndShutdown shutdownJob: jobContext.

]

{ #category : #'private - accessing' }
GtRemoteRunner >> critical: aBlock [
	"Evaluate the supplied block within sharedAccess.
	Only for use by cooperating objects."

	sharedAccess critical: aBlock.
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
GtRemoteRunner >> getNextTaskFor: aWorkerFuture [
	"Answer the next task for the supplied worker, or nil.
	Must be called within sharedAccess."
	<return: #GtRrTaskContext>
	| attributes |

	attributes := aWorkerFuture connection details.
	^ taskQueue nextOrNilSuchThat: [ :task | 
		task constraint matches: attributes ].

]

{ #category : #ui }
GtRemoteRunner >> gtExecutingJobsFor: aView [

	<gtView>
	^ aView list
		  title: 'Executing Jobs';
		  priority: 20;
		  items: [ sharedAccess critical: [ currentlyExecutingJobs values ] ];
		  send: [ :item | item ];
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
		  send: [ :item | item ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtPingActionFor: anAction [
	<gtAction>

	^ anAction button
		icon: BrGlamorousVectorIcons signal;
		tooltip: 'Ping all workers';
		action: [ :button | button phlow spawnObject: self pingAllWorkers ]
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
GtRemoteRunner >> gtTaskQueueFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Task Queue';
		  priority: 50;
		  items: [ taskQueue itemArray ];
		  column: 'Job' text: [ :item | item jobContext id ];
			column: 'Task' text: [ :item | item taskId ];
		  column: 'Description' text: [ :item | item printString ];
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtWorkersFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Registered Workers';
		  priority: 50;
		  items: [ registeredWorkers values ];
		  column: 'IP Address' text: [ :item | GtRemoteRunner printIpAddress: item remoteAddress ];
			column: 'Working Directory' text: [ :item | item detailAt: #workingDirectory ifAbsent: [ '' ] ];
		  actionUpdateButton
]

{ #category : #'api - logger' }
GtRemoteRunner >> hasLog [
	"Answer a boolean indicating if the receiver has an active log available"

	^ log isNotNil
]

{ #category : #announcer }
GtRemoteRunner >> hasSubscriber: anObject [

	^ self announcer hasSubscriber: anObject
]

{ #category : #initialization }
GtRemoteRunner >> initialize [

	super initialize.
	announcer := Announcer new.
	port := 7042.
	taskQueue := SharedQueue new.
	runnerStats := GtRemoteRunnerStats new.
	"currentlyExecutingJobs is a dictionary of GtRrJobContext keyed by job uid"
	currentlyExecutingJobs := Dictionary new.
	"currentlyExecutingTasks is a dictionary of GtRrTaskContext keyed by task context id"
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
		managerStartupAndShutdown: GtRrCodeSyncedLocalManagerStartupAndShutdown new;
		jobStartupAndShutdown: GtRrLocalJobStartupAndShutdown new.
]

{ #category : #testing }
GtRemoteRunner >> isRunning [

	^ server isNotNil and: [ server isRunning ]
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
GtRemoteRunner >> nextTaskForCurrentWorker [
	"Answer the next task allocated to the worker that is waiting on this method.
	The task is assigned in a separate process."
	| taskFuture |

	taskFuture := GtRrFutureWorkerTask new 
		connection: (registeredWorkers at: PharoLinkServerCurrentConnection value).
	sharedAccess critical:
		[ availableWorkers add: taskFuture.
		self assignTasksToWorkers ].
	taskFuture wait.
	^ taskFuture taskContext asWorkerTaskContext.

]

{ #category : #'api - worker' }
GtRemoteRunner >> nextTaskSerializedForCurrentWorker [
	"Answer the next task allocated to the worker that is waiting on this method serialised for transmission over the wire"

	^ LeJsonV4 uniqueInstance serialize: self nextTaskForCurrentWorker
]

{ #category : #'api - worker' }
GtRemoteRunner >> pingAllWorkers [
	"Ping each of the registered workers.
	Answer a collection of those that failed"
	| errors |

	errors := OrderedCollection new.
	registeredWorkers do: [ :worker |
		sharedAccess critical:
			[ [ worker commandPing ]
				on: Error
				do: [ :ex | errors add: worker -> ex freeze ] ] ].
	^ errors
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
	self announceAndLog: (GtRrTaskCompletedAnnouncement task: taskContext).
	self assignTasksToWorkers.
	self checkJobCompleted: taskContext.
]

{ #category : #'api - worker' }
GtRemoteRunner >> registerWorkerWithDetails: aDictionary [
	"Register the supplied worker and connection details.
	Register the connection for disconnection notification"
	| pharoLinkServerConnection workerConnection |

	pharoLinkServerConnection := PharoLinkServerCurrentConnection value.
	pharoLinkServerConnection setCloseOnExec: true.
	workerConnection := GtRrWorkerConnection 
		connection: pharoLinkServerConnection
		runner: self.
	workerConnection details: aDictionary.
	sharedAccess critical:
		[ registeredWorkers at: pharoLinkServerConnection put: workerConnection ].
	managerStartupAndShutdown registerWorker: workerConnection.
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

{ #category : #'private - debugging' }
GtRemoteRunner >> registeredWorkers [
	"Answer the registeredWorkers.
	WARNING: This is outside sharedAccess and is for debugging purposes only."

	^ registeredWorkers
]

{ #category : #enumerating }
GtRemoteRunner >> registeredWorkersDo: aBlock [
	"Evaluate aBlock for each of the receiver's registered workers.
	Must be called within sharedAccess."

	registeredWorkers do: aBlock
]

{ #category : #'private - accessing' }
GtRemoteRunner >> removeCurrentlyExecutingJob: aJobContextId [
	"Remove the specified job from the collection of currently executing jobs.
	It's possible that the job was cancelled on the server and a worker disappears at the same time, resulting in two attempts to remove the current job.  Do nothing if the job isn't found."

	currentlyExecutingJobs removeKey: aJobContextId ifAbsent: []
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> removeSubscription: subscription [
	"Remove the given subscription from the receiver"

	^ self announcer removeSubscription: subscription
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
GtRemoteRunner >> server: aPharoLinkServer [

	server := aPharoLinkServer
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

	log ifNotNil: [ ^ self ].
	log := CircularMemoryLogger new startFor: GtRemoteRunnerAnnouncement.
]

{ #category : #ui }
GtRemoteRunner >> state [
	"Answer a label that represents the overall state of the runner.
	Must be called within sharedAccess"
	| availableWorkerCount taskQueueCount currentJobCount currentTaskCount registeredWorkerCount |

	(server isNil or: [ server isRunning not ]) ifTrue: [ ^ #stopped ].
	sharedAccess size > 0 ifTrue: [ ^ #waiting ].
	availableWorkerCount := availableWorkers size.
	taskQueueCount := taskQueue size.
	currentJobCount := currentlyExecutingJobs size.
	currentTaskCount := currentlyExecutingTasks size.
	registeredWorkerCount := registeredWorkers size.
	(registeredWorkerCount = 0 and:
		[ taskQueueCount > 0 or: [ currentJobCount > 0 ] ]) ifTrue: [ ^ #stuck ].
	(taskQueueCount = 0 and: [ currentJobCount = 0 ]) ifTrue: [ ^ #idle ].
	(taskQueueCount > 0 or: [ currentJobCount > 0 ]) ifTrue: [ ^ #busy ].
	self error: 'Unknown state'.
]

{ #category : #'api - runner' }
GtRemoteRunner >> stop [

	self runManagerShutdown.
	self stopLogging.
]

{ #category : #'api - logger' }
GtRemoteRunner >> stopLogging [
	"Stop the receiver's in-memory log"

	log ifNil: [ ^ self ].
	log stop.
	log := nil.
]

{ #category : #'api - jobs' }
GtRemoteRunner >> submitJob: aGtRrJob [
	"Add the supplied job to the queue.
	Start execution as soon as possible"

	sharedAccess critical: [ self startJob: aGtRrJob ].
	self announceAndLog: (GtRrJobSubmittedAnnouncement job: aGtRrJob).
	^ aGtRrJob
]

{ #category : #'api - jobs' }
GtRemoteRunner >> submitSerializedJob: aGtRrJobString [
	"Submit the supplied job after deserialising it"

	^ self submitJob: (LeJsonV4 uniqueInstance deserialize: aGtRrJobString readStream)
]

{ #category : #ui }
GtRemoteRunner >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream
			nextPut: { #State. self state. self state. };
			nextPut: { 'Total Job Count'. runnerStats totalJobCount. self. };
			nextPut: { 'Total Task Count'. runnerStats totalTaskCount. self. };
			nextPut: {'Task Queue Size'. taskQueue size. taskQueue. };
			nextPut: {'Registered Workers'. registeredWorkers size. registeredWorkers. };
			nextPut: {'Available Workers'. availableWorkers size. availableWorkers. };
			nextPut: {'Currently Executing Jobs'. currentlyExecutingJobs size. currentlyExecutingJobs. };
			nextPut: {'Currently Executing Tasks'. currentlyExecutingTasks size. currentlyExecutingTasks. };
			nextPut: { 'Default Worker Timeout'. self workerTimeout. self. };
			nextPut: { 'Default Job Timeout'. self jobTimeout. self. };
			nextPut: { 'Default Task Timeout'. self taskTimeout. self. };
			nextPut: { #Port. port. server. };
			nextPut: { #Logging. log isNotNil. log. };
			nextPut: { 'Shared Access Waiting'. sharedAccess size. sharedAccess. } ]
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskDone: aTaskContextId with: anObject [
	| taskContext |

	sharedAccess critical: 
		[ taskContext := currentlyExecutingTasks removeKey: aTaskContextId.
		taskContext result: anObject.
		taskContext markTaskCompleted.
		self announceAndLog: (GtRrTaskCompletedAnnouncement task: taskContext).
		self assignTasksToWorkers.
		self checkJobCompleted: taskContext ].
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskFailed: aTaskContextId with: anGtRrTaskErrorDetails [
	"Mark the specified task as failed"

	sharedAccess critical: 
		[ self privateTaskFailed: aTaskContextId with: anGtRrTaskErrorDetails ].
]

{ #category : #'private - debugging' }
GtRemoteRunner >> taskQueue [
	"Answer the taskQueue.
	WARNING: This is outside sharedAccess and is for debugging purposes only."

	^ taskQueue
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
	If it has been started, it will be marked completed with errors."
	<return: #GtRrJob>
	| jobContext |

	jobContext := sharedAccess critical:
		[ currentlyExecutingJobs 
			at: aJobId 
			ifPresent: [ :aJobContext | 
				currentlyExecutingJobs removeKey: aJobId.
				aJobContext ]
			ifAbsent: [ ] ].
	jobContext ifNil: [ ^ nil ].
	jobContext terminateJob.
	self announceAndLog: (GtRrJobTerminatedAnnouncement job: jobContext job).
	^ jobContext job

]

{ #category : #private }
GtRemoteRunner >> terminateTaskContextId: aTaskContextId [
	"Terminate the specified currently executing task"

	currentlyExecutingTasks at: aTaskContextId ifPresent:
		[ :taskContext | taskContext terminateTask ].
	(taskQueue nextOrNilSuchThat: [ :each | each taskContextId = aTaskContextId ])
		ifNotNil: [ :taskContext | taskContext terminateTask ].
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
		worker: workerConnection;
		reason: aString).
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	^ self announcer unsubscribe: anObject
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> weak [
	"announcer weak subscribe: foo"

	^ self announcer weak
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> when: anAnnouncementClass do: aValuable [
	"Declare that when anAnnouncementClass is raised, aValuable is executed.  Pay attention that ushc method as well as when:do: should not be used on weak announcer since the block holds the receiver and more strongly."

	^ self announcer when: anAnnouncementClass do: aValuable
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> when: anAnnouncementClass do: aValuable for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, aValuable is executed and define the subscriber."

	^ (self when: anAnnouncementClass do: aValuable) subscriber: aSubscriber; yourself.
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> when: anAnnouncementClass doOnce: aValuable for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, aValuable is executed and define the subscriber.
	A valuable is executed ONCE, and then a subscriber gets unsubscribed"

	^ self
		when: anAnnouncementClass
		do: [ :anAnnouncement |
			self unsubscribe: aSubscriber.
			aValuable cull: anAnnouncement ]
		for: aSubscriber
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> when: anAnnouncementClass send: aSelector to: anObject [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector.
    When the message expects one argument (eg #fooAnnouncement:) the announcement is passed as argument.
    When the message expects two arguments (eg #fooAnnouncement:announcer:) both the announcement and the announcer 
    are passed as argument"

		^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> when: anAnnouncementClass send: aSelector to: anObject for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector."

	^ (self when: anAnnouncementClass send: aSelector to: anObject) subscriber: aSubscriber.
]

{ #category : #accessing }
GtRemoteRunner >> workerTimeout [

	^ workerTimeout ifNil: [ workerTimeout := self defaultWorkerTimeout ]
]

{ #category : #accessing }
GtRemoteRunner >> workerTimeout: anObject [

	workerTimeout := anObject
]
