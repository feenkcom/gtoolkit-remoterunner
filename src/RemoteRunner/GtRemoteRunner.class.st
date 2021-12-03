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


The main components of the system are:

- GtRemoteRunner provides the primary interface to the system and the main control.
- A {{gtClass:GtRrWorker}} is created for each client image that will run tests or examples.
- A {{gtClass:GtRrJob}} is submitted by users for each collection or tests or examples to be executed.  The user will be notified of the progress of the job.
- {{gtClass:GtRrTaskScheduler}} is responsible for taking all the tests / examples in a job and ordering and grouping them for equitable distribution amongst the workers.


The following phases are defined as part of the system.  Each of these phases is pluggable, so can be customised for individual scenarios:

- Manager Startup: this is run once when the manager starts.  It may be used to start worker machines, etc.
- Job Startup: this may include starting the worker images on the worker machines.
- Job Execution: the phase where tests / examples are being handed out to the workers.
- Job Shutdown: this may include stopping the worker images on the worker machines.
- Manager shutdown: this is run once when the manager is stopped.  It may be used to shut down worker machines, etc.


The worker images are assumed to be up to date when the Job Execution phase is run.

Futures:

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
		'taskScheduler',
		'jobExecutor',
		'jobStartupAndShutdown',
		'managerStartupAndShutdown',
		'availableWorkers',
		'jobQueue',
		'currentlyExecutingJobs',
		'taskPromises',
		'sharedAccess',
		'registeredWorkers'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #initialization }
GtRemoteRunner >> initialize [

	super initialize.
	port := 7042.
	jobQueue := SharedQueue new.
	currentlyExecutingJobs := OrderedDictionary new.
	sharedAccess := Semaphore forMutualExclusion.
	availableWorkers := Set new.
	registeredWorkers := Set new.
	taskPromises := Dictionary new.
	self 
		taskScheduler: GtRrOneAtATimeTaskScheduler new;
		managerStartupAndShutdown: GtDtsLocalManagerStartupAndShutdown new;
		jobStartupAndShutdown: GtDtsLocalJobStartupAndShutdown new;
		jobExecutor: GtRrJobExecutor new.

]

{ #category : #accessing }
GtRemoteRunner >> jobExecutor [

	^ jobExecutor
]

{ #category : #accessing }
GtRemoteRunner >> jobExecutor: aGtRrJobExecutor [

	jobExecutor := aGtRrJobExecutor
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
	| taskFuture task taskPromise |

	taskFuture := GtRrFutureWorkerTask new platform: aPlatform.
	taskFuture wait.
	task := taskFuture task.
	taskPromise := AsyncPendingPromise new.
	sharedAccess critical:
		[ taskPromises at: task id put: taskPromise ].
	^ task
]

{ #category : #'api - worker' }
GtRemoteRunner >> nextTaskFor: aWorkerId platform: aPlatform [
	"Answer the next task allocated to the worker that is waiting on this method.
	The task is assigned in a separate process."
	| taskFuture task taskPromise |

	taskFuture := GtRrFutureWorkerTask new 
		workerId: aWorkerId;
		platform: aPlatform.
	sharedAccess critical:
		[ availableWorkers add: taskFuture.
		self assignTasksToWorkers ].
	taskFuture wait.
	task := taskFuture task.
	taskPromise := AsyncPendingPromise new.
	sharedAccess critical:
		[ taskPromises at: task id put: taskPromise ].
	^ task
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

{ #category : #'api - worker' }
GtRemoteRunner >> registerWorkerWithPlatform: aPlatform [
	"Register the supplied worker and connection details.
	Register the connection for disconnection notification"
]

{ #category : #initialization }
GtRemoteRunner >> resetImagesFilesOnS3 [
	remoteHostCluster
		runCommand: 'powershell.exe'
		arguments: (Array
				with: '-File'
				with: 'C:\Users\Administrator\git\lifeware-source\Reset-LifewareWorkerImage.ps1'
				with: '-region'
				with: 'us-east-1')
		named: 'AWS: RESET IMAGES FILES ON S3'
]

{ #category : #'as yet unclassified' }
GtRemoteRunner >> restartRemoteCluster [
	"managerConfiguration startRemoteImages ifFalse: [^self].
	remoteHostCluster isAwsHost ifFalse: [^self].
	timestampsCollector registerNowAs: #beginRestartRemoteAwsCluster."
	self resetImagesFilesOnS3.
	"timestampsCollector registerNowAs: #resetImagesFilesOnS3."
	self stopRemoteAwsMachines.
	"timestampsCollector registerNowAs: #stoppedRemoteAwsMachines."
	self startRemoteAwsMachines.
	"timestampsCollector registerNowAs: #startedRemoteAwsMachines"
]

{ #category : #phases }
GtRemoteRunner >> runJobExecution [
	"Actually run all the tests"

	jobExecutor run
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

	context := GtRrJobContext new job: aGtRrJob.
	currentlyExecutingJobs
		at: aGtRrJob uid
		put: context.
	jobStartupAndShutdown startupForJob: context.
	self assignTasksToWorkers.
]

{ #category : #'as yet unclassified' }
GtRemoteRunner >> startRemoteAwsMachines [
	remoteHostCluster
		runCommand: 'go.exe'
		arguments: #('run'
			'C:\Users\Administrator\git\lifeware-source\startstop.go'
			'-region'
			'us-east-1'
			'-action'
			'START'
			'-instancescount'
			'50')
		named: 'AWS: START WORKER MACHINES'
]

{ #category : #'api - runner' }
GtRemoteRunner >> stop [

	self runManagerShutdown
]

{ #category : #snapshot }
GtRemoteRunner >> stopRemoteAwsMachines [
	remoteHostCluster
		runCommand: 'go.exe'
		arguments: (Array
				with: 'run'
				with: 'C:\Users\Administrator\git\lifeware-source\startstop.go'
				with: '-region'
				with: 'us-east-1'
				with: '-action'
				with: 'STOP')
		named: 'AWS: STOP LEFTOVER WORKER MACHINES'
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

{ #category : #accessing }
GtRemoteRunner >> taskScheduler [

	^ taskScheduler
]

{ #category : #accessing }
GtRemoteRunner >> taskScheduler: aGtRrTaskScheduler [

	taskScheduler := aGtRrTaskScheduler.
	taskScheduler remoteRunner: self.
]
