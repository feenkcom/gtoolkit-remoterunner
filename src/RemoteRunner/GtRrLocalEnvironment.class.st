Class {
	#name : #GtRrLocalEnvironment,
	#superclass : #GtRrEnvironment,
	#instVars : [
		'watchDog',
		'processes',
		'poolSize',
		'watchDogSemaphore'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrLocalEnvironment >> gtProcessesFor: aView [

	<gtView>
	^ aView forward
		  title: 'Processes';
		  priority: 10;
		  object: [ processes ];
		  view: #gtLiveFor:
]

{ #category : #initialization }
GtRrLocalEnvironment >> initialize [

	super initialize.
	poolSize := 2.
	processes := OrderedCollection new.
	watchDogSemaphore := Semaphore new.
]

{ #category : #testing }
GtRrLocalEnvironment >> isRunning [

	^ watchDog isNotNil
]

{ #category : #private }
GtRrLocalEnvironment >> newWorkerLocalProcess [

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
GtRrLocalEnvironment >> newWorkerLocalProcessArgumentsFor: someSettings [

	| args |
	args := OrderedCollection new.
	args
		add: someSettings serverImage fullName;
		add: 'clap';
		add: 'remoteRunnerWorker'.
	scheduler debugMode ifTrue: [ args add: '--log' ].
	args
		add: '--serverSocketAddress';
		add: scheduler port asString;
		add: '--detachChangesFromFileSystem'.
	^ args
]

{ #category : #accessing }
GtRrLocalEnvironment >> poolSize [

	^ poolSize
]

{ #category : #accessing }
GtRrLocalEnvironment >> poolSize: anInteger [

	poolSize := anInteger
]

{ #category : #'running tests' }
GtRrLocalEnvironment >> signalWatchDog [
	"Signal the watchdog to check immediately.
	Used for testing."

	watchDogSemaphore signal.
]

{ #category : #'startup - shutdown' }
GtRrLocalEnvironment >> start [

	self assert: processes isEmpty.
	self assert: self isRunning not.
	super start.

	self startWatchDog.
	poolSize timesRepeat: [ 
		| process |
		process := self newWorkerLocalProcess.
		process run.
		processes add: process ]
]

{ #category : #private }
GtRrLocalEnvironment >> startWatchDog [

	watchDog := [ 
	            [ 
	            | broken |
	            watchDogSemaphore waitTimeoutSeconds: 30.
	            broken := processes reject: #isRunning.
	            broken do: [ :e | 
		            | process |
		            process := self newWorkerLocalProcess.
		            process run.
		            processes
			            remove: e;
			            add: process.
		            scheduler announceAndLog:
			            (GtRrProcessReplacedAnnouncement
				             before: e
				             after: process) ] ] repeat ] forkNamed:
		            'GtRemoteRunner local watch dog'
]

{ #category : #'startup - shutdown' }
GtRrLocalEnvironment >> stop [

	self isRunning ifFalse: [ ^ self ].
	[ watchDog terminate ]
		on: ProcessAlreadyTerminating
		do: [ "noop" ].
	watchDog := nil.
	processes
		do: #terminate;
		removeAll.
	super stop
]
