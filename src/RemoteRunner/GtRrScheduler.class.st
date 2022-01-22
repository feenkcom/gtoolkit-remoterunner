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
	#name : #GtRrScheduler,
	#superclass : #Object,
	#traits : 'TTaskScheduler',
	#classTraits : 'TTaskScheduler classTrait',
	#instVars : [
		'server',
		'announcer',
		'log',
		'environment',
		'sharedAccess',
		'executors',
		'jobWorker',
		'taskQueue',
		'timeoutQueue'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #cleanup }
GtRrScheduler class >> cleanUniqueInstance [

	uniqueInstance ifNotNil: [ :anInstance | 
		self onRemoveUniqueInstance: anInstance ].
	uniqueInstance := nil.
]

{ #category : #cleanup }
GtRrScheduler class >> cleanUp [

	self cleanUniqueInstance
]

{ #category : #accessing }
GtRrScheduler class >> default [

	^ self uniqueInstance
]

{ #category : #testing }
GtRrScheduler class >> hasUniqueInstance [

	^ uniqueInstance isNotNil.
]

{ #category : #accessing }
GtRrScheduler class >> instance [
	<gtExample>

	^ self uniqueInstance
]

{ #category : #'as yet unclassified' }
GtRrScheduler class >> manual [

	^ self new
		  environment: GtRrManualEnvironment new;
		  start;
		  yourself
]

{ #category : #'private - hooks' }
GtRrScheduler class >> onRemoveUniqueInstance: anInstance [
	"Classes may perform some activities on a singleton that is about to be released"

	uniqueInstance stop.
]

{ #category : #printing }
GtRrScheduler class >> printIpAddress: aByteArray [
	"Answer the usual dot notation of the supplied IPv4 address"

	aByteArray ifNil: [ ^ '<none>' ].

	self assert: aByteArray size equals: 4.

	^ String streamContents: [ :stream |
		aByteArray printOn: stream delimiter: '.' ]
]

{ #category : #accessing }
GtRrScheduler class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new start ]
]

{ #category : #announcer }
GtRrScheduler >> announce: anAnnouncement [

	^ self announcer announce: anAnnouncement
]

{ #category : #announcer }
GtRrScheduler >> announceAndLog: aBeaconSignal [
	"Announce the supplied signal to the receiver's announcer and then emit the signal for logging"

	self announce: aBeaconSignal.
	aBeaconSignal emit.
]

{ #category : #announcer }
GtRrScheduler >> announcer [

	^ announcer
]

{ #category : #'_shady' }
GtRrScheduler >> applyCodeChanges: aCollection [

	| errors serialized drainer futures |
	serialized := LanguageLinkUtils base64Encode: aCollection.
	drainer := TKTWorkerPool new
		           name: 'CodeSync parallel';
		           poolMaxSize: 32;
		           start;
		           yourself.
	errors := OrderedCollection new.
	futures := executors
		           select: [ :executor | 
		           executor attributes includesKey: #codeSynced ]
		           thenCollect: [ :executor | 
			           drainer
				           future: [ 
					           [ executor commandApplyCodeChanges: serialized ]
						           on: Error
						           do: [ :ex | errors add: executor -> ex freeze ] ]
				           timeout: 1 minute ].
	futures do: [ :e | e waitForCompletion: 1 minute ].
	drainer stop.
	^ errors
]

{ #category : #'api - worker' }
GtRrScheduler >> connectWithAttributes: aDictionary observer: aBlock [

	"Register the supplied worker and connection details.
	Register the connection for disconnection notification"

	| connection executor |
	connection := PharoLinkServerCurrentConnection value.
	executor := GtRrExecutor
		            connection: connection
		            attributes: aDictionary
		            observer: aBlock
		            timeoutQueue: timeoutQueue.
	sharedAccess critical: [ executors at: connection put: executor ].
	connection
		when: PharoLinkServerConnectionDisconnectedAnnouncement
		send: #disconnect:
		to: self.
	self announceAndLog:
		(GtRrWorkerConnectedAnnouncement worker: executor).
	executor
		commandConnected;
		waitOnObserver
]

{ #category : #'api - worker' }
GtRrScheduler >> currentExecutor [

	^ sharedAccess critical: [ 
		  executors at: PharoLinkServerCurrentConnection value ]
]

{ #category : #accessing }
GtRrScheduler >> debugMode [
	"Answer a boolean indicating whether debug logging should be started.
	Always true during development.  Settings TBD."

	^ true.
]

{ #category : #'api - worker' }
GtRrScheduler >> disconnect: aPharoLinkServerConnectionDisconnectedAnnouncement [

	| connection executor |
	connection := aPharoLinkServerConnectionDisconnectedAnnouncement
		              connection.
	executor := sharedAccess critical: [ 
		            executors removeKey: connection ifAbsent: [ nil ] ].
	executor ifNotNil: #stop.
	self announceAndLog: (GtRrWorkerDisconnectedAnnouncement new
			 worker: executor;
			 reason: 'Worker connection lost')
]

{ #category : #accessing }
GtRrScheduler >> environment [

	^ environment
]

{ #category : #accessing }
GtRrScheduler >> environment: anEnvironment [

	environment := anEnvironment.
	environment remoteRunner: self.
]

{ #category : #accessing }
GtRrScheduler >> executorsSize [

	^ sharedAccess critical: [ executors size ]
]

{ #category : #schedulling }
GtRrScheduler >> future: aTask [

	^ self future: aTask timeout: aTask timeout
]

{ #category : #schedulling }
GtRrScheduler >> futureExecutionFor: aTask [

	^ self futureExecutionFor: aTask timeout: aTask timeout
]

{ #category : #schedulling }
GtRrScheduler >> futureExecutionFor: aTask timeout: aTimeout [

	^ GtRrExecutorFutureExecution new
		  runner: self;
		  task: aTask;
		  timeout: aTimeout;
		  yourself
]

{ #category : #'as yet unclassified' }
GtRrScheduler >> futureJob: aJob [

	^ self futureJob: aJob timeout: aJob timeout
]

{ #category : #'as yet unclassified' }
GtRrScheduler >> futureJob: aJob timeout: aTimeout [

	^ jobWorker future: aJob timeout: aTimeout
]

{ #category : #ui }
GtRrScheduler >> gtExecutingTasksFor: aView [

	<gtView>
	^ aView list
		  title: 'Executing Tasks';
		  priority: 20;
		  items: [ 
			  sharedAccess critical: [ 
					  executors select: #isBusy thenCollect: #currentTask ] ];
		  send: [ :item | item ];
		  updateWhen: GtRrAnnouncement in: [ self announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrScheduler >> gtExecutorsFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Executors';
		  priority: 50;
		  items: [ executors values ];
		  column: 'IP Address' text: [ :item | GtRrScheduler printIpAddress: item remoteAddress ];
			column: 'Working Directory' text: [ :item | item attributes at: #workingDirectory ifAbsent: [ '' ] ];
		  column: 'Platform' text: [ :item | item attributes at: #platform ];
		  actionUpdateButton
]

{ #category : #accessing }
GtRrScheduler >> gtLogFor: aView [

	<gtView>
	log ifNil: [ ^ aView empty ].
	^ aView forward
		  title: 'Log' translated;
		  priority: 20;
		  object: [ log ];
		  view: #gtRecordingsFor:
]

{ #category : #ui }
GtRrScheduler >> gtPingActionFor: anAction [
	<gtAction>

	^ anAction button
		icon: BrGlamorousVectorIcons signal;
		tooltip: 'Ping all workers';
		action: [ :button | button phlow spawnObject: self pingAllWorkers ]
]

{ #category : #ui }
GtRrScheduler >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item third ];
		  updateWhen: GtRrAnnouncement in: [ self announcer ];
			actionUpdateButton 
]

{ #category : #announcer }
GtRrScheduler >> hasSubscriber: anObject [

	^ self announcer hasSubscriber: anObject
]

{ #category : #initialization }
GtRrScheduler >> initialize [

	super initialize.
	announcer := Announcer new.
	server := PharoLinkServer new
		          listenPort: 7042;
		          setDebugMode;
		          yourself.
	server globals at: #GtAssignedRemoteRunner put: self.
	jobWorker := TKTWorker new.
	taskQueue := SharedQueue new.
	timeoutQueue := BlTaskAtQueue new.
	"Make sure you REALLY know what you're doing before changing sharedAccess to a Monitor.
	PharoLinkServer requests are handled in individual processes, so any deadlock is unlikely to be resolved by converting sharedAccess to a Monitor."
	sharedAccess := GtMutualExclusionSemaphore forMutualExclusion.
	executors := Dictionary new.
	self environment: GtRrCodeSyncedLocalEnvironment new
]

{ #category : #'api - logger' }
GtRrScheduler >> log [
	"Answer the in-memory log"

	^ log
]

{ #category : #'api - worker' }
GtRrScheduler >> pingAllWorkers [
	"Ping each of the registered workers.
	Answer a collection of those that failed"
	| errors |

	errors := OrderedCollection new.
	executors do: [ :executor |
		sharedAccess critical:
			[ [ executor commandPing ]
				on: Error
				do: [ :ex | errors add: executor -> ex freeze ] ] ].
	^ errors
]

{ #category : #accessing }
GtRrScheduler >> port [

	^ server listenPort
]

{ #category : #printing }
GtRrScheduler >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		<< self state;
		nextPut: $).
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> removeSubscription: subscription [
	"Remove the given subscription from the receiver"

	^ self announcer removeSubscription: subscription
]

{ #category : #schedulling }
GtRrScheduler >> schedule: aTask [

	^ self schedule: aTask timeout: aTask timeout
]

{ #category : #schedulling }
GtRrScheduler >> scheduleTaskExecution: aTaskExecution [

	aTaskExecution task execution: aTaskExecution.
	taskQueue nextPut: aTaskExecution
]

{ #category : #schedulling }
GtRrScheduler >> scheduleTimeout: aTimeout on: aTaskExecution [

	"release the task execution, check later"

	| weak |
	weak := aTaskExecution asWeakReference.
	timeoutQueue
		schedule: [ 
			weak first ifNotNil: [ :taskExecution | 
				taskExecution isFinished ifFalse: [ 
					taskExecution terminateWithReason:
						'Timeout after: ' , aTimeout asString ] ] ]
		at: DateAndTime now + aTimeout
]

{ #category : #'api - runner' }
GtRrScheduler >> start [

	server start.
	timeoutQueue start.
	jobWorker start.
	environment start
]

{ #category : #'api - logger' }
GtRrScheduler >> startLogging [
	"Start the receiver's in-memory log"

	log ifNotNil: [ ^ self ].
	log := CircularMemoryLogger new startFor: GtRrAnnouncement.
]

{ #category : #ui }
GtRrScheduler >> state [

	"Answer a label that represents the overall state of the runner.
	Must be called within sharedAccess"

	| queuedTaskCount currentTaskCount |
	(server isNil or: [ server isRunning not ]) ifTrue: [ ^ #stopped ].
	queuedTaskCount := taskQueue size.
	currentTaskCount := executors count: #isBusy.
	(executors isEmpty = 0 and: [ 
		 queuedTaskCount > 0 or: [ currentTaskCount > 0 ] ]) ifTrue: [ 
		^ #stuck ].
	(queuedTaskCount = 0 and: [ currentTaskCount = 0 ]) ifTrue: [ 
		^ #idle ].
	(queuedTaskCount > 0 or: [ currentTaskCount > 0 ]) ifTrue: [ ^ #busy ].
	self error: 'Unknown state'
]

{ #category : #'api - runner' }
GtRrScheduler >> stop [

	environment stop.
	jobWorker stop.
	timeoutQueue stop.
	server stop
]

{ #category : #ui }
GtRrScheduler >> summaryAttributes [

	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream | 
		  sharedAccess critical: [ 
			  stream
				  nextPut: { 
						  #State.
						  self state.
						  self state };
				  nextPut: { 
						  'Tasks'.
						  taskQueue size.
						  taskQueue };
				  nextPut: { 
						  'Executors'.
						  executors size.
						  executors };
				  nextPut: { 
						  'Executing Tasks'.
						  (executors count: #isBusy).
						  (executors select: #isBusy thenCollect: #currentTask) };
				  nextPut: { 
						  #Server.
						  server listenPort.
						  server } ].
		  stream nextPut: { 
				  'Shared Access Waiting'.
				  sharedAccess size.
				  sharedAccess } ]
]

{ #category : #'api - worker' }
GtRrScheduler >> task: aTaskId failure: anObject [

	^ self currentExecutor task: aTaskId failure: anObject
]

{ #category : #'api - worker' }
GtRrScheduler >> task: aTaskId success: anObject [

	^ self currentExecutor task: aTaskId success: anObject
]

{ #category : #schedulling }
GtRrScheduler >> taskExecutionFor: aTask [

	^ self taskExecutionFor: aTask timeout: aTask timeout
]

{ #category : #schedulling }
GtRrScheduler >> taskExecutionFor: aTask timeout: aTimeout [

	^ GtRrExecutorTaskExecution new
		  runner: self;
		  task: aTask;
		  timeout: aTimeout;
		  yourself
]

{ #category : #'api - worker' }
GtRrScheduler >> taskNext [

	"Answer the next task allocated to the worker that is waiting on this method."

	| executor taskExecution task |
	executor := self currentExecutor.
	taskExecution := taskQueue gtRrNextSuchThat: [ :e | 
		                 e task constraint matches: executor attributes ].
	task := taskExecution task.
	executor scheduleTaskExecution: taskExecution.
	^ task
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	^ self announcer unsubscribe: anObject
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> weak [
	"announcer weak subscribe: foo"

	^ self announcer weak
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> when: anAnnouncementClass do: aValuable [
	"Declare that when anAnnouncementClass is raised, aValuable is executed.  Pay attention that ushc method as well as when:do: should not be used on weak announcer since the block holds the receiver and more strongly."

	^ self announcer when: anAnnouncementClass do: aValuable
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> when: anAnnouncementClass do: aValuable for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, aValuable is executed and define the subscriber."

	^ (self when: anAnnouncementClass do: aValuable) subscriber: aSubscriber; yourself.
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> when: anAnnouncementClass doOnce: aValuable for: aSubscriber [
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
GtRrScheduler >> when: anAnnouncementClass send: aSelector to: anObject [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector.
    When the message expects one argument (eg #fooAnnouncement:) the announcement is passed as argument.
    When the message expects two arguments (eg #fooAnnouncement:announcer:) both the announcement and the announcer 
    are passed as argument"

		^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : #'announcer - subscription' }
GtRrScheduler >> when: anAnnouncementClass send: aSelector to: anObject for: aSubscriber [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector."

	^ (self when: anAnnouncementClass send: aSelector to: anObject) subscriber: aSubscriber.
]
