"
nil
"
Class {
	#name : #GtRrWorker,
	#superclass : #Object,
	#instVars : [
		'uid',
		'attributes',
		'connectionStrategy',
		'resultQueue',
		'lastHeartbeat',
		'heartbeatProcess',
		'heartbeatDelay',
		'stopFlag',
		'executionContext',
		'readProcess',
		'exceptionHandlingStrategy',
		'logger'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorker class >> commandLine [
	<commandline>

	^ self commandLineCommand meaning: [ :args | 
		self processCommandLineArgs: args ].
]

{ #category : #accessing }
GtRrWorker class >> commandLineCommand [

	^ (ClapCommand id: self commandLineName)
		description: 'Run the RemoteRunner worker';
		add: ClapFlag forHelp;
		add: ((ClapFlag id: #log) description: 'Enable logging');
		add: ((ClapFlag id: #logDir) 
				description: 'Directory to save logs in (./workerLogs)';
				add: (ClapPositional id: #directory);
				yourself);
		add: ((ClapFlag id: #logPrefix) 
				description: 'Prefix to use when creating beacon and PharoDebug.log files';
				add: (ClapPositional id: #prefix);
				yourself);
		add: ((ClapFlag id: #serverSocketAddress)
				   description:
					   'The server socket address on which to connect for requests';
				   add: (ClapPositional id: #address);
				   yourself);
		add: ((ClapFlag id: #connectionStrategy)
				   description:
					   'The connection strategy, e.g. #perMessage, #single';
				   add: (ClapPositional id: #strategyId);
				   yourself);
		add: ((ClapFlag id: #changesSync) description:
			'Synchronise the changes with the remote runner on startup');
		add: ((ClapFlag id: #changesFile) 
			description: 'Load the specified changes file on startup';
			add: (ClapPositional id: #changesFilename);
			yourself);
		add: ((ClapFlag id: #attribute)
				   description: 'add key/value pairs to attributes';
				   multiple: true;
				   add: (ClapPositional id: #key);
				   add: (ClapPositional id: #value);
				   yourself);
		add: ((ClapFlag id: #workerClass) 
				description: 'Specify the class of the worker (GtRrWorker)';
				add: (ClapPositional id: #workerClassName);
				yourself);
		yourself
]

{ #category : #clap }
GtRrWorker class >> commandLineName [

	^ #remoteRunnerWorker
]

{ #category : #clap }
GtRrWorker class >> connectionStrategyLookup [

	^ {#perMessage -> [GtRrWorkerConnectionPerMessageStrategy new].
	#single -> [GtRrWorkerSingleConnectionStrategy new].
	#stompMq -> [GtRrMqWorkerConnectionStrategy new]}
			asDictionary
]

{ #category : #accessing }
GtRrWorker class >> heartbeatDelay [
	"Answer the Duration between heartbeats"

	^ 20 seconds
]

{ #category : #testing }
GtRrWorker class >> isCommandLineWorker [
	"Answer a boolean indicating whether a GtRrWorker was started from the command line"

	^ Smalltalk commandLine argumentsInclude: self commandLineName
]

{ #category : #clap }
GtRrWorker class >> logFilenameFor: aGtRrWorker [
	"Answer a beacon log file name for the worker.
	This is now a fallback if `--logPrefix` is not supplied."
	| pid |

	pid := GtOsSystemInfo current currentProcessId.
	^ 'gtrrworker-' , pid asString , '.log'.
]

{ #category : #private }
GtRrWorker class >> newPharoApplication: aString [

	^ PharoLinkApplication newWith:
		  (PharoLinkApplication defaultSettings
			   serverProcessClass: LanguageLinkManualProcess;
			   serverSocketAddress: (LanguageLinkSocketAddress from: aString);
			   debugMode: true;
			   yourself)
]

{ #category : #'instance creation' }
GtRrWorker class >> newPharoLinkServer: aString [

	^ PharoLinkServer new
		  listenPort: aString;
		  yourself
]

{ #category : #clap }
GtRrWorker class >> processCommandLineArgs: args [
	| worker connectionStrategyId connectionStrategy serverSocketAddress workerClass |

	args at: #help
		ifPresent: 
			[:help |
			help value.
			help context exitSuccess].
	Stdio stdout
		<< Smalltalk commandLineString;
		lf.
	workerClass := self environment at: (args
						at: #workerClass
						ifPresent: [:arg | (arg at: #workerClassName) value asSymbol]
						ifAbsent: [#GtRrWorker]).
	worker := workerClass new.
	args occurrencesOf: #attribute
		do: [:arg | worker attributes at: (arg at: #key) value put: (arg at: #value) value].
	worker startLoggerFor: worker arguments: args.
	GtRrWorkerCliStartingSignal new emit.
	StringSignal emit: Smalltalk commandLineString.
	serverSocketAddress := ((args at: #serverSocketAddress) at: #address)
				value.
	StringSignal emit: 'Server address: ' , serverSocketAddress.
	StringSignal emit: 'WorkerClass: ' , workerClass name.
	connectionStrategyId := args
				at: #connectionStrategy
				ifPresent: [:arg | (arg at: #strategyId) value]
				ifAbsent: [].
	StringSignal
		emit: 'ConnectionStrategy: ' , (connectionStrategyId ifNil: ['<none>']).
	connectionStrategyId ifNotNil: 
		[connectionStrategy := (workerClass connectionStrategyLookup
			at: connectionStrategyId
			ifAbsent: [self error: 
				'Invalid connectionStrategy: ' , connectionStrategyId printString])
					value.
		worker connectionStrategy: connectionStrategy].
	worker connectionStrategy socketAddress: serverSocketAddress.
	args at: #changesSync
		ifPresent: 
			[StringSignal emit: 'changesSync: true'.
			worker attributes at: #changesSync put: true].
	args at: #changesFile
		ifPresent: 
			[:arg |
			| filename |
			filename := (arg at: #changesFilename) value.
			worker attributes at: #changesFile put: filename.
			StringSignal emit: 'changesFile: ' , filename asString].
	StringSignal emit: 'Worker Attributes:'.
	worker attributes keysAndValuesDo: 
			[:key :value |
			StringSignal emit: 'key: ' , key asString , ', value: ' , value asString].
	StringSignal emit: 'Install UI manager...'.
	UIManager default: GtRrUIManager new.
	StringSignal emit: 'Starting worker...'.
	worker start.
	GtRrWorkerCliCompletedSignal new emit.
	"Hibernate until the process exits"
	Semaphore new wait
]

{ #category : #'instance creation' }
GtRrWorker class >> serverSocketAddress: aString [
	| worker |

	worker := self new.
	worker connectionStrategy socketAddress: aString.
	^ worker.
]

{ #category : #'attribute names' }
GtRrWorker class >> stompMqQueueNames [

	^ 'stompMqQueueNames'
]

{ #category : #observer }
GtRrWorker >> addObserver [
	^self connectDuring: [:application |
		| commandFactory observer |
		commandFactory := application newCommandFactory.
		observer := commandFactory
			observerFromCallback: [:message | self command: message].
		observer setByValue.
		"register needs to keep request alive to keep observer alive"
		commandFactory
			send: ('GtAssignedRemoteRunner addObserver: {1} toWorkerId: ''{2}'''
				format: {
					observer pharoLinkFormattedCode. uid})]
]

{ #category : #private }
GtRrWorker >> applyImageSyncEntries: imageSyncEntries addressString: aString [
	"Apply the supplied OmEntries.
	Answer the number of entries supplied
	(entries in the receiver's session history are not applied)."
	<return: #Integer>
	| stonReader sessionIds count |

	stonReader := STONReader on: (imageSyncEntries entriesReadStream
		ifNil: [ ^ self ]).
	sessionIds := GtRrChangesSync default sessionHistory.
	count := 0.
	[ [ stonReader atEnd ] whileFalse:
		[ self applyOmbuEntry: stonReader next 
			remoteAddressString: aString
			sessionIds: sessionIds.
		count := count + 1. ] ]
				ensure: [ stonReader close ].
	^ count
]

{ #category : #private }
GtRrWorker >> applyOmbuEntry: anOmbuEntry remoteAddressString: aRemoteAddressString sessionIds: sessionIds [
	"Apply the supplied OmEntry if it isn't in the supplied session history"
	| shouldApply |

	GtRrWorkerApplyChangeStartingSignal new
		initializeFromOmbuEntry: anOmbuEntry;
		remoteAddressString: aRemoteAddressString;
		workerId: self uid;
		emit.

	shouldApply := self shouldApply: anOmbuEntry with: sessionIds.
	shouldApply ifTrue:
		[ anOmbuEntry content accept: GtExportedEventApplyVisitor new ].
	      
	GtRrWorkerApplyChangeCompletedSignal new
		initializeFromOmbuEntry: anOmbuEntry;
		remoteAddressString: aRemoteAddressString;
		workerId: self uid;
		applied: shouldApply;
		emit.
]

{ #category : #accessing }
GtRrWorker >> attributes [
 
	^ attributes
]

{ #category : #observer }
GtRrWorker >> command: anArray [
	"Execute the command sent from the remote runner.
	The message is encoded as { selector. arguments. lookupClass. }.
	HACK: There isn't proper error handling here.  If an error occurs, return a string describing it."
	| message result |

	GtRrWorkerCommandStartedAnnouncement new
		command: anArray;
		emit.
	result := [ 
		message := Message
			selector: anArray first asSymbol
			arguments: anArray second.
		message lookupClass: anArray third.
		message sendTo: self ]
			on: Exception
			do: [ :ex |
				GtRrWorkerCommandAnnouncement new
					command: anArray;
					message: ex printString;
					emit.
				'#ERROR: ', ex printString. ].
	GtRrWorkerCommandCompletedAnnouncement new
		command: anArray;
		message: result;
		emit.
	^ result
]

{ #category : #commands }
GtRrWorker >> commandCurrentTaskContextId [
	"Answer the current task context id, or nil if nothing is being currently executed"

	^ executionContext ifNotNil: [ executionContext taskContext taskContextId ]
]

{ #category : #commands }
GtRrWorker >> commandEvaluate: aString [
	"Evaluate the supplied string."
	| result |

	result := [ self class compiler
		source: aString;
		receiver: self;
		evaluate ]
			on: Error 
			do: [ :ex | ex return: ex messageText ].
	^ result isPharoLinkPrimitive
		ifTrue: [ result ]
		ifFalse: [ result asString ]
]

{ #category : #commands }
GtRrWorker >> commandPharoLinkServer: anInteger [
	"Start a PharoLinkServer on the supplied port number.
	Answer true if successful, or the error."
	| result |

	result := Dictionary new
		at: #succeeded put: true;
		yourself.
	[ PharoLinkServer new
		listenPort: anInteger;
		start ]
			on: Error 
			do: [ :ex | result
				at: #succeeded put: false;
				at: #messageText put: ex messageText;
				at: #trace put: self stackString ].
	^ result
]

{ #category : #commands }
GtRrWorker >> commandPing [
	"Note that we must not wait for a response, as this leads to a deadlock"

	^ #ping
]

{ #category : #commands }
GtRrWorker >> commandQuitSmalltalk [
	"Except connection closed."

	Smalltalk image snapshot: false andQuit: true
]

{ #category : #commands }
GtRrWorker >> commandTerminateTaskContextId: taskContextId [
	"Terminate the current task, confirming the context id"
	| priority canTerminate |

	"Once we start we don't want to be interrupted by the task, since it may change"
	priority := Processor activeProcess priority.
	[ Processor activeProcess priority: priority + 1.
	canTerminate := true.
	executionContext ifNil:
		[ GtRrWorkerCommandAnnouncement new
			message: taskContextId printString, ': can''t terminate: currentTaskExecution isNil';
			emit.
		canTerminate := false. ]
	ifNotNil:
		[ executionContext task taskContextId = taskContextId ifFalse:
			[ GtRrWorkerCommandAnnouncement new
				message: (String streamContents: [ :stream |
					stream
						print: taskContextId;
						<< ': can''t terminate: current taskContextId = ';
						print: executionContext task taskContextId ]);
				emit.
			canTerminate := false. ] ].
	canTerminate ifTrue: 
		[ executionContext cancelWithReason: 'received TerminateCurrentTask from RemoteRunner' ] ]
			ensure: [ Processor activeProcess priority: priority ].
	^ canTerminate
]

{ #category : #starting }
GtRrWorker >> configureConnectionStrategy [

	attributes at: 'mqLargeMessageUrl' ifPresent:
		[ :mqLargeMessageUrl |
			connectionStrategy largeMessageUrl: mqLargeMessageUrl asZnUrl ].
]

{ #category : #private }
GtRrWorker >> connectDuring: aBlock [
	"Evaluate aBlock passing in a connected PharoLinkApplication"

	^ connectionStrategy connectDuring: aBlock
]

{ #category : #accessing }
GtRrWorker >> connectionStrategy [

	^ connectionStrategy
]

{ #category : #accessing }
GtRrWorker >> connectionStrategy: aGtRrConnectionStrategy [

	connectionStrategy := aGtRrConnectionStrategy.
	connectionStrategy worker: self.
	attributes at: #workerConnectionStrategy put: connectionStrategy strategyName.
]

{ #category : #private }
GtRrWorker >> currentProcessId [
	"Answer the PID of this OS process"

	^ GtOsSystemInfo current currentProcessId
]

{ #category : #'as yet unclassified' }
GtRrWorker >> enableStrictSymbolComparison [
	<gtWorkerStartupScript>

	GtStrictSymbolComparisonFlag setStrictComparison
]

{ #category : #accessing }
GtRrWorker >> exceptionHandlingStrategy [

	^ exceptionHandlingStrategy
]

{ #category : #accessing }
GtRrWorker >> exceptionHandlingStrategy: anObject [

	exceptionHandlingStrategy := anObject
]

{ #category : #accessing }
GtRrWorker >> initialize [

	super initialize.
	uid := UUID new asString.
	"WaitfreeQueues should have only one process reading - which is the taskProcess"
	resultQueue := WaitfreeQueue new.
	"The default strategy for a remote worker is to fail the task with the error"
	exceptionHandlingStrategy := GtRrTaskHeadlessExceptionStrategy new.
	"Attributes is a dictionary of information can be json encoded.
	Additional values can be provided, or existing values overwritten, by the command line.
	This is used by the remote runner to determine which workers can run a given task (the constraints)."
	attributes := GtStringContentDictionary new
		at: #workingDirectory put: FileLocator workingDirectory resolve fullName;
		at: #id put: uid;
		at: #pid put: self currentProcessId;
		at: #platform put: OSPlatform current name;
		yourself.
	heartbeatDelay := self class heartbeatDelay.
	self connectionStrategy: GtRrWorkerSingleConnectionStrategy new.
]

{ #category : #testing }
GtRrWorker >> isRunning [

	^ connectionStrategy isNotNil and: [ 
		readProcess isNotNil and: [ 
		readProcess isTerminated not ] ]
]

{ #category : #accessing }
GtRrWorker >> lastHeartbeat [
	^ lastHeartbeat
]

{ #category : #accessing }
GtRrWorker >> lastHeartbeat: anObject [
	lastHeartbeat := anObject
]

{ #category : #private }
GtRrWorker >> logAndQuit: reasonString [

	GtRrWorkerOperationShutdownAnnouncement new 
		reason: 'Quit received: ', reasonString asString;
		emit.
	"Give other processes time to finish"
	Processor activeProcess priority: 15.
	Smalltalk image isInteractiveGraphic 
		ifTrue: [ UIManager notify: 'GtRrWorker>>logAndQuit: ', reasonString asString ]
		ifFalse: [ Smalltalk snapshot: false andQuit: true ].
]

{ #category : #accessing }
GtRrWorker >> newTaskProcess [

	^ [ [ stopFlag ] whileFalse:
		[ [ [ self stepService ] repeat ]
			on: Error
			do: [ :ex |
				GtRrWorkerTaskProcessErrorAnnouncement new
					taskContext: executionContext;
					exception: ex;
					emit.
				5 seconds wait ] ].
	] forkNamed: 'Worker Process: ', uid.
]

{ #category : #private }
GtRrWorker >> nextTask [
	"Send any queued results and get the next task"

	^ connectionStrategy nextTask
]

{ #category : #accessing }
GtRrWorker >> postTaskProcessing [
	"Subclasses may use this to do any post task processing"
]

{ #category : #stepping }
GtRrWorker >> preTaskConfiguration [
	"Subclasses may use this to do any configuration prior to running a task"
]

{ #category : #private }
GtRrWorker >> registerWith: aPharoLinkApplication [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

	^ connectionStrategy registerWith: aPharoLinkApplication
]

{ #category : #accessing }
GtRrWorker >> resultQueue [
	^ resultQueue
]

{ #category : #private }
GtRrWorker >> retrieveChangesFromServerWith: aPharoLinkApplication [ 

	^ connectionStrategy  retrieveChangesFromServerWith: aPharoLinkApplication
]

{ #category : #starting }
GtRrWorker >> runWorkerStartupScripts [
	"Run any worker startup scripts in the receiver's class"

	self class methods
		select: [ :method | method hasPragmaNamed: #gtWorkerStartupScript ]
		thenDo: [ :method | 
			method
				receiver: self
				withArguments: #()
				executeMethod: method ]
]

{ #category : #private }
GtRrWorker >> sendHeartbeat [

	connectionStrategy sendHeartbeat
]

{ #category : #private }
GtRrWorker >> shouldApply: anOmbuEntry with: sessionIds [
	| omReference localNumber |
	
	omReference := anOmbuEntry tagAt: #self.
	localNumber := [ omReference localName asNumber ]
		on: Error
		do: [ :ex | ^ true ].
	^ sessionIds noneSatisfy: [ :sessionId | | idNumber |
		idNumber := [ sessionId localName asNumber ]
			on: Error
			do: [ :ex | nil ].
		omReference globalName = sessionId globalName and:
		[ localNumber <= idNumber ] ]
]

{ #category : #private }
GtRrWorker >> stackString [

	^ String streamContents: [ :stream |
		thisContext stack do: [ :stackItem |
			stream print: stackItem; cr ] ]
]

{ #category : #starting }
GtRrWorker >> start [

	stopFlag := false.
	self configureConnectionStrategy.
	connectionStrategy start.
	self runWorkerStartupScripts.
	readProcess := self newTaskProcess.
	self startHeartbeat.
]

{ #category : #starting }
GtRrWorker >> startHeartbeat [
	| expiry waitDuration zero |

	lastHeartbeat := DateAndTime now.
	expiry := lastHeartbeat + heartbeatDelay.
	zero := Duration zero.
	heartbeatProcess := [ [ stopFlag ] whileFalse: [
		waitDuration := expiry - DateAndTime now.
		waitDuration > zero ifTrue: [ waitDuration wait ].
		(DateAndTime now - lastHeartbeat) >= heartbeatDelay ifTrue:
			[ self sendHeartbeat ].
		expiry := lastHeartbeat + heartbeatDelay. ].
				] forkAt: Processor lowIOPriority named: 'Worker Heartbeat'.
]

{ #category : #logging }
GtRrWorker >> startLoggerFor: worker arguments: args [
	| announcements logDir logPrefix beaconFile pid pharoDebugLogFile |

	args at: #log ifAbsent: [^ self ].

	logDir := (args at: #logDir
		ifPresent: [:arg | (arg at: #directory) value]
		ifAbsent: ['workerLogs']) asFileReference.
	logPrefix := args at: #logPrefix 
		ifPresent: [ :arg | (arg at: #prefix) value ]
		ifAbsent: [].
	SignalLogger resetAllInstances.
	beaconFile := logPrefix
		ifNil: [ logDir / (worker class logFilenameFor: worker) ]
		ifNotNil: [ :prefix | logDir / (prefix, '.beacon.log') ].
	Stdio stdout
		<< 'worker beacon filename set to: ';
		<< beaconFile asString;
		lf.
	pharoDebugLogFile := logPrefix ifNil:
		[ pid := GtOsSystemInfo current currentProcessId.
		(logDir / ('worker.pharoDebug.', pid asString, '.log')) ]
	ifNotNil: [ :prefix |
		logDir / (prefix, '.PharoDebug.log') ].
	
	Smalltalk logFileName: pharoDebugLogFile fullName.
	Stdio stdout
		<< 'PharoDebug.log filename set to: ';
		<< pharoDebugLogFile fullName;
		lf; flush.

	logger := StreamLoggerFlusher new 
		logger: (SessionFallbackFileLogger filename: beaconFile).

	announcements := AnnouncementSetWithExclusions withAll: 
		{GtRemoteRunnerAnnouncement , GtRemoteRunnerSignal , PharoLinkSignal, 
		GtAwsWebServiceCommandSignal,
		LanguageLinkEventSignal , StringSignal,
		StampSignals}.
	announcements addExclusions: ContextStackSignal allSubclasses.
	logger startFor: announcements.
]

{ #category : #stepping }
GtRrWorker >> stepService [
	"On each iteration:
	- send any results (while requesting the next task)
	- get the next task
	- evaluate the task
	- queue the result (success or failure)"
	| taskContext |

	taskContext := self nextTask.
	taskContext = 'quit' ifTrue: [ self logAndQuit: 'Quit Received' ].
	GtRrWorkerTaskStartingSignal new
		taskId: taskContext taskId;
		emit.
	self preTaskConfiguration.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		timeout: taskContext taskTimeout;
		worker: self.
	executionContext forkAndRun.
	executionContext waitForTaskCompletion.
	executionContext := nil.
]

{ #category : #stopping }
GtRrWorker >> stop [

	stopFlag := true.
	self stopHeartbeat.
	self stopReadProcess.
	connectionStrategy stop.
	self stopExecutionContext.
]

{ #category : #stopping }
GtRrWorker >> stopAndQuit: aString [

	[ self stop  ]
		ensure: [ self logAndQuit: aString ].
]

{ #category : #stopping }
GtRrWorker >> stopExecutionContext [

	executionContext ifNotNil: [ executionContext stop ].
]

{ #category : #stopping }
GtRrWorker >> stopHeartbeat [
	"Stop the heartbeat from running"

	heartbeatProcess ifNotNil:
		[ heartbeatProcess terminate ].
]

{ #category : #stopping }
GtRrWorker >> stopReadProcess [
	"Stop the read process from running"

	readProcess ifNotNil:
		[ readProcess terminate ].
]

{ #category : #private }
GtRrWorker >> syncChangesFromFile: aFileReference [
	"Load the changes from the specified file.
	The changes are encoded as an sequence of OmEntries."
	| imageSyncEntries eventsCount |

	GtRrWorkerApplyChangesStartingSignal new
		remoteAddressString: aFileReference fullName;
		workerId: self uid;
		emit.
	imageSyncEntries := GtRrFileImageSync new entriesFile: aFileReference.
	eventsCount := self applyImageSyncEntries: imageSyncEntries 
		addressString: aFileReference fullName.
	GtRrWorkerApplyChangesCompletedSignal new
		remoteAddressString: aFileReference fullName;
		workerId: self uid;
		encodedEventsSize: aFileReference size;
		eventsCount: eventsCount;
		emit.
	^ imageSyncEntries
]

{ #category : #private }
GtRrWorker >> syncChangesFromServerWith: aConnection [ 
	| imageSyncEntries eventsCount |

	(attributes at: #changesSync ifAbsent: [ false ]) ifFalse: [ ^ #() ].

	GtRrWorkerApplyChangesStartingSignal new
		remoteAddressString: aConnection remoteAddressString;
		workerId: self uid;
		emit.
	imageSyncEntries := self retrieveChangesFromServerWith:  aConnection.
	eventsCount := self applyImageSyncEntries: imageSyncEntries 
		addressString: aConnection remoteAddressString.
	GtRrWorkerApplyChangesCompletedSignal new
		remoteAddressString: aConnection remoteAddressString;
		workerId: self uid;
		encodedEventsSize: imageSyncEntries serializedSize;
		eventsCount: eventsCount;
		emit.
	^ imageSyncEntries
]

{ #category : #private }
GtRrWorker >> syncChangesWith: aConnection [
	| changesSync changesFile |

	(attributes at: #changesSync ifAbsent: [ false ])
		ifTrue: [ changesSync := self syncChangesFromServerWith: aConnection ].
	attributes at: #changesFile
		ifPresent: [ :filename | changesFile := self syncChangesFromFile: filename asFileReference ].
	^ { changesSync. changesFile. }
]

{ #category : #accessing }
GtRrWorker >> taskDone: aTaskContext with: anObject [

	connectionStrategy taskDone: aTaskContext with: anObject
]

{ #category : #accessing }
GtRrWorker >> taskFailed: aTaskContext with: anError [

	connectionStrategy taskFailed: aTaskContext with: anError
]

{ #category : #accessing }
GtRrWorker >> uid [

	^ uid
]

{ #category : #accessing }
GtRrWorker >> uid: anObject [
	uid := anObject
]

{ #category : #private }
GtRrWorker >> unregisterWith: aPharoLinkApplication [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

	^ connectionStrategy unregisterWith: aPharoLinkApplication
]
