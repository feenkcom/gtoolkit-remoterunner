Class {
	#name : #GtRrWorkerManager,
	#superclass : #Object,
	#instVars : [
		'remoteIpAddress',
		'watchDog',
		'autoRestart',
		'watchdogSemaphore',
		'processes',
		'remoteRunner',
		'workerIndex',
		'changesSync',
		'workerCountCalculator',
		'state',
		'connectionStrategyId',
		'workerClassName',
		'currentSession',
		'additionalArguments',
		'changesFile',
		'settings',
		'vmArguments',
		'logPrefix',
		'failures',
		'restartsStopped',
		'stoppedWorkerIndices',
		'processIndices'
	],
	#classVars : [
		'SharedAccess'
	],
	#category : #'RemoteRunner-Runner-Workers'
}

{ #category : #accessing }
GtRrWorkerManager class >> sharedAccess [

	^ SharedAccess ifNil: [ SharedAccess := Mutex new ]
]

{ #category : #accessing }
GtRrWorkerManager >> addArguments: aCollection [

	additionalArguments addAll: aCollection
]

{ #category : #private }
GtRrWorkerManager >> addFailure: anAssociation [
	"Add a failure (exit time -> worker index).
	Once the restarts are stopped the failures are frozen, they describe why.
	Must be called within sharedAccess."

	restartsStopped ifFalse: [ failures add: anAssociation ]
]

{ #category : #'start-stop' }
GtRrWorkerManager >> addOrRemoveWorkers [
	"Add or remove workers in the remote runner to reach the current pool size"
	 | poolSize currentSize |

	remoteRunner critical:
		[ poolSize := self poolSize.
		currentSize := processes size.
		currentSize = poolSize ifTrue: [ ^ self ].
		poolSize > currentSize 
			ifTrue: [ self addWorkers: poolSize - currentSize ]
			ifFalse: [ self removeWorkers: currentSize - poolSize ] ].
]

{ #category : #accessing }
GtRrWorkerManager >> addVmArguments: aCollection [

	vmArguments addAll: aCollection
]

{ #category : #private }
GtRrWorkerManager >> addWorkers: anInteger [
	"Add the specified number of workers to the remote runner.
	Must be called within sharedAccess."

	self startWorkers: anInteger
]

{ #category : #accessing }
GtRrWorkerManager >> autoRestart [
	^ autoRestart
]

{ #category : #accessing }
GtRrWorkerManager >> autoRestart: anObject [
	autoRestart := anObject
]

{ #category : #testing }
GtRrWorkerManager >> canReplaceStoppedWorkers [
	"Answer a boolean indicating whether the watchdog may replace workers that the runner stopped on purpose"

	^ autoRestart and: [ state ~= #sessionIdChanged ]
]

{ #category : #testing }
GtRrWorkerManager >> canStartWorkers [
	"Answer a boolean indicating whether the watchdog may start workers to replace those that failed"

	^ self canReplaceStoppedWorkers and: [ restartsStopped not ]
]

{ #category : #accessing }
GtRrWorkerManager >> changesFile [
	^changesFile
]

{ #category : #accessing }
GtRrWorkerManager >> changesFile: aString [

	changesFile := aString
]

{ #category : #accessing }
GtRrWorkerManager >> changesSync [
	^ changesSync
]

{ #category : #accessing }
GtRrWorkerManager >> changesSync: aBoolean [

	changesSync := aBoolean
]

{ #category : #private }
GtRrWorkerManager >> checkFailuresAt: aDateAndTime [
	"Stop restarting workers if too many failed within the failure window.
	Without automatic restart there is nothing to stop.
	Must be called within sharedAccess."

	restartsStopped ifTrue: [ ^ self ].
	failures removeAllSuchThat: [ :each | aDateAndTime - each key > self failureWindow ].
	(autoRestart and: [ failures size >= self maxFailures ]) ifFalse: [ ^ self ].
	restartsStopped := true.
	remoteRunner announceAndLog: self newRestartsStoppedAnnouncement.
	remoteRunner announceStatusMessageWithString: self restartsStoppedDescription
]

{ #category : #accessing }
GtRrWorkerManager >> commandLine [
	"Answer a string representing the command line that will be used to start the workers"

	^ String streamContents: [ :stream |
		stream
			<< settings serverExecutable fullName;
			space.
		(self newWorkerLocalProcessArgumentsFor: settings)
			do: [ :arg | stream << arg ]
			separatedBy: [ stream space ] ].
]

{ #category : #accessing }
GtRrWorkerManager >> connectionStrategyId [
	^ connectionStrategyId
]

{ #category : #accessing }
GtRrWorkerManager >> connectionStrategyId: anObject [
	connectionStrategyId := anObject
]

{ #category : #private }
GtRrWorkerManager >> criticalIfRunner: aBlock [
	"Evaluate aBlock within the sharedAccess of the receiver's runner.
	A worker manager that was never given a runner has nothing to share"

	^ remoteRunner
		ifNil: [ aBlock value ]
		ifNotNil: [ :aRemoteRunner | aRemoteRunner critical: aBlock ]
]

{ #category : #accessing }
GtRrWorkerManager >> failures [
	"Answer the recent worker failures, associations of the exit time and the worker index"

	^ failures
]

{ #category : #accessing }
GtRrWorkerManager >> failureWindow [
	"Worker failures older than this are forgotten"

	^ 10 minutes
]

{ #category : #private }
GtRrWorkerManager >> forgetWorkers [
	"Forget the failures and the workers of a previous start"

	(restartsStopped and: [ remoteRunner isNotNil ]) ifTrue: [ 
		remoteRunner announceAndLog: GtRrWorkerRestartsResumedAnnouncement new ].
	failures removeAll.
	restartsStopped := false.
	stoppedWorkerIndices removeAll.
	processIndices removeAll
]

{ #category : #ui }
GtRrWorkerManager >> gtCommandLineFor: aView [
	<gtView>

	^ aView text
		title: 'Command Line';
		priority: 20;
		text: [ self humanReadableCommandLine ]
]

{ #category : #ui }
GtRrWorkerManager >> gtProcessesFor: aView [
	<gtView>

	^ aView list
		title: 'Processes';
		priority: 20;
		items: [ processes ];
		actionUpdateButton.
]

{ #category : #ui }
GtRrWorkerManager >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item last ];
		  actionUpdateButton
]

{ #category : #accessing }
GtRrWorkerManager >> humanReadableCommandLine [
	"Answer a string representing the command line that will be used to start the workers split over multiple lines.
	No attempt is made to provide shell line continuation."

	^ String streamContents: [ :stream |
		stream
			<< settings serverExecutable fullName.
		(self newWorkerLocalProcessArgumentsFor: settings) do: [ :arg | 
			(arg first = $-)
				ifTrue: [ stream cr; tab ]
				ifFalse: [ stream space ].
			stream << arg ] ].
]

{ #category : #initialize }
GtRrWorkerManager >> initialize [
	"Initialize the receiver"

	super initialize.
	workerIndex := 0.
	autoRestart := true.
	changesSync := true.
	"The LanguageLinkSettings are used to determine the executable, image and working directory"
	settings := LanguageLinkSettings pharoDefaultSettings.
	workerCountCalculator := GtRrWorkerCountCalculator new.
	processes := OrderedCollection new.
	watchdogSemaphore := Semaphore new.
	state := #notStarted.
	additionalArguments := OrderedCollection new.
	vmArguments := OrderedCollection new.
	failures := OrderedCollection new.
	restartsStopped := false.
	stoppedWorkerIndices := Set new.
	processIndices := IdentityDictionary new.
]

{ #category : #private }
GtRrWorkerManager >> isReplacedOnExit: aProcess [
	"Answer a boolean indicating whether the watchdog will replace aProcess when it sees it exited, i.e. the runner stopped it on purpose"

	^ self canReplaceStoppedWorkers and: [ 
		stoppedWorkerIndices includes: (processIndices at: aProcess ifAbsent: [ nil ]) ]
]

{ #category : #testing }
GtRrWorkerManager >> isRunning [

	^ watchDog notNil and: [ state = #running ]
]

{ #category : #private }
GtRrWorkerManager >> lastErrorLineIn: aFileReferenceOrNil [
	"Answer the last error line (printed in red) of the supplied worker log, or nil.
	Only the end of the log is read, the log of a worker that ran for a long time can be large"

	| red reset contents |
	(aFileReferenceOrNil isNotNil and: [ aFileReferenceOrNil exists ]) ifFalse: [ ^ nil ].
	red := (String with: Character escape) , '[31m'.
	reset := (String with: Character escape) , '[0m'.
	contents := [ aFileReferenceOrNil binaryReadStreamDo: [ :stream | 
			stream position: (aFileReferenceOrNil size - self logTailSize max: 0).
			stream upToEnd asString ] ]
		on: FileException
		do: [ :ex | ^ nil ].
	contents lines reverseDo: [ :each | 
		(each includesSubstring: red) ifTrue: [ 
			^ ((each copyReplaceAll: red with: '') copyReplaceAll: reset with: '') trimBoth ] ].
	^ nil
]

{ #category : #private }
GtRrWorkerManager >> logFileForIndex: aString [
	"Answer the stdout / stderr log file of the worker with the supplied index"

	^ ('workerLogs/', self logPrefix, '.', aString, '.stdouterr.log') asFileReference
]

{ #category : #private }
GtRrWorkerManager >> logPrefix [
	"Answer the string to be used as a prefix for the worker logs"
	| logFile pid index lockFile |

	logPrefix ifNotNil: [ ^ logPrefix ].
	pid := GtOsSystemInfo current currentProcessId.
	index := 1.
	self class sharedAccess critical:
		[ [ logFile := String streamContents: [ :stream |
			stream
				<< 'worker.';
				print: pid;
				<< '.';
				print: index ].
		index := index + 1.
		lockFile := ('workerLogs/', logFile, '.lock') asFileReference.
		lockFile exists ] whileTrue.
		lockFile ensureCreateFile ].
	^ logPrefix := logFile.
]

{ #category : #private }
GtRrWorkerManager >> logTailSize [
	"Answer the number of bytes at the end of a worker log searched for its last error"

	^ 64 * 1024
]

{ #category : #accessing }
GtRrWorkerManager >> maxFailures [
	"Answer the number of workers that may fail within the failure window before restarts are stopped"

	^ self poolSize // 2 max: 3
]

{ #category : #private }
GtRrWorkerManager >> missingWorkerCountReplacing: aNumberStoppedOnPurpose [
	"Answer how many workers the watchdog should start to reach the pool size.
	Once the restarts are stopped, only the workers that the runner just stopped on purpose (job terminated, task timeout, heartbeat lost) are replaced, otherwise the pool would drain.
	Must be called within sharedAccess."

	| missing |
	missing := self poolSize - processes size max: 0.
	self canStartWorkers ifTrue: [ ^ missing ].
	self canReplaceStoppedWorkers ifTrue: [ ^ missing min: aNumberStoppedOnPurpose ].
	^ 0
]

{ #category : #private }
GtRrWorkerManager >> newRestartsStoppedAnnouncement [
	"Answer the announcement describing why the restarts were stopped.
	The log is the one of the last failed worker that has one (a worker that couldn't be started has none).
	Must be called within sharedAccess."

	| lastLogFile |
	lastLogFile := failures reversed
		detect: [ :each | each value isNotNil ]
		ifFound: [ :each | self logFileForIndex: each value ]
		ifNone: [ nil ].
	^ GtRrWorkerRestartsStoppedAnnouncement new
		reason: self restartsStoppedDescription;
		failures: failures asArray;
		poolSize: self poolSize;
		runningWorkerCount: (processes select: #isRunning) size;
		lastLogFile: lastLogFile;
		lastErrorLine: (self lastErrorLineIn: lastLogFile)
]

{ #category : #private }
GtRrWorkerManager >> newWorkerLocalProcess [
	| builder process logFile pid |

	workerIndex := workerIndex + 1.
	'workerLogs' asFileReference ensureCreateDirectory.
	pid := GtOsSystemInfo current currentProcessId.
	logFile := self logFileForIndex: workerIndex asString.
	builder := GtExternalProcessBuilder new
		command: settings serverExecutable fullName;
		args: (self newWorkerLocalProcessArgumentsFor: settings);
		fileStdout: logFile;
		fileStderr: logFile;
		workingDirectory: settings workingDirectory resolve fullName.
	process := builder createNativeCommand spawn.
	process terminateOnShutdown.
	self recordProcess: process index: workerIndex asString.
	^ process.
]

{ #category : #private }
GtRrWorkerManager >> newWorkerLocalProcessArgumentsFor: someSettings [
	| args logDir |

	remoteIpAddress ifNil:
		[ self error: 'Attempt to start worker without server address' ].

	logDir := 'workerLogs'.
	args := OrderedCollection new.
	args addAll: vmArguments.
	args
		add: someSettings serverImage fullName;
		add: 'clap';
		add: 'remoteRunnerWorker'.
	workerClassName ifNotNil:
		[ args
			add: '--workerClass';
				add: workerClassName ].
	args
		add: '--log';
		add: '--logDir';
			add: logDir;
		add: '--logPrefix';
			add: (self logPrefix, '.', workerIndex asString);
		add: '--serverSocketAddress';
			add: remoteIpAddress asString.
	connectionStrategyId ifNotNil:
		[ args
			add: '--connectionStrategy';
				add: connectionStrategyId asString ].
	changesSync ifTrue:
		[ args add: '--changesSync' ].
	changesFile ifNotNil:
		[ args
			add: '--changesFile';
				add: changesFile ].
	args addAll: additionalArguments.
	args
		add: '--attribute';
			add: 'gtRrWorkerIndex';
			add: workerIndex asString.
	args
		add: '--detachChangesDir';
			add: logDir;
		add: '--epiceaMemoryStore';
		add: '--noLepiterReload';
		add: '--noGtImageUpdate'.
	^ args
]

{ #category : #private }
GtRrWorkerManager >> noteExitedProcesses: aCollection at: aDateAndTime [
	"Count the exited processes that the runner didn't stop on purpose as failures, see #checkFailuresAt:.
	Answer the processes that the runner stopped on purpose.
	Must be called within sharedAccess."

	| stoppedOnPurpose |
	stoppedOnPurpose := OrderedCollection new.
	aCollection do: [ :each | | index |
		index := processIndices removeKey: each ifAbsent: [ nil ].
		(stoppedWorkerIndices includes: index)
			ifTrue: [ 
				stoppedWorkerIndices remove: index.
				stoppedOnPurpose add: each ]
			ifFalse: [ self addFailure: aDateAndTime -> index ] ].
	self checkFailuresAt: aDateAndTime.
	^ stoppedOnPurpose
]

{ #category : #private }
GtRrWorkerManager >> noteFailedStart: anError [
	"Count a worker that couldn't be started as a failure.
	Must be called within sharedAccess."

	| now |
	now := DateAndTime now.
	self addFailure: now -> nil.
	remoteRunner announceStatusMessageWithString: 'Failed to start a worker: ' , anError messageText asString.
	self checkFailuresAt: now
]

{ #category : #'api - worker' }
GtRrWorkerManager >> noWorkersExpectedReason [
	"Answer a description of why no worker will be able to run a job, or nil if a worker is registered, its process is still running or a worker may still be started.
	Must be called within sharedAccess."

	remoteRunner registeredWorkers ifNotEmpty: [ ^ nil ].
	state = #sessionIdChanged ifTrue: [ 
		^ 'No worker can run this job: the image session changed, workers are not restarted' ].
	(self canStartWorkers or: [ 
		processes anySatisfy: [ :each | each isRunning or: [ self isReplacedOnExit: each ] ] ])
			ifTrue: [ ^ nil ].
	^ 'No worker can run this job: ' , (restartsStopped
		ifTrue: [ self restartsStoppedDescription ]
		ifFalse: [ 'all workers exited and automatic restart is disabled' ])
]

{ #category : #accessing }
GtRrWorkerManager >> pharoDebugLog [
	"Temporary backward compatibility.
	Answer the PharoDebug.log filename that is generated by the worker."

	^ self logPrefix, '.', workerIndex asString, '.PharoDebug.log'
]

{ #category : #accessing }
GtRrWorkerManager >> pharoDebugLog: aString [
	"The PharoDebug.log file is now controlled via `--logPrefix`"
]

{ #category : #accessing }
GtRrWorkerManager >> poolSize [

	^ workerCountCalculator workerCount
]

{ #category : #accessing }
GtRrWorkerManager >> poolSize: anInteger [
	"Set the receiver's pool size to the fixed value provided.
	If the runner has been started, add new workers or disconnect existing workers as required."
	| oldSize |

	oldSize := self poolSize.
	workerCountCalculator := GtRrWorkerCountCalculator fixedCount: anInteger.
	oldSize = self poolSize ifTrue: [ ^ self ].
	(remoteRunner isNotNil and: [ remoteRunner isRunning ]) ifTrue:
		[ remoteRunner critical:
			[ self addOrRemoveWorkers ] ]
]

{ #category : #accessing }
GtRrWorkerManager >> processCount [

	^ processes size.
]

{ #category : #accessing }
GtRrWorkerManager >> processes [

	^ processes
]

{ #category : #private }
GtRrWorkerManager >> recordProcess: aProcess index: aString [
	"Remember the worker index of the supplied process, it identifies the worker when it registers or is stopped"

	processIndices at: aProcess put: aString
]

{ #category : #'api - worker' }
GtRrWorkerManager >> registerWorker: aWorkerConnection [
	"Do nothing"
]

{ #category : #accessing }
GtRrWorkerManager >> remoteIpAddress [
	^ remoteIpAddress
]

{ #category : #accessing }
GtRrWorkerManager >> remoteIpAddress: anObject [
	remoteIpAddress := anObject
]

{ #category : #accessing }
GtRrWorkerManager >> remoteRunner [
	^ remoteRunner
]

{ #category : #accessing }
GtRrWorkerManager >> remoteRunner: anObject [
	remoteRunner := anObject
]

{ #category : #private }
GtRrWorkerManager >> removeExitedProcesses [
	"Remove the processes that exited, without counting them as failures.
	Must be called within sharedAccess."

	| exited |
	exited := processes reject: #isRunning.
	processes removeAll: exited.
	exited do: [ :each | 
		(processIndices removeKey: each ifAbsent: [ nil ])
			ifNotNil: [ :index | stoppedWorkerIndices remove: index ifAbsent: [ ] ] ]
]

{ #category : #private }
GtRrWorkerManager >> removeWorkers: anInteger [
	"Remove the specified number of workers from the pool.
	Only remove workers that are currently available, i.e. idle.
	This is a best attempt, not a guarantee, if the workers are all currently busy this will quietly return.
	Must be called within sharedAccess."
	| removeCount workers |

	remoteRunner sharedAccess assertIsOwner.
	removeCount := anInteger min: remoteRunner availableWorkers size.
	workers := remoteRunner availableWorkers asArray first: removeCount.
	workers do: [ :worker | worker connection stop ].
]

{ #category : #testing }
GtRrWorkerManager >> restartsStopped [

	^ restartsStopped
]

{ #category : #private }
GtRrWorkerManager >> restartsStoppedDescription [
	"Answer a description of why the worker restarts were stopped"
	^String streamContents: 
			[:stream |
			stream
				<< 'worker restarts were stopped after ';
				print: failures size;
				<< ' workers exited within ';
				<< self failureWindow humanReadablePrintString;
				<< ' without being stopped by the runner']
]

{ #category : #'start-stop' }
GtRrWorkerManager >> retryWorkerStartup [
	"Forget the worker failures and start workers up to the pool size again.
	Do nothing unless the restarts were stopped and the receiver is running (not stopped, same image session).
	Within sharedAccess, so that it can't start workers while the receiver is shut down"

	remoteRunner critical: [ 
		(restartsStopped and: [ self isRunning ]) ifFalse: [ ^ self ].
		self removeExitedProcesses.
		failures removeAll.
		restartsStopped := false.
		remoteRunner announceAndLog: GtRrWorkerRestartsResumedAnnouncement new.
		self addOrRemoveWorkers.
		watchDog isTerminated
			ifTrue: [ self startWatchdog ]
			ifFalse: [ self signalWatchdog ] ]
]

{ #category : #accessing }
GtRrWorkerManager >> settings [
	^settings
]

{ #category : #'start-stop' }
GtRrWorkerManager >> shutdown [

	self shutdownLocalWorkers.
]

{ #category : #'start-stop' }
GtRrWorkerManager >> shutdownLocalWorkers [
	"Stop the watchdog and terminate the worker processes.
	Within sharedAccess, so that a concurrent retry can't start workers that would be left running"

	self criticalIfRunner: [ 
		state := #stopping.
		watchDog ifNotNil: 
			[ [ watchDog terminate ]
				on: ProcessAlreadyTerminating
				do: [ "noop" ] ].
		watchDog := nil.
		processes do: #terminate.
		processes removeAll.
		processIndices removeAll.
		stoppedWorkerIndices removeAll.
		state := #stopped ]
]

{ #category : #'start-stop' }
GtRrWorkerManager >> signalWatchdog [
	"Signal the watchdog to check immediately"

	watchdogSemaphore signal.
]

{ #category : #'start-stop' }
GtRrWorkerManager >> startLocalWorkers [
	| processCount isWindows |

	workerCountCalculator reset.
	self forgetWorkers.
	processCount := self poolSize.
	isWindows := OSPlatform current isWindows.
	processCount timesRepeat: 
		[ processes add: self newWorkerLocalProcess.
		"Pharo writes a number of files during startup.
		Windows locks these files causing the workers to fail during startup,
		give each worker a fighting chance to get going."
		isWindows ifTrue: [ 1 second wait ] ].
	self startWatchdog.
]

{ #category : #'start-stop' }
GtRrWorkerManager >> startLocalWorkersFor: aGtRrJobContext [

	self startLocalWorkers.
]

{ #category : #private }
GtRrWorkerManager >> startWatchdog [

	state := #running.
	currentSession := SessionManager default currentSession.
	watchDog := [ [ state = #running and: [ autoRestart or: [ processes notEmpty ] ] ] whileTrue:
		[ watchdogSemaphore waitTimeoutSeconds: 30.
		self watchDogCheck.
		 ] ] forkNamed: 'GtRrWorkerManager local watch dog'.
]

{ #category : #'start-stop' }
GtRrWorkerManager >> startup [

	self startLocalWorkers.
]

{ #category : #private }
GtRrWorkerManager >> startWorker [
	"Start a worker process and answer it, or nil if it couldn't be started.
	A worker that can't be started counts as a failure: an error here must not suspend the caller while it owns sharedAccess.
	Must be called within sharedAccess."

	^ [ processes add: self newWorkerLocalProcess ]
		on: Error
		do: [ :ex | 
			self noteFailedStart: ex.
			nil ]
]

{ #category : #private }
GtRrWorkerManager >> startWorkers: anInteger [
	"Start up to anInteger workers and answer their processes.
	Stop at the first worker that can't be started: it is counted as a failure once, a later watchdog pass tries again.
	Must be called within sharedAccess."

	| started |
	started := OrderedCollection new.
	anInteger timesRepeat: [ 
		started add: (self startWorker ifNil: [ ^ started ]) ].
	^ started
]

{ #category : #accessing }
GtRrWorkerManager >> state [

	^ state
]

{ #category : #ui }
GtRrWorkerManager >> summaryAttributes [

	^ OrderedCollection new
		add: { #Running. self isRunning. self. };
		add: { #ProcessCount. self processCount. processes. };
		yourself
]

{ #category : #private }
GtRrWorkerManager >> watchDogCheck [
	"Check for workers that exited, then start the missing workers up to the pool size if appropriate, see #missingWorkerCountReplacing:.
	Workers that exit without being stopped by the runner are failures, see #noteExitedProcesses:at:"

	"Terminate if the session has changed to prevent the possibility of accidentally starting workers because the image was saved in an inconsistent state."
	currentSession = SessionManager default currentSession ifFalse: [ 
		state := #sessionIdChanged.
		^ self ].
	remoteRunner critical: [ | exited stoppedOnPurpose started |
		exited := processes reject: #isRunning.
		processes removeAll: exited.
		stoppedOnPurpose := self noteExitedProcesses: exited at: DateAndTime now.
		started := self startWorkers: (self missingWorkerCountReplacing: stoppedOnPurpose size).
		exited withIndexDo: [ :each :index | 
			remoteRunner announceAndLog: (GtRrWorkerReplacedAnnouncement new
				oldProcess: each;
				newProcess: (started at: index ifAbsent: [ nil ])) ] ].
	remoteRunner terminateJobsOnNoWorkers
]

{ #category : #accessing }
GtRrWorkerManager >> workerClassName [
	^ workerClassName
]

{ #category : #accessing }
GtRrWorkerManager >> workerClassName: anObject [
	workerClassName := anObject
]

{ #category : #accessing }
GtRrWorkerManager >> workerCountCalculator [
	^ workerCountCalculator
]

{ #category : #accessing }
GtRrWorkerManager >> workerCountCalculator: anObject [
	workerCountCalculator := anObject
]

{ #category : #'api - worker' }
GtRrWorkerManager >> workerStopped: aWorkerConnection [
	"The runner is stopping the supplied worker on purpose (job terminated, pool reduced, heartbeat lost, runner stopped).
	Its exit is not a failure."

	aWorkerConnection attributes
		at: #gtRrWorkerIndex
		ifPresent: [ :index | 
			remoteRunner critical: 
				[ (processIndices includes: index) ifTrue: 
					[ stoppedWorkerIndices add: index ] ] ]
]
