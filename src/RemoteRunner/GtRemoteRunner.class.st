"
GtRemoteRunner manages the running of tasks, such as tests or examples, in a distributed system across one or more machines.

The original scenarios used to design the  system were:

- Individual developer: A developer is working in an image and wants to run tasks in one or more worker images on their local machine.
- Internal team: A team of developers are working, and pool their worker images for common use.
- CI: An automated system runs all tasks on all supported platforms, e.g. linux, mac, windows, on each commit.

Features of the system (mostly not yet implemented) include:

- Handling of the scenarios described above.
- Support for running tests / examples across multiple platforms.
- Timeouts on:
  - Tasks
  - Workers
  - Jobs
  
### Main Components

The main components of the system are:

- {{gtClass:GtRemoteRunner}} provides the primary interface to the system and the main control.
- A {{gtClass:GtRrWorker}} is created for each client image that will run tests or examples.
- A {{gtClass:GtRrJob}} is submitted by users for each collection or tests or examples to be executed.  The user will be notified of the progress of the job.  A {{gtClass:GtRrJob}} contains one or more {{gtClass:GtRrTask}}s.

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
	#traits : 'TGtWithAnnouncementsQueue',
	#classTraits : 'TGtWithAnnouncementsQueue classTrait',
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
		'taskQueue',
		'changesSyncEvents',
		'announcementNotifier',
		'logEmitter'
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

