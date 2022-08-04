Class {
	#name : #GtRrLocalManagerStartupAndShutdown,
	#superclass : #GtRrManagerStartupAndShutdown,
	#instVars : [
		'inMemoryLog',
		'workerIndex',
		'autoRestart',
		'watchDog',
		'watchdogSemaphore',
		'processes',
		'workerCountCalculator',
		'connectionStrategyId'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> addOrRemoveWorkers [
	"Add or remove workers in the remote runner to reach the current pool size"
	 | poolSize currentSize |

	poolSize := self poolSize.
	currentSize := processes size.
	currentSize = poolSize ifTrue: [ ^ self ].
	poolSize > currentSize 
		ifTrue: [ self addWorkers: poolSize - currentSize ]
		ifFalse: [ self removeWorkers: currentSize - poolSize ].
]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> addWorkers: anInteger [
	"Add the specified number of workers to the remote runner.
	Must be called within sharedAccess."

	anInteger timesRepeat:
		[ processes add: self newWorkerLocalProcess ]
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> autoRestart [
	"Answer a boolean indicating whether the workers should be automatically restarted when they fail"

	^ autoRestart
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> autoRestart: aBoolean [

	autoRestart := aBoolean
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> connectionStrategyId [
	"Answer the id of the strategy used by the worker to connect to the runner.
	For a list of valid values, see {{gtMethod:GtRrWorker class>>#commandLine}}"
	<return: #Symbol>

	^ connectionStrategyId
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> connectionStrategyId: aSymbol [

	connectionStrategyId := aSymbol
]

{ #category : #'gt-extension' }
GtRrLocalManagerStartupAndShutdown >> gtProcessesFor: aView [
	<gtView>

	^ aView list
		title: 'Processes';
		priority: 20;
		items: [ processes ];
		actionUpdateButton.
]

{ #category : #ui }
GtRrLocalManagerStartupAndShutdown >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item third ];
		  updateWhen: GtRrWorkerAnnouncement in: [ remoteRunner announcer ];
		  actionUpdateButton
]

{ #category : #initialization }
GtRrLocalManagerStartupAndShutdown >> initialize [

	super initialize.
	inMemoryLog := false.
	workerIndex := 0.
	autoRestart := true.
	workerCountCalculator := GtRrResourceWorkerCountCalculator new.
	processes := OrderedCollection new.
	watchdogSemaphore := Semaphore new.
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> inMemoryLog [
	"Answer a boolean indicating whether worker output should be stored in memory or not"

	^ inMemoryLog
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> inMemoryLog: aBoolean [

	inMemoryLog := aBoolean
]

{ #category : #testing }
GtRrLocalManagerStartupAndShutdown >> isRunning [

	^ watchDog isNotNil
]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> newInMemoryWorkerLocalProcess [

	| settings |
	settings := LanguageLinkSettings pharoDefaultSettings.
	^ GtSubprocessWithInMemoryOutput new
		  command: settings serverExecutable fullName;
		  arguments: (self newWorkerLocalProcessArgumentsFor: settings);
		  workingDirectory: settings workingDirectory resolve fullName;
		  terminateOnShutdown;
		  run;
		  yourself
]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> newLogFileWorkerLocalProcess [
	| settings builder process logFile |

	settings := LanguageLinkSettings pharoDefaultSettings.
	workerIndex := workerIndex + 1.
	logFile := ('worker.', workerIndex asString, '.log') asFileReference.
	builder := GtExternalProcessBuilder new
		command: settings serverExecutable fullName;
		args: (self newWorkerLocalProcessArgumentsFor: settings);
		fileStdout: logFile;
		fileStderr: logFile;
		workingDirectory: settings workingDirectory resolve fullName.
	process := builder createNativeCommand spawn.
	process terminateOnShutdown.
	^ process.

]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> newWorkerLocalProcess [

	^ inMemoryLog
		ifTrue: [ self newInMemoryWorkerLocalProcess ]
		ifFalse: [ self newLogFileWorkerLocalProcess ]
]

{ #category : #'instance creation' }
GtRrLocalManagerStartupAndShutdown >> newWorkerLocalProcessArgumentsFor: someSettings [

	| args |
	args := OrderedCollection new.
	args
		add: someSettings serverImage fullName;
		add: 'clap';
		add: 'remoteRunnerWorker'.
	remoteRunner debugMode ifTrue: [ args add: '--log' ].
	args
		add: '--serverSocketAddress';
		add: remoteRunner port asString.
	connectionStrategyId ifNotNil:
		[ args
			add: '--connectionStrategy';
			add: connectionStrategyId asString ].
	args
		add: '--detachChangesFromFileSystem';
		add: '--noGtImageUpdate'.
	^ args
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> poolSize [

	^ workerCountCalculator workerCount
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> poolSize: anInteger [
	"Set the receiver's pool size to the fixed value provided.
	If the runner has been started, add new workers or disconnect existing workers as required."
	| oldSize |

	oldSize := self poolSize.
	workerCountCalculator := GtRrFixedWorkerCountCalculator workerCount: anInteger.
	oldSize = self poolSize ifTrue: [ ^ self ].
	remoteRunner isRunning ifTrue:
		[ remoteRunner critical:
			[ self addOrRemoveWorkers ] ]
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> processCount [

	^ processes size.
]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> removeWorkers: anInteger [
	"Remove the specified number of workers from the pool.
	Only remove workers that are currently available, i.e. idle.
	This is a best attempt, not a guarantee, if the workers are all currently busy this will quietly return.
	Must be called within sharedAccess."
	| removeCount workers |

	removeCount := anInteger min: remoteRunner availableWorkers size.
	workers := remoteRunner availableWorkers asArray first: removeCount.
	"Run the stop in separate processes to avoid sharedAccess recursion lock"
	workers do: [ :worker |
		[ worker connection stop ] fork ].
]

{ #category : #'startup - shutdown' }
GtRrLocalManagerStartupAndShutdown >> shutdown [ 

	self isRunning ifFalse: [ ^ self ].
	[ watchDog terminate ]
		on: ProcessAlreadyTerminating
		do: [ "noop" ].
	watchDog := nil.
	processes do: #terminate.
	remoteRunner debugMode ifFalse:
		[ processes removeAll ].
	super shutdown.

]

{ #category : #'running tests' }
GtRrLocalManagerStartupAndShutdown >> signalWatchdog [
	"Signal the watchdog to check immediately.
	Used for testing."

	watchdogSemaphore signal.
]

{ #category : #'startup - shutdown' }
GtRrLocalManagerStartupAndShutdown >> startup [ 
	| isWindows |

	self assert: processes isEmpty.
	self assert: self isRunning not.
	super startup.

	isWindows := OSPlatform current isWin32.
	self poolSize timesRepeat: 
		[ processes add: self newWorkerLocalProcess.
		"Pharo writes a number of files during startup.
		Windows locks these files causing the workers to fail during startup,
		give each worker a fighting chance to get going."
		isWindows ifTrue: [ 1 second wait ] ].
	self startWatchDog.

]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> startWatchDog [

	watchDog := [ [ autoRestart or: [ processes isNotEmpty ] ] whileTrue:
		[ | broken |
		watchdogSemaphore waitTimeoutSeconds: 30.
		broken := processes reject: #isRunning.
		broken do: [ :e | | process |
			processes remove: e.
			process := autoRestart
				ifTrue: [ processes add: self newWorkerLocalProcess ]
				ifFalse: [ ].
			remoteRunner announceAndLog: (GtRrWorkerReplacedAnnouncement new
				worker: e;
				newWorker: process) ].
		 ] ] forkNamed:
			'GtRemoteRunner local watch dog'
]

{ #category : #ui }
GtRrLocalManagerStartupAndShutdown >> summaryAttributes [

	^ OrderedCollection new
		add: { #Running. self isRunning. self. };
		add: { #ProcessCount. self processCount. processes. };
		yourself
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> workerCountCalculator [

	^ workerCountCalculator
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> workerCountCalculator: anObject [

	workerCountCalculator := anObject
]
