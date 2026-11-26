Class {
	#name : #GtRrWorkerManagerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> connectionWithWorkerIndex: aString [

	^ GtRrWorkerConnection new
		attributes: (GtStringContentDictionary new
			at: #gtRrWorkerIndex put: aString;
			yourself)
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> exitedProcesses: anInteger [

	^ (1 to: anInteger) collect: [ :each |
		GtRrWorkerManagerExampleProcess new
			id: each;
			isRunning: false;
			yourself ]
]

{ #category : #examples }
GtRrWorkerManagerExamples >> failedStartsAreFailures [
	"A worker whose process can't even be started is a failure, the error doesn't reach the watchdog.
	An attempt to start several workers stops at the first failure, so that it is counted once"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager |
	workerManager := self workerManagerWithPoolSize: 2.
	workerManager
		remoteIpAddress: 0;
		changesSync: false.
	workerManager settings serverExecutable: FileLocator temp / 'GtRrNoSuchExecutable.exe'.
	workerManager remoteRunner critical: [ workerManager addWorkers: 2 ].
	self assert: workerManager failures size equals: 1.
	workerManager remoteRunner critical: [ 
		workerManager addWorkers: 2.
		workerManager addWorkers: 2 ].
	self assert: workerManager processes isEmpty.
	self assert: workerManager failures size equals: 3.
	self assert: workerManager restartsStopped.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> failuresStopRestarts [
	"Workers that exit without being stopped by the runner are failures.
	Restarts stop, and this is announced, once the failures within the failure window reach the limit"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager announcements now |
	workerManager := self workerManagerWithPoolSize: 2.
	announcements := OrderedCollection new.
	workerManager remoteRunner
		when: GtRrWorkerRestartsStoppedAnnouncement
		do: [ :each | announcements add: each ]
		for: self.
	self assert: workerManager maxFailures equals: 3.
	now := DateAndTime now.
	self note: 2 exitsOf: workerManager at: now.
	self deny: workerManager restartsStopped.
	self assert: workerManager canStartWorkers.
	self note: 1 exitsOf: workerManager at: now + 30 seconds.
	self assert: workerManager restartsStopped.
	self deny: workerManager canStartWorkers.
	self assert: announcements size equals: 1.
	self assert: announcements first failures size equals: 3.
	self assert: announcements first reason equals: workerManager restartsStoppedDescription.
	self
		assert: announcements first description
		equals: 'worker restarts were stopped after 3 workers exited within 10 minutes without being stopped by the runner, 0 of 2 workers were still running'.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> jobsRunOnRemainingWorkers [
	"Stopping the worker restarts keeps the registered workers: jobs still run on them"

	<gtExample>
	<return: #GtRrTasksJob>
	| runner workerManager registered completed job |
	runner := self runnerWithoutWorkers.
	workerManager := runner managerStartupAndShutdown workerManager.
	registered := Semaphore new.
	completed := Semaphore new.
	runner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ :each | registered signal ]
		for: self.
	[ runner start.
	runner managerStartupAndShutdown startInImageWorker.
	self
		deny: (registered waitTimeoutSeconds: 20)
		description: 'The in-image worker did not register'.
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	self assert: workerManager restartsStopped.
	job := self simpleJob.
	job
		when: GtRrJobCompletedAnnouncement
		do: [ :each | completed signal ]
		for: self.
	runner submitJob: job.
	self
		deny: (completed waitTimeoutSeconds: 20)
		description: 'The job did not complete on the in-image worker'.
	self assert: job state equals: #completed.
	self assert: job errorDetails isNil ]
		ensure: [ runner stop ].
	^ job
]

{ #category : #examples }
GtRrWorkerManagerExamples >> maxFailuresDependsOnPoolSize [
	"Half the pool may fail before restarts are stopped, at least three workers"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager |
	workerManager := self workerManagerWithPoolSize: 1.
	self assert: workerManager maxFailures equals: 3.
	workerManager poolSize: 20.
	self assert: workerManager maxFailures equals: 10.
	^ workerManager
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> note: anInteger exitsOf: aWorkerManager at: aDateAndTime [
	"Let the supplied worker manager note anInteger worker processes that exited on their own"

	^ aWorkerManager remoteRunner critical: [ 
		aWorkerManager
			noteExitedProcesses: (self exitedProcesses: anInteger)
			at: aDateAndTime ]
]

{ #category : #examples }
GtRrWorkerManagerExamples >> noWorkersExpected [
	"Jobs are cancelled only when no worker is registered, no worker process is running and no worker can be started"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager runningProcess |
	workerManager := self workerManagerWithPoolSize: 2.
	self assert: workerManager noWorkersExpectedReason isNil.
	workerManager autoRestart: false.
	self assert: (workerManager noWorkersExpectedReason
		includesSubstring: 'automatic restart is disabled').
	runningProcess := GtRrWorkerManagerExampleProcess new
		id: 1;
		isRunning: true;
		yourself.
	workerManager processes add: runningProcess.
	self assert: workerManager noWorkersExpectedReason isNil.
	runningProcess isRunning: false.
	workerManager autoRestart: true.
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	self assert: (workerManager noWorkersExpectedReason
		includesSubstring: 'restarts were stopped').
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> oldFailuresAreForgotten [
	"Only the failures within the failure window count"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager now |
	workerManager := self workerManagerWithPoolSize: 2.
	now := DateAndTime now.
	self note: 2 exitsOf: workerManager at: now.
	self note: 2 exitsOf: workerManager at: now + workerManager failureWindow + 1 minute.
	self assert: workerManager failures size equals: 2.
	self deny: workerManager restartsStopped.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> replacementsKeepThePoolSize [
	"The watchdog only starts the workers missing to reach the pool size.
	A worker stopped on purpose to shrink the pool is not replaced, and a pool of 0 never starts a worker"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager running |
	workerManager := self workerManagerWithPoolSize: 1.
	running := GtRrWorkerManagerExampleProcess new
		id: 1;
		isRunning: true;
		yourself.
	workerManager remoteRunner critical: [ 
		workerManager processes add: running.
		self assert: (workerManager missingWorkerCountReplacing: 1) equals: 0.
		workerManager poolSize: 0.
		workerManager processes removeAll.
		self assert: (workerManager missingWorkerCountReplacing: 1) equals: 0.
		workerManager poolSize: 2.
		self assert: (workerManager missingWorkerCountReplacing: 0) equals: 2 ].
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	workerManager remoteRunner critical: [ 
		self assert: (workerManager missingWorkerCountReplacing: 0) equals: 0.
		self assert: (workerManager missingWorkerCountReplacing: 1) equals: 1 ].
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> restartsAreNotStoppedWithoutAutoRestart [
	"Without automatic restart no worker is restarted, so there are no restarts to stop.
	Jobs are cancelled once all workers exited"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager |
	workerManager := self workerManagerWithPoolSize: 2.
	workerManager autoRestart: false.
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	self deny: workerManager restartsStopped.
	self
		assert: workerManager noWorkersExpectedReason
		equals: 'No worker can run this job: all workers exited and automatic restart is disabled'.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> restartsStoppedCancelJobs [
	"When the worker restarts are stopped and no worker is left, a job is cancelled with the reason instead of waiting forever.
	Retrying the worker startup announces it, after that jobs wait for workers again"

	<gtExample>
	<return: #GtRemoteRunner>
	| runner workerManager cancelledJob waitingJob resumed |
	runner := self runnerWithoutWorkers.
	workerManager := runner managerStartupAndShutdown workerManager.
	resumed := OrderedCollection new.
	runner
		when: GtRrWorkerRestartsResumedAnnouncement
		do: [ :each | resumed add: each ]
		for: self.
	[ runner start.
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	self assert: runner workerRestartsStopped.
	cancelledJob := runner submitJob: self simpleJob.
	self assert: cancelledJob state equals: #cancelled.
	self assert: (cancelledJob errorDetails errorMessage
		includesSubstring: 'No worker can run this job: worker restarts were stopped').
	runner retryWorkerStartup.
	self deny: runner workerRestartsStopped.
	self assert: workerManager failures isEmpty.
	self assert: resumed size equals: 1.
	waitingJob := runner submitJob: self simpleJob.
	self assert: waitingJob state equals: #started.
	self assert: waitingJob errorDetails isNil ]
		ensure: [ runner stop ].
	^ runner
]

{ #category : #examples }
GtRrWorkerManagerExamples >> restartsStopWhenWorkersCannotStart [
	"Start a real worker process that cannot start (its worker class does not exist).
	The watchdog restarts it until too many failed, then stops the restarts and cancels the waiting job.
	Takes about 90 seconds: the watchdog checks the workers every 30 seconds"

	<gtExample>
	<noTest>
	<timeLimit: 300000>
	<return: #GtRemoteRunner>
	| runner workerManager stopped ended job |
	runner := GtRemoteRunner new port: 0.
	runner managerStartupAndShutdown: GtRrLocalManagerStartupAndShutdown new.
	runner managerStartupAndShutdown
		changesSync: false;
		poolSize: 1.
	workerManager := runner managerStartupAndShutdown workerManager.
	workerManager workerClassName: 'GtRrNoSuchWorkerClass'.
	stopped := Semaphore new.
	ended := Semaphore new.
	runner
		when: GtRrWorkerRestartsStoppedAnnouncement
		do: [:each | stopped signal]
		for: self.
	job := self simpleJob.
	"A terminated job announces its completion, its state is #cancelled"
	job
		when: GtRrJobCompletedAnnouncement
		do: [:each | ended signal]
		for: self.
	[runner start.
	runner submitJob: job.
	self deny: (stopped waitTimeoutSeconds: 180)
		description: 'The worker restarts were not stopped'.
	self deny: (ended waitTimeoutSeconds: 30)
		description: 'The job did not end'.
	self assert: job state equals: #cancelled.
	self assert: workerManager failures size equals: 3.
	self assert: workerManager processes isEmpty.
	self assert: (job errorDetails errorMessage
				includesSubstring: 'No worker can run this job: worker restarts were stopped')]
		ensure: [runner stop].
	^runner
]

{ #category : #examples }
GtRrWorkerManagerExamples >> retryForgetsExitedWorkers [
	"Retrying forgets the worker processes that already exited, the watchdog doesn't count them as new failures"

	<gtExample>
	<return: #GtRrWorkerManager>
	| runner workerManager exited |
	runner := self runnerWithoutWorkers.
	workerManager := runner managerStartupAndShutdown workerManager.
	[ runner start.
	exited := self exitedProcesses: 1.
	runner critical: [ 
		workerManager recordProcess: exited first index: '1'.
		workerManager processes addAll: exited ].
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	runner retryWorkerStartup.
	self assert: workerManager processes isEmpty.
	workerManager watchDogCheck.
	self assert: workerManager failures isEmpty.
	self deny: workerManager restartsStopped ]
		ensure: [ runner stop ].
	^ workerManager
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> runnerWithoutWorkers [
	"Answer a runner whose worker manager has a pool of 0 workers.
	Starting it starts the watchdog, but no worker process"
	| runner |
	runner := GtRemoteRunner new port: #none.
	runner managerStartupAndShutdown: GtRrLocalManagerStartupAndShutdown new.
	runner managerStartupAndShutdown
		changesSync: false;
		poolSize: 0.
	^runner
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> simpleJob [
	^GtRrTasksJob new tasks: {GtRrScriptTask script: '#done'}
]

{ #category : #examples }
GtRrWorkerManagerExamples >> stopOnSessionChange [
	"Ensure that the worker manager stops the watchdog when the session changes"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager semaphore process |
	workerManager := GtRrWorkerManager new.
	semaphore := Semaphore new.
	process := [ semaphore wait ] fork.
	workerManager processes add: process.
	workerManager startWatchdog.
	self assert: workerManager isRunning.
	workerManager instVarNamed: #currentSession put: Object new.
	workerManager signalWatchdog.
	self waitForManagerWatchdog: workerManager.
	self deny: workerManager isRunning.
	self assert: workerManager state identicalTo: #sessionIdChanged.
	semaphore signal.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> stoppedWorkersAreNotFailures [
	"A worker the runner stopped on purpose (e.g. its job was terminated) is not a failure when its process exits"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager exited stoppedOnPurpose |
	workerManager := self workerManagerWithPoolSize: 2.
	exited := self exitedProcesses: 2.
	workerManager
		recordProcess: exited first index: '1';
		recordProcess: exited second index: '2'.
	workerManager processes addAll: exited.
	workerManager workerStopped: (self connectionWithWorkerIndex: '1').
	stoppedOnPurpose := workerManager remoteRunner critical: [ 
		workerManager noteExitedProcesses: exited at: DateAndTime now ].
	self assert: stoppedOnPurpose asArray equals: { exited first }.
	self assert: workerManager failures size equals: 1.
	self assert: workerManager failures first value equals: '2'.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> stoppedWorkersAreReplacedAfterRestartsStopped [
	"Once the restarts are stopped, failed workers are no longer replaced.
	Workers that the runner stops on purpose (job terminated, task timeout, heartbeat lost) still are, otherwise the pool would drain"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager |
	workerManager := self workerManagerWithPoolSize: 2.
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	self assert: workerManager restartsStopped.
	self deny: workerManager canStartWorkers.
	self assert: workerManager canReplaceStoppedWorkers.
	^ workerManager
]

{ #category : #examples }
GtRrWorkerManagerExamples >> stoppedWorkersAwaitingReplacementKeepJobs [
	"After the restarts stopped, a worker that the runner stopped on purpose will be replaced once its process exits.
	Until then jobs keep waiting for it instead of being cancelled"

	<gtExample>
	<return: #GtRrWorkerManager>
	| workerManager stopped |
	workerManager := self workerManagerWithPoolSize: 2.
	self note: 3 exitsOf: workerManager at: DateAndTime now.
	stopped := (self exitedProcesses: 1) first.
	workerManager remoteRunner critical: [ 
		workerManager recordProcess: stopped index: '4'.
		workerManager processes add: stopped ].
	self assert: workerManager noWorkersExpectedReason notNil.
	workerManager workerStopped: (self connectionWithWorkerIndex: '4').
	self assert: workerManager noWorkersExpectedReason isNil.
	^ workerManager
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> waitForManagerWatchdog: workerManager [ 
	| count |

	count := 0.
	[ count < 300 and: [ workerManager isRunning ] ] whileTrue:
		[ 100 milliseconds wait.
		count := count + 1 ].
]

{ #category : #examples }
GtRrWorkerManagerExamples >> watchDogStopsRestarts [
	"The watchdog replaces the workers that exited until too many failed.
	Then it stops starting workers: the exited workers are not replaced and the workers still running are kept"

	<gtExample>
	<return: #GtRrWorkerManager>
	| runner workerManager exited running replaced stopped |
	runner := self runnerWithoutWorkers.
	workerManager := runner managerStartupAndShutdown workerManager.
	replaced := OrderedCollection new.
	stopped := OrderedCollection new.
	runner
		when: GtRrWorkerReplacedAnnouncement
			do: [ :each | replaced add: each ]
			for: self;
		when: GtRrWorkerRestartsStoppedAnnouncement
			do: [ :each | stopped add: each ]
			for: self.
	[ runner start.
	exited := self exitedProcesses: 3.
	running := GtRrWorkerManagerExampleProcess new
		id: 4;
		isRunning: true;
		yourself.
	runner critical: [ 
		exited doWithIndex: [ :each :index | 
			workerManager recordProcess: each index: index printString ].
		workerManager processes
			addAll: exited;
			add: running ].
	workerManager watchDogCheck.
	self assert: workerManager restartsStopped.
	self assert: workerManager processes asArray equals: { running }.
	self assert: replaced size equals: 3.
	self assert: (replaced allSatisfy: [ :each | each newProcess isNil ]).
	self assert: stopped size equals: 1.
	self assert: stopped first runningWorkerCount equals: 1.
	self assert: (stopped first failures collect: [ :each | each value ]) asArray equals: #('1' '2' '3') ]
		ensure: [ runner stop ].
	^ workerManager
]

{ #category : #'private - helpers' }
GtRrWorkerManagerExamples >> workerManagerWithPoolSize: anInteger [

	^ GtRrWorkerManager new
		remoteRunner: GtRemoteRunner new;
		poolSize: anInteger;
		yourself
]
