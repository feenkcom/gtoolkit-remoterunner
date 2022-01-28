Class {
	#name : #GtRrLocalManagerStartupAndShutdown,
	#superclass : #GtRrManagerStartupAndShutdown,
	#instVars : [
		'watchDog',
		'watchdogSemaphore',
		'processes',
		'poolSize'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #initialization }
GtRrLocalManagerStartupAndShutdown >> initialize [

	super initialize.
	poolSize := 2.
	processes := OrderedCollection new.
	watchdogSemaphore := Semaphore new.
]

{ #category : #testing }
GtRrLocalManagerStartupAndShutdown >> isRunning [

	^ watchDog isNotNil
]

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> newWorkerLocalProcess [

	| settings |
	settings := LanguageLinkSettings pharoDefaultSettings.
	^ GtSubprocessWithInMemoryOutput new
		  command: settings serverExecutable fullName;
		  arguments: (self newWorkerLocalProcessArgumentsFor: settings);
		  workingDirectory: settings workingDirectory resolve fullName;
		  terminateOnShutdown;
		  yourself
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
		add: remoteRunner port asString;
		add: '--detachChangesFromFileSystem'.
	^ args
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> poolSize [

	^ poolSize
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> poolSize: anInteger [

	poolSize := anInteger
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

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> startWatchDog [

	watchDog := [ [ | broken |
		watchdogSemaphore waitTimeoutSeconds: 30.
		broken := processes reject: #isRunning.
		broken do: [ :e | | process |
			process := self newWorkerLocalProcess.
			process run.
			processes
				remove: e;
				add: process.
			remoteRunner announceAndLog: (GtRrWorkerReplacedAnnouncement new
				worker: e;
				newWorker: process) ].
		 ] repeat ] forkNamed:
			'GtRemoteRunner local watch dog'
]

{ #category : #'startup - shutdown' }
GtRrLocalManagerStartupAndShutdown >> startup [ 

	self assert: processes isEmpty.
	self assert: self isRunning not.
	super startup.

	self startWatchDog.
	poolSize timesRepeat: [ 
		| process |
		process := self newWorkerLocalProcess.
		process run.
		processes add: process ]
]
