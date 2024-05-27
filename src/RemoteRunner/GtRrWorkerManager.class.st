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
		'workerCountCalculator'
	],
	#category : #'RemoteRunner-Runner-Workers'
}

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

	super initialize.
	workerIndex := 0.
	autoRestart := true.
	changesSync := true.
	workerCountCalculator := GtRrResourceWorkerCountCalculator new
		algorithm: #workerCountFreeMemory;
		minWorkers: 0.
	processes := OrderedCollection new.
	watchdogSemaphore := Semaphore new.
]

{ #category : #testing }
GtRrWorkerManager >> isRunning [

	^ watchDog notNil
]

{ #category : #private }
GtRrWorkerManager >> newWorkerLocalProcess [
	| settings builder process logFile |

	settings := LanguageLinkSettings pharoDefaultSettings.
	workerIndex := workerIndex + 1.
	'workerLogs' asFileReference ensureCreateDirectory.
	logFile := ('workerLogs/worker.', workerIndex asString, '.log') asFileReference.

	"Stdio stdout
		<< settings serverExecutable fullName;
		<< ' '.
	(self newWorkerLocalProcessArgumentsFor: settings)
		do: [ :arg | Stdio stdout << arg ]
		separatedBy: [ Stdio stdout << ' ' ].
	Stdio stdout << String lf.
	true ifTrue: [ ^ self ]."

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
	| args pharoDebugFile |

	(remoteRunner port isNil or:
		[ remoteRunner port = #none ]) 
			ifTrue: [ self error: 'Attempt to start worker without server port' ].

	args := OrderedCollection new.
	args
		add: someSettings serverImage fullName;
		add: 'clap';
		add: 'remoteRunnerWorker';
		add: '--workerClass';
		add: 'LwGtRrWorker';
		add: '--log';
		add: '--logDir';
		add: 'workerLogs';
		add: '--serverSocketAddress';
		add: remoteIpAddress.
	changesSync ifTrue:
		[ args add: '--changesSync' ].
	args
		add: '--detachChangesFromFileSystem';
		add: '--epiceaMemoryStore';
		add: '--noLepiterReload';
		add: '--noGtImageUpdate'.
	pharoDebugFile := 'workerLogs/worker.pharoDebug.', workerIndex asString, '.log'.
	args
		add: '--pharoDebugLog';
		add: pharoDebugFile.
	^ args
]

{ #category : #accessing }
GtRrWorkerManager >> poolSize [

	^ workerCountCalculator workerCount
]

{ #category : #accessing }
GtRrWorkerManager >> poolSize: anInteger [
	"Set the receiver's pool size to the fixed value provided"

	workerCountCalculator := GtRrFixedWorkerCountCalculator workerCount: anInteger.
]

{ #category : #accessing }
GtRrWorkerManager >> processCount [

	^ processes size.
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
GtRrWorkerManager >> shutdownLocalWorkers [

	watchDog ifNotNil: 
		[ [ watchDog terminate ]
			on: ProcessAlreadyTerminating
			do: [ "noop" ] ].
	watchDog := nil.
	processes do: #terminate.
	processes removeAll.
]

{ #category : #private }
GtRrWorkerManager >> startLocalWorkersFor: aGtRrJobContext [
	| processCount isWindows |

	processCount := self poolSize.
	isWindows := OSPlatform current isWin32.
	processCount timesRepeat: 
		[ processes add: self newWorkerLocalProcess.
		"Pharo writes a number of files during startup.
		Windows locks these files causing the workers to fail during startup,
		give each worker a fighting chance to get going."
		isWindows ifTrue: [ 1 second wait ] ].
	"processes removeAll."
	self startWatchDog.
]

{ #category : #private }
GtRrWorkerManager >> startWatchDog [

	watchDog := [ [ autoRestart or: [ processes notEmpty ] ] whileTrue:
		[ | broken |
		watchdogSemaphore waitTimeoutSeconds: 30.
		broken := processes reject: #isRunning.
		broken do: [ :e | | process |
			processes remove: e.
			process := autoRestart
				ifTrue: [ processes add: self newWorkerLocalProcess ]
				ifFalse: [ ].
			remoteRunner announceAndLog: (GtRrWorkerReplacedAnnouncement new
				oldProcess: e;
				newProcess: process) ].
		 ] ] forkNamed:
			'GtRrWorkerManager local watch dog'
]

{ #category : #ui }
GtRrWorkerManager >> summaryAttributes [

	^ OrderedCollection new
		add: { #Running. self isRunning. self. };
		add: { #ProcessCount. self processCount. processes. };
		yourself
]