{ #category : #clap }
GtRemoteRunner class >> commandLine [
	<commandline>

	^ self commandLineCommand meaning: [ :args | 
		self processCommandLineArgs: args ].
]

{ #category : #clap }
GtRemoteRunner class >> commandLineCommand [

	^ (ClapCommand id: #remoteRunnerServer)
		  description: 'Run the RemoteRunner server';
		  add: ClapFlag forHelp;
		  add: ((ClapFlag id: #log) description: 'Enable logging to stdout');
		  add: ((ClapFlag id: #listenOn)
				   description:
					   'The port number to listen on.  Should also be able to specify an interface (TDB)';
				   add: (ClapPositional id: #address);
				   yourself);
		  yourself
]

{ #category : #accessing }
GtRemoteRunner class >> connectionOnPort: aNumberOrString [
	"Answer a PharoLink connection to the supplied address"
	| settings plApplication |

	settings := LanguageLinkSettings pharoDefaultSettings.
	settings
		serverProcessClass: LanguageLinkManualProcess;
		serverSocketAddress: (LanguageLinkSocketAddress from: aNumberOrString asString).
	plApplication := PharoLinkApplication newWith: settings.
	plApplication start.
	^ plApplication
]

{ #category : #accessing }
GtRemoteRunner class >> default [

	^ self uniqueInstance
]

{ #category : #accessing }
GtRemoteRunner class >> defaultWatchedAnnouncements [
	"Start the receiver's in-memory log"

	^ { GtRrResultProcessingErrorAnnouncement.
		GtRrWorkerChangesSyncErrorAnnouncement.
	}
]

{ #category : #testing }
GtRemoteRunner class >> hasUniqueInstance [

	^ uniqueInstance isNotNil.
]

{ #category : #accessing }
GtRemoteRunner class >> headlessOnPort: aNumberOrString codeSync: aBoolean [
	"Answer a proxy remote runner connected to the supplied address"
	| plApplication runner |

	plApplication := self connectionOnPort: aNumberOrString.
	runner := plApplication newCommandFactory
		sendAndWait: 'GtAssignedRemoteRunner'.
	aBoolean ifTrue: [ runner startCodeSync ].

	^ runner.
]

{ #category : #'class initialization' }
GtRemoteRunner class >> initialize [
	SessionManager default
		registerSystemClassNamed: self name
]

{ #category : #accessing }
GtRemoteRunner class >> instance [
	"Override the default which makes this an example.
	Starting multiple servers on the default port is a bad idea."

	^ self uniqueInstance
]

{ #category : #accessing }
GtRemoteRunner class >> newHeadlessRunnerProcess [
	"Start a default headless runner on the local machine.
	It is up to the caller to start the process (i.e. whether to just run, signal, wait, etc.).
	Mainly used for testing."
	| proc vm |

	vm := Smalltalk vmDirectory asFileReference / 'GlamorousToolkit-cli'.
	proc := GtSubprocessWithInMemoryOutput
		command: vm fullName
		arguments: {
			FileLocator image resolve fullName.
			'clap'.
			'remoteRunnerServer'.
			'--listenOn'.
			'7042'.
			'--log'.
			'--detachChangesFromFileSystem'.
			'--noLepiterReload'.
			'--noGtImageUpdate'. }.
	proc
		addAllEnvVariablesFromParentWithoutOverride;
		setDefaultErrorBlock;
		terminateOnShutdown.
	^ proc.
]

{ #category : #'private - hooks' }
GtRemoteRunner class >> onRemoveUniqueInstance: anInstance [
	"Classes may perform some activities on a singleton that is about to be released"

	anInstance stop.
]

{ #category : #printing }
GtRemoteRunner class >> printIpAddress: aByteArray [
	"Answer the usual dot notation of the supplied IPv4 address"

	aByteArray ifNil: [ ^ '<none>' ].

	self assert: aByteArray size equals: 4.

	^ String streamContents: [ :stream |
		aByteArray printOn: stream delimiter: '.' ]
]

{ #category : #clap }
GtRemoteRunner class >> processCommandLineArgs: args [
	| runner logger address announcements |

	args
		at: #help ifPresent: [ :help | 
			help value.
			help context exitSuccess ];
		at: #log ifPresent: [ 
			SignalLogger resetAllInstances.
			logger := RestartingStreamLogger stdout.
			announcements := AnnouncementSetWithExclusions withAll:
				{ GtRemoteRunnerAnnouncement, 
				PharoLinkSignal,
				StringSignal }.
			announcements 
				addExclusions: ContextStackSignal allSubclasses;
				addExclusion: PharoLinkEvalSignal.
			logger startFor: announcements ].
	address := ((args at: #listenOn) at: #address) value.
	runner := self new.
	runner 
		port: address asNumber;
		managerStartupAndShutdown: GtRrManualManagerStartupAndShutdown new.
	StringSignal emit: 'Server address: ' , runner port asString.
	runner start.
	StringSignal emit: 'Running'.
	"Hibernate until the process exits"
	Semaphore new wait.
]

{ #category : #'headless remote runner' }
GtRemoteRunner class >> setDefaultHeadless [
	"Make the default remote runner a proxy to an existing headless runner"

	^ self setDefaultHeadlessOnPort: 7042 codeSync: true
]

{ #category : #'headless remote runner' }
GtRemoteRunner class >> setDefaultHeadlessOnPort: aNumberOrString codeSync: aBoolean [
	"Make the default remote runner a proxy to an existing headless runner"
	| runner |

	self hasUniqueInstance ifTrue: [ GtRemoteRunner cleanUp ].
	runner := self headlessOnPort: aNumberOrString codeSync: aBoolean.
	self setUniqueInstance: runner.
	^ runner.
]

{ #category : #initialization }
GtRemoteRunner class >> setUniqueInstance: aGtRemoteRunner [

	self hasUniqueInstance ifTrue: 
		[ self error: 'GtRemoteRunner already running' ].
	uniqueInstance := aGtRemoteRunner.
]

{ #category : #'headless remote runner' }
GtRemoteRunner class >> startUp: resuming [

	resuming ifTrue: 
		[ [ self cleanUp ] 
			forkAt: Processor userInterruptPriority
			named: 'GtRr startup stop' ]
]

{ #category : #accessing }
GtRemoteRunner class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new start startLogging ]
]

{ #category : #accessing }
GtRemoteRunner >> addCurrentlyExecutingTask: aGtRrTaskContext [
	"Add the supplied task to the collection of currently executing tasks.
	Must be called within sharedAccess."

	sharedAccess assertIsOwner.
	currentlyExecutingTasks at: aGtRrTaskContext taskContextId put: aGtRrTaskContext.
	runnerStats currentlyExecutingTaskCount: currentlyExecutingTasks size.
]

{ #category : #'api - worker' }
GtRemoteRunner >> addObserver: aBlock toWorkerId: workerId [
	| worker |

	worker := registeredWorkers at: workerId.
	worker addObserver: aBlock.
	self announceAndLog: (GtRrWorkerControlChannelRegisteredAnnouncement worker: worker).
	worker observerWait.
]

{ #category : #adding }
GtRemoteRunner >> addTaskContext: taskContext [
	"Add the supplied taskContext to the task queue.
	Can be called from anywhere since a SharedQueue is used."

	taskQueue nextPut: taskContext.
	runnerStats taskQueueSize: taskQueue size.
	self assignTasksToWorkers.
]

{ #category : #adding }
GtRemoteRunner >> addTaskContextFirst: taskContext [
	"Add the supplied taskContext to the task queue.
	Can be called from anywhere since a SharedQueue is used."

	taskQueue putFirst: taskContext.
	runnerStats taskQueueSize: taskQueue size.
	self assignTasksToWorkers.
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

{ #category : #announcer }
GtRemoteRunner >> announceStatusMessage: aStatusMessage [
	self announce: (GtRrStatusMessageChangedAnnouncement new
			statusMessage: aStatusMessage)
]

{ #category : #announcer }
GtRemoteRunner >> announceStatusMessageWithString: aMessageString [ 
	self 
		announceStatusMessageWithString: aMessageString 
		andSourceLabel:  'Runner'
]

{ #category : #announcer }
GtRemoteRunner >> announceStatusMessageWithString: aMessageString andSourceLabel: aSourceLabel [
	self announceStatusMessage: (GtRrStatusMessage new
		messageString: aMessageString;
		sourceToolLabel: aSourceLabel)
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
	sharedAccess assertIsOwner.
	"availableWorkers reverseSelect: #notNil thenDo: [ :workerFuture |"
	availableWorkers reverseDo: [ :workerFuture |
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
	busyWorkers do: [ :each |
		availableWorkers 
			remove: each
			ifAbsent: [ StringSignal emit: 'Unable to mark unavailable: ', each printString.
				self error: 'Unable to mark unavailable' ] ].
	runnerStats updateAvailableWorkerCounts: availableWorkers.
]

{ #category : #accessing }
GtRemoteRunner >> availableWorkerCount [

	^ runnerStats availableWorkerCount
]

{ #category : #'private - accessing' }
GtRemoteRunner >> availableWorkers [
	"Answer the availableWorkers.
	Generally, this shouldn't be used, and subsequent access must be within sharedAccess."

	sharedAccess assertIsOwner.
	^ availableWorkers 
]

{ #category : #'private - debugging' }
GtRemoteRunner >> basicRegisteredWorkers [
	"Answer the registeredWorkers.
	WARNING: This is outside sharedAccess and is for debugging purposes only."

	^ registeredWorkers
]

{ #category : #accessing }
GtRemoteRunner >> changesSyncEvents [

	^ changesSyncEvents
]

{ #category : #accessing }
GtRemoteRunner >> changesSyncEvents: anObject [
	"Set the change events to be replayed by each worker.
	Storing the change events in the runner is normally only done when workers will be used for multiple jobs.  If workers are restarted for each job the change events will normally be provided with the job using the 'changeEvents' property."

	changesSyncEvents := anObject
]

{ #category : #accessing }
GtRemoteRunner >> changesSyncEventsFrom: aSerializedOmReference [
	"Answer a collection of encoded EpEvents that will take the worker from the supplied OmReference to the state ready for testing.
	If a collection of events is supplied, use that, otherwise synchronise with the current image.
	Ensure that the supplied OmReference is in the receiver's history"
	| workerOmReference ipAddress result |

	workerOmReference := STON fromString: aSerializedOmReference.
	ipAddress := PharoLinkServerCurrentConnection value remoteAddressString.
	GtRrChangesSyncRetrievalStartingSignal new
		omReference: workerOmReference;
		ipAddress: ipAddress;
		emit.
	result := [ changesSyncEvents
		ifNil: [ GtRrChangesSync uniqueInstance encodedChangesFrom: workerOmReference ]
		ifNotNil: [ changesSyncEvents encodedChangesFrom: workerOmReference ] ]
			on: Error
			do: [ :ex |
				self announceAndLog: (GtRrWorkerChangesSyncErrorAnnouncement new
					ipAddress: ipAddress;
					exception: ex copy freeze).
				ex pass ].
	GtRrChangesSyncRetrievalCompletedSignal new
		omReference: workerOmReference;
		ipAddress: ipAddress;
		emit.
	^ result.
]

{ #category : #'api - jobs' }
GtRemoteRunner >> changesSyncEventsSerialized: anEncodedGtRrChangesSyncEncodedEvents [
	"Submit the supplied job after deserialising it, and enable a queue for it"
	| deserializedChangesSyncEvents |

	deserializedChangesSyncEvents := LeJsonV4 uniqueInstance 
		deserialize: anEncodedGtRrChangesSyncEncodedEvents readStream.
		
	self changesSyncEvents: deserializedChangesSyncEvents.
	^ nil
]

{ #category : #private }
GtRemoteRunner >> checkJobCompleted: aGtRrContext [
	"After each task has been completed, check if the job has finished, and if so, signal it.
	Must be called within sharedAccess."
	| jobContext |

	jobContext := aGtRrContext jobContext.
	jobContext isFinished ifFalse: [ ^ self ].

	self logEmitter emitJobShutdownStartFor:  jobContext.
	jobStartupAndShutdown shutdownJob: jobContext.
	self logEmitter emitJobShutdownEndFor:  jobContext.
	self flushLogger.
]

{ #category : #'private - debugging' }
GtRemoteRunner >> checkRunningJobsCompleted [
	"Check if the currently executing jobs have completed.
	Mostly for debugging."

	self critical:
		[ currentlyExecutingJobs do: [ :jobContext |
			self checkJobCompleted: jobContext ] ].
]

{ #category : #'private - accessing' }
GtRemoteRunner >> critical: aBlock [
	"Evaluate the supplied block within sharedAccess.
	Only for use by cooperating objects."

	^ sharedAccess critical: 
		[ | result |
		runnerStats sharedAccessCount: sharedAccess size.
		result := aBlock value.
		runnerStats sharedAccessCount: sharedAccess size.
		result ].
]

{ #category : #'private - accessing' }
GtRemoteRunner >> currentlyExecutingJobs [
	"Must be called within shared access"

	^ currentlyExecutingJobs
]

{ #category : #'private - accessing' }
GtRemoteRunner >> currentlyExecutingTasks [
	"Must be called within shared access"

	^ currentlyExecutingTasks
]

{ #category : #accessing }
GtRemoteRunner >> debugMode [
	"Answer a boolean indicating whether debug logging should be started.
	Always true during development.  Settings TBD."

	^ true.
]

{ #category : #accessing }
GtRemoteRunner >> defaultTaskTimeout [

	^ 1 hour
]

{ #category : #accessing }
GtRemoteRunner >> defaultWorkerTimeout [

	^ self taskTimeout + 1 minute
]

{ #category : #private }
GtRemoteRunner >> emptyQueuesFor: aJobId [

	self critical: [ | toRemove |
		toRemove := currentlyExecutingTasks values select:
			[ :taskContext | taskContext jobId = aJobId ].
		toRemove do: [ :each | 
			each terminateTask.
			currentlyExecutingTasks removeKey: each taskId ifAbsent: [] ].
		[ (taskQueue nextOrNilSuchThat: [ :aTaskContext |
			aTaskContext jobId = aJobId ]) isNotNil ] whileTrue.
		runnerStats currentlyExecutingTaskCount: currentlyExecutingTasks size.
		runnerStats taskQueueSize: taskQueue size ]
]

{ #category : #accessing }
GtRemoteRunner >> executingJobCount [
	"Answer the number of jobs that are currently being executed."
	
	^ runnerStats currentlyExecutingJobCount
]

{ #category : #'api - logger' }
GtRemoteRunner >> flushLogger [

	log ifNil: [ ^ self ].
	log flushLog.
]

{ #category : #private }
GtRemoteRunner >> getNextTaskFor: aWorkerFuture [
	"Answer the next task for the supplied worker, or nil.
	Must be called within sharedAccess."
	<return: #GtRrTaskContext>
	| attributes result |

	attributes := aWorkerFuture connection details.
	result := taskQueue nextOrNilSuchThat: [ :taskContext | 
		(aWorkerFuture workerJobIdMatches: taskContext) and:
			[ taskContext constraint matches: attributes ] ].
	runnerStats taskQueueSize: taskQueue size.
	^ result
]

{ #category : #ui }
GtRemoteRunner >> gtExecutingJobsFor: aView [

	<gtView>
	^ aView list
		  title: 'Executing jobs';
		  priority: 20;
		  items: [ self critical: [ currentlyExecutingJobs values ] ];
		  send: [ :item | item ];
		  updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRemoteRunner >> gtExecutingTasksFor: aView [

	<gtView>
	^ aView list
		  title: 'Executing tasks';
		  priority: 20;
		  items: [ 
			  self critical: [ currentlyExecutingTasks values ] ];
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
		  title: 'Task queue';
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
		title: 'Registered workers';
		priority: 50;
		items: [ registeredWorkers values sorted: #remoteAddressString ascending ];
		column: 'IP Address' text: [ :item | GtRemoteRunner printIpAddress: item remoteAddress ];
		column: 'Working Directory' text: [ :item | item detailAt: #workingDirectory ifAbsent: [ '' ] ];
		column: 'PID' text: [ :item | item pid ];
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

{ #category : #accessing }
GtRemoteRunner >> heartbeatForWorkerId: aUidString [
	"Register the heartbeat for the specified worker.
	If the worker isn't registered do nothing"

	registeredWorkers 
		at: aUidString
		ifPresent: [ :worker | worker registerHeartbeat ].
	^ nil
]

{ #category : #initialization }
GtRemoteRunner >> initialize [

	super initialize.
	announcer := Announcer new.
	taskQueue := SharedQueue new. "of GtRrTaskContext"
	runnerStats := GtRemoteRunnerStats new
		defaultWorkerTimeout: self workerTimeout;
		defaultTaskTimeout: self taskTimeout.
	"currentlyExecutingJobs is a dictionary of GtRrJobContext keyed by job uid"
	currentlyExecutingJobs := Dictionary new.
	"currentlyExecutingTasks is a dictionary of GtRrTaskContext keyed by task context id"
	currentlyExecutingTasks := Dictionary new.
	sharedAccess := Mutex new.
	"availableWorkers is a SortedCollection of GtRrFutureWorkerTask, sorted by #workerPriority.
	The worker is represented by a GtRrWorkerConnection and is waiting on the semaphore held by the GtRrFutureWorkerTask.
	Sort the collection ascending and remove the last item to minimise the need for repacking the collection."
	availableWorkers := SortedCollection sortUsing: #workerPriority ascending.
	registeredWorkers := Dictionary new.
	timeoutManager := GtRrTimeoutManager remoteRunner: self.
	logEmitter := GtRemoteRunnerBeaconsEmitter new.
	
	self 
		managerStartupAndShutdown: GtRrCodeSyncedLocalManagerStartupAndShutdown new;
		jobStartupAndShutdown: GtRrLocalJobStartupAndShutdown new.
]

{ #category : #accessing }
GtRemoteRunner >> isIdle [

	^ self state = #idle
]

{ #category : #testing }
GtRemoteRunner >> isRunning [
	"Answer a boolean indicating whether the receiver is considered to be running, i.e.:
	There is a server listening for workers, or
	The port is set to #none and there is at least one worker connected"

	^ (server isNotNil and: [ server isRunning ]) or:
		[ port = #none and: [ registeredWorkers isNotEmpty ] ]
]

{ #category : #accessing }
GtRemoteRunner >> jobContextForJob: aGtRrJob [
	"Answer the context for the supplied job"

	^ self critical:
		[ currentlyExecutingJobs at: aGtRrJob id ].
]

{ #category : #accessing }
GtRemoteRunner >> jobStartupAndShutdown [

	^ jobStartupAndShutdown
]

{ #category : #accessing }
GtRemoteRunner >> jobStartupAndShutdown: aGtDtsJobStartupAndShutdown [

	jobStartupAndShutdown := aGtDtsJobStartupAndShutdown.
	jobStartupAndShutdown remoteRunner: self.
	runnerStats updateJobStartupAndShutdown:  jobStartupAndShutdown.
]

{ #category : #'api - logger' }
GtRemoteRunner >> log [
	"Answer the in-memory log"

	^ log
]

{ #category : #private }
GtRemoteRunner >> logEmitter [
	^ logEmitter
]

{ #category : #'private - accessing' }
GtRemoteRunner >> logNotifier [

	^ announcementNotifier
]

{ #category : #accessing }
GtRemoteRunner >> managerStartupAndShutdown [

	^ managerStartupAndShutdown
]

{ #category : #accessing }
GtRemoteRunner >> managerStartupAndShutdown: aGtRrManagerStartupAndShutdown [
	"Set the receiver's manager.
	See also the comment in {{gtMethod:GtRemoteRunner>>#port:}}"

	managerStartupAndShutdown := aGtRrManagerStartupAndShutdown.
	managerStartupAndShutdown remoteRunner: self.
	runnerStats updateManagerStartupAndShutdown: managerStartupAndShutdown.
]

{ #category : #'api - logger' }
GtRemoteRunner >> moveLoggingTo: aFileReference [
	"Replace the receiver's logger with one that logs to the supplied file"
	| oldLogger newLogger |

	(log isNil or:
		[ log fileReference isNotNil
			and: [ log fileReference resolve = aFileReference resolve ] ])
				ifTrue: [ ^ self ].
	oldLogger := log.
	newLogger := SessionFallbackFileLogger filename: aFileReference.
	log := StreamLoggerFlusher new logger: newLogger.
	self startLogger: log.
	oldLogger stop; close.
	^ oldLogger.
]

{ #category : #'api - worker' }
GtRemoteRunner >> nextTaskForWorkerId: aUidString [
	"Answer the next task allocated to the specified worker that is waiting on this method.
	The task is assigned in a separate process."
	| taskFuture workerConnection mutexStart mutexEnd |

	GtRrNextTaskStartingSignal new emit.
	mutexStart := DateAndTime now.
	self critical:
		[ mutexEnd := DateAndTime now.
		workerConnection := registeredWorkers at: aUidString.
		workerConnection registerHeartbeat.
		taskFuture := GtRrFutureWorkerTask new 
			connection: workerConnection.
		(jobStartupAndShutdown finishedWithWorkerFuture: taskFuture) ifTrue:
			[ runnerStats updateAvailableWorkerCounts: availableWorkers.
			GtRrNextTaskCompletedSignal new
				mutexWait: (mutexEnd - mutexStart) asMilliSeconds;
				emit.
			^ 'quit' ].
		availableWorkers add: taskFuture.
		runnerStats updateAvailableWorkerCounts: availableWorkers.
		self assignTasksToWorkers ].
	taskFuture wait.
	GtRrNextTaskCompletedSignal new
		mutexWait: (mutexEnd - mutexStart) asMilliSeconds;
		taskId: taskFuture taskContext taskId;
		emit.
	^ taskFuture taskContext asWorkerTaskContext.

]

{ #category : #'api - worker' }
GtRemoteRunner >> nextTaskSerializedForWorkerId: aUidString [
	"Answer the next task allocated to the worker that is waiting on this method serialised for transmission over the wire"

	^ LeJsonV4 uniqueInstance serialize: (self nextTaskForWorkerId: aUidString)
]

{ #category : #'api - worker' }
GtRemoteRunner >> pingAllWorkers [
	"Ping each of the registered workers.
	Answer a collection of those that failed"
	| errors |

	errors := OrderedCollection new.
	registeredWorkers do: [ :worker |
		self critical:
			[ [ worker commandPing ]
				on: Error
				do: [ :ex | errors add: worker -> ex freeze ] ] ].
	^ errors
]

{ #category : #accessing }
GtRemoteRunner >> port [
	<return: #Number or: #Symbol>

	port = #none ifTrue: [ ^ port ].
	(port isNil or: [ port = 0 ]) ifTrue: 
		[ | socket |
		[ socket := Socket newTCP listenOn: 0.
		port := socket localPort ]
			ensure: [ socket closeAndDestroy ].
		self assert: port > 0
			description: 'Failed to get an unallocated port' ].
	^ port
]

{ #category : #accessing }
GtRemoteRunner >> port: aPortNumberOrSymbol [
	"Set the port number.
	0 = find a free port.
	#none = don't listen on the port (in-image workers only).
		This should be set prior to changing the manager."

	port := aPortNumberOrSymbol isSymbol 
		ifTrue: [ aPortNumberOrSymbol ]
		ifFalse: [ aPortNumberOrSymbol asNumber ].

	"If there is no listening port, ensure that the manager startup and shutdown is manual"
	port == #none ifTrue:
		[ self managerStartupAndShutdown: GtRrManualManagerStartupAndShutdown new ].
	runnerStats 
		portNumber: port;
		isRunning: self isRunning.
]

{ #category : #printing }
GtRemoteRunner >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		<< self state;
		nextPut: $).
]

{ #category : #private }
GtRemoteRunner >> privateTaskFailed: aTaskContextId executionData: aGtRrWorkerExecutionData [
	"Mark the specified task as failed and retry if required.
	Must be called within sharedAccess"
	| taskContext retryTasks registeredAvailable |

	taskContext := currentlyExecutingTasks 
		removeKey: aTaskContextId 
		ifAbsent: [ ^ self ].
	runnerStats currentlyExecutingTaskCount: currentlyExecutingTasks size.
	taskContext task executionData updateFromWorker: aGtRrWorkerExecutionData.
	retryTasks := taskContext task retryTasks.
	taskContext retryTasks: retryTasks.
	registeredAvailable := registeredWorkers isNotEmpty.
	(retryTasks isEmpty or: [ registeredAvailable not ]) ifTrue:
		[ taskContext markTaskCompleted ]
	ifFalse:
		[ self queueTasksFirst: retryTasks jobContext: taskContext jobContext ].
	self announceAndLog: taskContext taskFailedAnnouncement.
	self checkJobCompleted: taskContext.
	self assignTasksToWorkers.
]

{ #category : #private }
GtRemoteRunner >> queueTasks: retryTasks jobContext: aJobContext [ 

	aJobContext isStarted ifFalse: [ ^ self ].
	retryTasks do: [ :task |
		self addTaskContext: (GtRrTaskContext new 
			task: task;
			jobContext: aJobContext) ]
]

{ #category : #private }
GtRemoteRunner >> queueTasksFirst: retryTasks jobContext: aJobContext [ 

	aJobContext isStarted ifFalse: [ ^ self ].
	retryTasks do: [ :task |
		self addTaskContextFirst: (GtRrTaskContext new 
			task: task;
			jobContext: aJobContext) ]
]

{ #category : #accessing }
GtRemoteRunner >> registerAnnouncementsQueueForHeadlessRunner [
	"Register a queue only for certaint types of announcements. This exists as now announcements for tasks are also delivered to the the remote announcements."

	self registerAnnouncementsQueueForAnnouncementType: 
			GtRrJobAnnouncement, 
			GtRrWorkerAnnouncement,
			GtRrWorkerChangesSyncErrorAnnouncement,
			GtRrResultProcessingErrorAnnouncement,
			GtRrStatusMessageChangedAnnouncement.
]

{ #category : #accessing }
GtRemoteRunner >> registeredWorkerCount [

	^ runnerStats registeredWorkerCount
]

{ #category : #'private - debugging' }
GtRemoteRunner >> registeredWorkers [
	"Answer the registeredWorkers."

	^ self critical: [ registeredWorkers copy ].
]

{ #category : #enumerating }
GtRemoteRunner >> registeredWorkersDo: aBlock [
	"Evaluate aBlock for each of the receiver's registered workers.
	Must be called within sharedAccess."

	"sharedAccess assertIsOwner."
	registeredWorkers do: aBlock
]

{ #category : #accessing }
GtRemoteRunner >> registerJob: aGtRrJob [
	"Answer the proxy for the job when using a headless runner."

	^ aGtRrJob
]

{ #category : #'api - worker' }
GtRemoteRunner >> registerWorkerWithDetails: aDictionary [
	"Register the supplied worker and connection details.
	Register the connection for disconnection notification"
	| pharoLinkServerConnection workerConnection workerId mutexStart mutexEnd |

	GtRrRegisterWorkerStartingSignal new
		workerAttributes: aDictionary;
		emit.
	pharoLinkServerConnection := PharoLinkServerCurrentConnection value.
	pharoLinkServerConnection closeOnExec: true.
	mutexStart := DateAndTime now.
	self critical:
		[ mutexEnd := DateAndTime now.
		"If the worker specifies that it is for a particular job only accept the connection if that job is currently running"
		aDictionary at: #workerJobId
			ifPresent: 
				[:workerJobId |
				(workerJobId = 'anyJob'
					or: [currentlyExecutingJobs includesKey: workerJobId])
						ifFalse: 
							[ GtRrRegisterWorkerRejectedSignal new
								ipAddress: pharoLinkServerConnection remoteAddressString;
								workerAttributes: aDictionary;
								mutexWait: (mutexEnd - mutexStart) asMilliSeconds;
								emit.
							pharoLinkServerConnection stop.
							^self ] ].
		workerConnection := GtRrWorkerConnection
				connection: pharoLinkServerConnection
				runner: self.
		workerConnection details: aDictionary.
		workerId := aDictionary at: #id.
		aDictionary at: #workerIpAddress put: workerConnection remoteAddressString.
		registeredWorkers at: workerId put: workerConnection.
		runnerStats 
			updateRegisteredWorkerCounts: registeredWorkers;
			isRunning: self isRunning.
		managerStartupAndShutdown registerWorker: workerConnection ].
	self announceAndLog: (GtRrWorkerRegisteredAnnouncement new
				worker: workerConnection).
	GtRrRegisterWorkerCompletedSignal new
		workerAttributes: aDictionary;
		ipAddress: pharoLinkServerConnection remoteAddressString;
		mutexWait: (mutexEnd - mutexStart) asMilliSeconds;
		emit.

	"Answer a PharoLink primitive so that a proxy isn't created for the runner (which is a global, anyway)"
	^nil
]

{ #category : #'private - accessing' }
GtRemoteRunner >> removeCurrentlyExecutingJob: aJobContextId [
	"Remove the specified job from the collection of currently executing jobs.
	It's possible that the job was cancelled on the server and a worker disappears at the same time, resulting in two attempts to remove the current job.  Do nothing if the job isn't found.
	Must be called within sharedAccess."

	sharedAccess assertIsOwner.
	currentlyExecutingJobs removeKey: aJobContextId ifAbsent: [].
	runnerStats currentlyExecutingJobCount: currentlyExecutingJobs size.
]

{ #category : #private }
GtRemoteRunner >> removeQueuedTasksForWorkerId: aUidString [
	"Remove any tasks from the queue that have a single constraint on the worker Id.
	Must be called within sharedAccess.  2"

	[(taskQueue nextOrNilSuchThat: 
			[:aTaskContext |
			| constraint |
			constraint := aTaskContext task constraint.
			constraint class = GtRrEqualsConstraint
				and: [constraint attribute = #id and: [constraint value = aUidString]]])
		isNotNil]
			whileTrue.
	runnerStats taskQueueSize: taskQueue size.
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> removeSubscription: subscription [
	"Remove the given subscription from the receiver"

	^ self announcer removeSubscription: subscription
]

{ #category : #'api - logger' }
GtRemoteRunner >> replaceLogger [
	"Replace the receiver's logger and answer the old one"
	| oldLogger |

	log ifNil: [ ^ nil ].
	oldLogger := log.
	log := nil.
	self startLogging.
	oldLogger stop; close.
	^ oldLogger.
]

{ #category : #phases }
GtRemoteRunner >> runJobShutdown [
	"Perform any actions associated with stopping the job manager"

	self terminateAllJobs.
	jobStartupAndShutdown shutdown
]

{ #category : #phases }
GtRemoteRunner >> runJobStartup [
	"Perform any actions associated with starting the job manager"

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
GtRemoteRunner >> runnerStats [

	^ runnerStats
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

	self runManagerStartup.
	self runJobStartup.
	runnerStats isRunning: self isRunning.
]

{ #category : #'api - logger' }
GtRemoteRunner >> startAnnouncementsNotifier [
	"Start the receiver's in-memory log"

	announcementNotifier ifNotNil: [ ^ self ].
	announcementNotifier := GtAnnouncementNotifier new
		addAnnouncer: self announcer;
		addAllWatching: self class defaultWatchedAnnouncements.
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
	runnerStats currentlyExecutingJobCount: currentlyExecutingJobs size.
	jobStartupAndShutdown startupJob: context.
	
	self announceAndLog: (GtRrJobStartedAnnouncement job: aGtRrJob).
	self announceStatusMessageWithString: 'Running tests - Job started, awaiting workers'.
		
	self assignTasksToWorkers.
	
	"If there are problems during submission the job will be marked with an error and the context should show isFinished."
	self checkJobCompleted: context.
]

{ #category : #'api - logger' }
GtRemoteRunner >> startLogger: aLogger [

	aLogger startFor: GtRemoteRunnerAnnouncement, GtRemoteRunnerSignal, StringSignal.
]

{ #category : #'api - logger' }
GtRemoteRunner >> startLogging [
	"Start the receiver's in-memory log"

	log ifNotNil: [ ^ self ].
	log := MemoryLogger new.
	self startLogger: log.
]

{ #category : #ui }
GtRemoteRunner >> state [
	"Answer a label that represents the overall state of the runner"

	^ runnerStats state
]

{ #category : #'api - runner' }
GtRemoteRunner >> stop [

	self stopRegisteredWorkers.
	self runJobShutdown.
	self runManagerShutdown.
	self stopTimeoutManager.
	self stopLogging.
	self stopAnnouncementNotifier.
	runnerStats isRunning: self isRunning.
]

{ #category : #'api - runner' }
GtRemoteRunner >> stopAndQuit [
	"This is called by the remote runner proxy as part of a two step shut down sequence"

	self runManagerShutdown.
	self stopLogging.
	self stopAnnouncementNotifier.
	SmalltalkImage current snapshot: false andQuit: true.
]

{ #category : #'api - logger' }
GtRemoteRunner >> stopAnnouncementNotifier [

	announcementNotifier ifNil: [ ^ self ].
	announcementNotifier stop.
	announcementNotifier := nil.
]

{ #category : #'api - logger' }
GtRemoteRunner >> stopLogging [
	"Stop the receiver's in-memory log"

	log ifNil: [ ^ self ].
	log stop; close.
	log := nil.
]

{ #category : #'api - runner' }
GtRemoteRunner >> stopRegisteredWorkers [
	"Stop all registered workers.
	Must be called within sharedAccess."
	
	GtRrStopRegisteredWorkersStartingSignal new
		registeredWorkerCount: registeredWorkers size;
		emit.
	self registeredWorkersDo: #stop.
	"The stats will be updated when the worker is unregistered, so this isn't strictly necessary."
	runnerStats
		updateRegisteredWorkerCounts: registeredWorkers;
		isRunning: self isRunning.
	GtRrStopRegisteredWorkersCompletedSignal new
		registeredWorkerCount: registeredWorkers size;
		emit.
]

{ #category : #'api - logger' }
GtRemoteRunner >> stopTimeoutManager [
	"Stop the receiver's timeout manager"

	timeoutManager stop.
]

{ #category : #'api - jobs' }
GtRemoteRunner >> submitJob: aGtRrJob [
	"Add the supplied job to the queue.
	Start execution as soon as possible"

	self critical: [ self startJob: aGtRrJob ].
	^ aGtRrJob
]

{ #category : #'api - jobs' }
GtRemoteRunner >> submitJobFromProxy: aGtRrJob [
	"Add the supplied job to the queue.
	Start execution as soon as possible.
	Register the announcement queue for the job."

	aGtRrJob registerAnnouncementsQueue.
	^ self submitJob: aGtRrJob.
]

{ #category : #'api - jobs' }
GtRemoteRunner >> submitSerializedJob: aGtRrJobString [
	"Submit the supplied job after deserialising it, and enable a queue for it"

	| job |
	job := LeJsonV4 uniqueInstance 
		deserialize: aGtRrJobString readStream.
		
	"Register an announcements queue here before submitting the job.
	We do this to not loose announcements if the job executes fast."
	job registerAnnouncementsQueue.
	
	^ self submitJob: job
]

{ #category : #ui }
GtRemoteRunner >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream
			nextPut: { #State. runnerStats state. self. };
			nextPut: { 'Total Job Count'. runnerStats totalJobCount. self. };
			nextPut: { 'Total Task Count'. runnerStats totalTaskCount. self. };
			nextPut: {'Task Queue Size'. runnerStats taskQueueSize. taskQueue. };
			nextPut: {'Registered Workers'. runnerStats registeredWorkerCount. registeredWorkers. };
			nextPut: {'Available Workers'. runnerStats availableWorkerCount. availableWorkers. };
			nextPut: {'Currently Executing Jobs'. runnerStats currentlyExecutingJobCount. currentlyExecutingJobs. };
			nextPut: {'Currently Executing Tasks'. runnerStats currentlyExecutingTaskCount. currentlyExecutingTasks. };
			nextPut: { 'Default Worker Timeout'. runnerStats defaultWorkerTimeout. self. };
			nextPut: { 'Default Task Timeout'. runnerStats defaultTaskTimeout. self. };
			nextPut: { #Port. port. server. };
			nextPut: { #Logging. log isNotNil. log. };
			nextPut: { 'Shared Access Waiting'. runnerStats sharedAccessCount. sharedAccess. } ]
]

{ #category : #printing }
GtRemoteRunner >> summaryString [

	^ String streamContents: [ :stream |
		stream << 'RemoteRunner Summary:'; cr.
		self summaryAttributes do: [ :tuple |
			stream
				<< (tuple first padRightTo: 30);
				<< (tuple second printString padLeftTo: 20);
				cr ] ]
]

{ #category : #'code sync' }
GtRemoteRunner >> syncChanges [
	"Send changes from the current image to the remote runner.
	Provided for compatibility with {{gtClass:PlpoGtRemoteRunner}}.
	In this case the remote runner is in the same image as the user, so no sync required."

]

{ #category : #'api - worker' }
GtRemoteRunner >> taskDone: aTaskContextId executionData: aGtRrWorkerExecutionData result: aResult [
	| mutexStart mutexEnd |

	GtRrTaskDoneStartingSignal new 
		taskId: aTaskContextId;
		emit.
	mutexStart := DateAndTime now.
	self critical: 
		[ | taskContext |
		mutexEnd := DateAndTime now.
		taskContext := currentlyExecutingTasks removeKey: aTaskContextId ifAbsent: [].
		"If the task hasn't been found, assumed that it was terminated and move on"
		taskContext ifNotNil: [ | retryTasks |
			taskContext workerConnection registerHeartbeat.
			runnerStats currentlyExecutingTaskCount: currentlyExecutingTasks size.
			taskContext task executionData updateFromWorker: aGtRrWorkerExecutionData.
			taskContext result: aResult.
			retryTasks := taskContext task retryTasks.
			taskContext retryTasks: retryTasks.
			taskContext markTaskCompleted.
			(retryTasks isNotEmpty and: [ registeredWorkers isNotEmpty ]) ifTrue:
				[ self queueTasksFirst: retryTasks jobContext: taskContext jobContext ].
			self announceAndLog: taskContext taskCompletedAnnouncement.
			self checkJobCompleted: taskContext ].
		self assignTasksToWorkers. ].

	GtRrTaskDoneCompletedSignal new
		mutexWait: (mutexEnd - mutexStart) asMilliSeconds;
		taskId: aTaskContextId;
		emit.

	"There is no useful result, avoid having to create proxies, etc."
	^ nil.
]

{ #category : #'api - worker' }
GtRemoteRunner >> taskFailed: aTaskContextId executionData: aGtRrWorkerExecutionData [
	"Mark the specified task as failed"

	GtRrWorkerTraceAnnouncement new
		message: 'taskFailed:with: pre ', aTaskContextId asString;
		emit.
	self critical: 
		[ self privateTaskFailed: aTaskContextId executionData: aGtRrWorkerExecutionData ].
	GtRrWorkerTraceAnnouncement new
		message: 'taskFailed:with: post ', aTaskContextId asString;
		emit.

	"There is no useful result, avoid having to create proxies, etc."
	^ nil.
]

{ #category : #'private - accessing' }
GtRemoteRunner >> taskQueue [
	"Answer the taskQueue.
	Must be called with shared access."

	^ taskQueue
]

{ #category : #accessing }
GtRemoteRunner >> taskTimeout [

	^ taskTimeout ifNil: [ taskTimeout := self defaultTaskTimeout ]
]

{ #category : #accessing }
GtRemoteRunner >> taskTimeout: anObject [

	taskTimeout := anObject.
	runnerStats defaultTaskTimeout: taskTimeout.
]

{ #category : #accessing }
GtRemoteRunner >> terminateAllJobs [
	"Terminate all the currently executing jobs"
	| jobIds |

	jobIds := self critical:
		[currentlyExecutingJobs values collect: #id ].
	jobIds do: [ :id | self terminateJobId: id ].
]

{ #category : #'api - jobs' }
GtRemoteRunner >> terminateJobId: aJobId [
	"Terminate the specified job.
	If it has been started, it will be marked completed with errors."
	<return: #GtRrJob>
	| jobContext |

	self critical:
		[ jobContext := currentlyExecutingJobs 
			at: aJobId 
			ifPresent: [ :aJobContext | 
				currentlyExecutingJobs removeKey: aJobId.
				aJobContext ]
			ifAbsent: [ ].
		runnerStats currentlyExecutingJobCount: currentlyExecutingJobs size.
		jobContext ifNil: [ ^ nil ].
		self emptyQueuesFor: aJobId.
		jobContext terminateJob ].

	self announceAndLog: (GtRrJobTerminatedAnnouncement job: jobContext job).
	^ jobContext job

]

{ #category : #private }
GtRemoteRunner >> terminateJobsOnNoWorkers [
	"If managerStartupAndShutdown and jobStartupAndShutdown allow, and there are no workers,
	terminate any jobs that are running (as no workers are expected in future)"

	(managerStartupAndShutdown shouldTerminateJobsOnNoWorkers and:
		[ jobStartupAndShutdown shouldTerminateJobsOnNoWorkers ]) ifFalse:
			[ ^ self ].
	self critical:
		[ registeredWorkers ifEmpty:
			[ currentlyExecutingJobs do: [ :each |
				self terminateJobId: each jobId ] ] ].
]

{ #category : #private }
GtRemoteRunner >> terminateTaskContextId: aTaskContextId [
	"Terminate the specified currently executing task"

	self critical:
		[ currentlyExecutingTasks at: aTaskContextId ifPresent:
			[ :taskContext | taskContext terminateTask ].
		(taskQueue nextOrNilSuchThat: [ :each | each taskContextId = aTaskContextId ])
			ifNotNil: [ :taskContext | taskContext terminateTask ].
		runnerStats taskQueueSize: taskQueue size ].
]

{ #category : #accessing }
GtRemoteRunner >> timeoutManager [

	^ timeoutManager
]

{ #category : #'api - worker' }
GtRemoteRunner >> unregisterWorkerId: aUidString reason: aString [
	| terminatedWorkers failedTasks errorDetails workerConnection |

	self critical: 
		[workerConnection := registeredWorkers 
			removeKey: aUidString
			ifAbsent: 
				[StringSignal
					emit: 'Unable to properly unregister worker ' , aUidString asString
						, ' due to reason ' , aString asString.
				nil].
		runnerStats 
			updateRegisteredWorkerCounts: registeredWorkers;
			isRunning: self isRunning.
		terminatedWorkers := availableWorkers select: [ :workerFuture | 
			workerFuture connection = workerConnection].
		terminatedWorkers do: [:workerFuture | workerFuture terminateProcess].
		availableWorkers removeAll: terminatedWorkers.
		runnerStats updateAvailableWorkerCounts: availableWorkers.
		failedTasks := currentlyExecutingTasks
					select: [:each | each connection = workerConnection].
		failedTasks valuesDo: [ :taskContext |
			errorDetails := (GtRrErrorDetails new)
				errorMessage: 'Worker Unregistered: ' , aString printString;
				setTrace.
			self privateTaskFailed: taskContext taskContextId
				executionData: (GtRrWorkerExecutionData new errorDetails: errorDetails)].
		self removeQueuedTasksForWorkerId: aUidString. 
		"self terminateJobsOnNoWorkers" ].
	workerConnection
		ifNotNil: 
			[self announceAndLog: ((GtRrWorkerUnregisteredAnnouncement new)
						worker: workerConnection;
						reason: aString)]
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	^ self announcer unsubscribe: anObject
]

{ #category : #'private - debugging' }
GtRemoteRunner >> updateStats [
	"Update all attributes of the stats object.
	Answer the stats pre- and post-update.
	For debugging purposes."
	| pre post |

	self critical:
		[ pre := runnerStats copy.
		runnerStats
			updateRegisteredWorkerCounts: registeredWorkers;
			currentlyExecutingJobCount: currentlyExecutingJobs size;
			currentlyExecutingTaskCount: currentlyExecutingTasks size;
			taskQueueSize: taskQueue size;
			updateAvailableWorkerCounts: availableWorkers;
			sharedAccessCount: sharedAccess size;
			portNumber: port;
			isRunning: self isRunning;
			defaultTaskTimeout: taskTimeout;
			defaultWorkerTimeout: workerTimeout.
		post := runnerStats copy ].
	^ { pre. post. }
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

		^ self announcer weak when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : #'announcer - subscription' }
GtRemoteRunner >> when: anAnnouncementClass send: aSelector to: anObject for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector."

	^ (self when: anAnnouncementClass send: aSelector to: anObject) subscriber: aSubscriber.
]

{ #category : #accessing }
GtRemoteRunner >> workerResultProcessingError: errorDetails workerId: workerId taskContextId: taskContextId [
	"The worker received an error while the receiver was processing results.
	Log the error."

	self announceAndLog: (GtRrResultProcessingErrorAnnouncement new
		workerId: workerId;
		errorDetails: errorDetails).
	currentlyExecutingTasks
		at: taskContextId
		ifPresent: [ :taskContext |
			self taskFailed: taskContextId executionData: (GtRrWorkerExecutionData new
				errorDetails: errorDetails) ].
]

{ #category : #accessing }
GtRemoteRunner >> workerTimeout [

	^ workerTimeout ifNil: [ workerTimeout := self defaultWorkerTimeout ]
]

{ #category : #accessing }
GtRemoteRunner >> workerTimeout: anObject [

	workerTimeout := anObject.
	runnerStats defaultWorkerTimeout: workerTimeout.
]
