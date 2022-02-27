Class {
	#name : #GtRrLocalManagerStartupAndShutdown,
	#superclass : #GtRrManagerStartupAndShutdown,
	#instVars : [
		'autoRestart',
		'watchDog',
		'watchdogSemaphore',
		'processes',
		'poolSize'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #private }
GtRrLocalManagerStartupAndShutdown >> addOrRemoveWorkers: oldSize [
	"Add or remove workers in the remote runner to reach the current pool size"

	oldSize = poolSize ifTrue: [ ^ self ].
	poolSize > oldSize 
		ifTrue: [ self addWorkers: poolSize - oldSize ]
		ifFalse: [ self removeWorkers: oldSize - poolSize ]
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
	autoRestart := true.
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
		  run;
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
	"Set the receiver's pool size.
	Start new workers or disconnect existing workers as required."
	| oldSize |

	oldSize := poolSize ifNil: [ 0 ].
	poolSize := anInteger.
	oldSize = poolSize ifTrue: [ ^ self ].
	remoteRunner isRunning ifTrue:
		[ remoteRunner critical:
			[ self addOrRemoveWorkers: oldSize ] ]
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

	self assert: processes isEmpty.
	self assert: self isRunning not.
	super startup.

	poolSize timesRepeat: 
		[ processes add: self newWorkerLocalProcess ].
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
