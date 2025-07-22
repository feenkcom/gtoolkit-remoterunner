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
		'pharoDebugLog',
		'settings',
		'vmArguments'
	],
	#category : #'RemoteRunner-Runner-Workers'
}

{ #category : #accessing }
GtRrWorkerManager >> addArguments: aCollection [

	additionalArguments addAll: aCollection
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

	anInteger timesRepeat:
		[ processes add: self newWorkerLocalProcess ]
]

{ #category : #accessing }
GtRrWorkerManager >> autoRestart [
	^ autoRestart
]

{ #category : #accessing }
GtRrWorkerManager >> autoRestart: anObject [
	autoRestart := anObject
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

{ #category : #accessing }
GtRrWorkerManager >> connectionStrategyId [
	^ connectionStrategyId
]

{ #category : #accessing }
GtRrWorkerManager >> connectionStrategyId: anObject [
	connectionStrategyId := anObject
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
]

{ #category : #testing }
GtRrWorkerManager >> isRunning [

	^ watchDog notNil and: [ state = #running ]
]

{ #category : #private }
GtRrWorkerManager >> newWorkerLocalProcess [
	| builder process logFile pid |

	workerIndex := workerIndex + 1.
	'workerLogs' asFileReference ensureCreateDirectory.
	pid := GtOsSystemInfo current currentProcessId.
	logFile := (String streamContents: [ :stream |
		stream
			<< 'workerLogs/worker.';
			print: pid;
			<< '.';
			print: workerIndex;
			<< '.log' ]) asFileReference.

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
GtRrWorkerManager >> newWorkerLocalProcessArgumentsFor: someSettings [
	| args |

	remoteIpAddress ifNil:
		[ self error: 'Attempt to start worker without server address' ].

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
		add: 'workerLogs';
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
		add: '--detachChangesFromFileSystem';
		add: '--epiceaMemoryStore';
		add: '--noLepiterReload';
		add: '--noGtImageUpdate'.
	pharoDebugLog ifNotNil: [ | fileName |
		fileName := pharoDebugLog format: { #workerIndex -> workerIndex asString } asDictionary.
		args
			add: '--pharoDebugLog';
			add: fileName ].
	^ args
]

{ #category : #accessing }
GtRrWorkerManager >> pharoDebugLog [
	^pharoDebugLog
]

{ #category : #accessing }
GtRrWorkerManager >> pharoDebugLog: aString [
	"Set the PharoDebug.log filename template.
	The string is a format string with the #workerIndex as the argument."

	pharoDebugLog := aString
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

	state := #stopping.
	watchDog ifNotNil: 
		[ [ watchDog terminate ]
			on: ProcessAlreadyTerminating
			do: [ "noop" ] ].
	watchDog := nil.
	processes do: #terminate.
	processes removeAll.
	state := #stopped.
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
	"Check for failed workers are restart if appropriate"
	| broken |

	"Terminate if the session has changed to prevent the possibility of accidentally starting workers because the image was saved in an inconsistent state."
	currentSession = SessionManager default currentSession ifFalse:
		[ state := #sessionIdChanged.
		^ self ].

	broken := processes reject: #isRunning.
	broken do: [ :e | | process |
		processes remove: e.
		process := autoRestart ifTrue: 
			[ [ processes add: self newWorkerLocalProcess ]
				on: Error
				do: [ :ex | self isRunning 
					ifTrue: [ ex pass ]
					ifFalse: [ ^ self ] ] ].
		remoteRunner announceAndLog: (GtRrWorkerReplacedAnnouncement new
			oldProcess: e;
			newProcess: process) ].
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
