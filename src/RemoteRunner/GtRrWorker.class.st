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
		'exceptionHandlingStrategy'
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
		add: ((ClapFlag id: #log) description: 'Enable logging to stdout');
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

{ #category : #accessing }
GtRrWorker class >> commandLineName [

	^ #remoteRunnerWorker
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
	| pid filename |

	pid := GtOsSystemInfo current currentProcessId.
	filename := 'gtrrworker-' , pid asString , '.log'.
	Stdio stdout
		<< 'gtrrworker.log filename set to: ';
		<< filename;
		lf.
	^ filename
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
	| worker connectionStrategyId connectionStrategy logger serverSocketAddress announcements workerClass |

	args
		at: #help ifPresent: [ :help | 
			help value.
			help context exitSuccess ].
	workerClass := self environment at: (args
		at: #workerClass
		ifPresent: [ :arg | (arg at: #workerClassName) value asSymbol ]
		ifAbsent: [ #GtRrWorker ]).
	worker := workerClass new.
	args occurrencesOf: #attribute do: [ :arg | 
		worker attributes
			at: (arg at: #key) value
			put: (arg at: #value) value ].
	args at: #log ifPresent: 
		[ SignalLogger resetAllInstances.
		logger := RestartingStreamLogger appendToFile: (workerClass logFilenameFor: worker).
		announcements := AnnouncementSetWithExclusions withAll:
			{ GtRemoteRunnerAnnouncement, 
			GtRemoteRunnerSignal,
			PharoLinkSignal,
			LanguageLinkEventSignal,
			StringSignal }.
		announcements addExclusions: ContextStackSignal allSubclasses.
		logger startFor: announcements ].

	GtRrWorkerCliStartingSignal new emit.
	serverSocketAddress := ((args at: #serverSocketAddress) at:
			                          #address) value.
	StringSignal emit: 'Server address: ' , serverSocketAddress.
	StringSignal emit: 'WorkerClass: ' , workerClass name.
	connectionStrategyId := args
		at: #connectionStrategy
		ifPresent: [ :arg | (arg at: #strategyId) value ]
		ifAbsent: [ ].
	StringSignal emit: 'ConnectionStrategy: ', (connectionStrategyId ifNil: [ '<none>' ]).
	connectionStrategyId ifNotNil: [ 
		connectionStrategy := ({ 
			(#perMessage -> [ GtRrWorkerConnectionPerMessageStrategy new ]).
			(#single -> [ GtRrWorkerSingleConnectionStrategy new ]) } asDictionary
				at: connectionStrategyId
				ifAbsent: [ self error: 'Invalid connectionStrategy: ', connectionStrategyId printString ]) value.
		worker connectionStrategy: connectionStrategy ].
	worker connectionStrategy socketAddress: serverSocketAddress.
	args at: #changesSync ifPresent:
		[ StringSignal emit: 'changesSync: true'.
		worker attributes at: #changesSync put: true ].
	StringSignal emit: 'Worker Attributes:'.
	worker attributes keysAndValuesDo: [ :key :value |
		StringSignal emit: 'key: ', key asString, ', value: ', value asString ].

	StringSignal emit: 'Install UI manager...'.
	UIManager default: GtRrUIManager new.
	StringSignal emit: 'Starting worker...'.
	worker start.
	GtRrWorkerCliCompletedSignal new emit.
	"Hibernate until the process exits"
	Semaphore new wait.
]

{ #category : #'instance creation' }
GtRrWorker class >> serverSocketAddress: aString [
	| worker |

	worker := self new.
	worker connectionStrategy socketAddress: aString.
	^ worker.
]

{ #category : #observer }
GtRrWorker >> addObserver [
	| commandFactory observer |

	^ self connectDuring: [ :application |
	commandFactory := application newCommandFactory.
	observer := commandFactory observerFromCallback: [ :message | 
		            self command: message ].
	observer setByValue.
	"register needs to keep request alive to keep observer alive"
	commandFactory send: ('GtAssignedRemoteRunner addObserver: {1} toWorkerId: ''{2}''' format:
			   { observer pharoLinkFormattedCode. uid. }) ]
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

	^ executionContext ifNotNil: [ executionContext task taskContextId ]
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
	attributes := Dictionary new
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

{ #category : #private }
GtRrWorker >> logAndQuit [

	GtRrWorkerOperationShutdownAnnouncement new 
		reason: 'Quit received';
		emit.
	"Give other processes time to finish"
	Processor activeProcess priority: 15.
	Smalltalk snapshot: false andQuit: true.
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
	| promise result serializedTask |
	
	^ self connectDuring: [ :application |
		[ result := resultQueue nextOrNil ] whileNotNil:
			[ result sendThroughApplication: application ].

		GtRrWorkerWaitForTaskAnnouncement new emit.
		promise := application newCommandFactory send:
			'GtAssignedRemoteRunner nextTaskSerializedForWorkerId: ''', uid, ''''.
		serializedTask := promise waitForValue.
		lastHeartbeat := DateAndTime now.
		LeJsonV4 uniqueInstance deserialize: serializedTask readStream ].

]

{ #category : #private }
GtRrWorker >> registerWith: aPharoLinkApplication [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

	self syncChangesIfRequiredWith: aPharoLinkApplication.
	^ aPharoLinkApplication newCommandFactory 
			bindingAt: #attributes put: attributes;
			sendAndWait: 'GtAssignedRemoteRunner registerWorkerWithDetails: attributes'.

]

{ #category : #private }
GtRrWorker >> sendHeartbeat [

	self connectDuring: [ :application |
		lastHeartbeat := DateAndTime now.
		application newCommandFactory send:
			'GtAssignedRemoteRunner heartbeatForWorkerId: ''', uid, ''''.
				GtRrWorkerHeartbeatSentAnnouncement new emit ].
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
	connectionStrategy start.
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

{ #category : #stepping }
GtRrWorker >> stepService [
	"On each iteration:
	- send any results (while requesting the next task)
	- get the next task
	- evaluate the task
	- queue the result (success or failure)"
	| taskContext |

	taskContext := self nextTask.
	taskContext = 'quit' ifTrue: [ self logAndQuit ].
	GtRrWorkerTaskStartingSignal new
		taskId: taskContext taskId;
		emit.
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
GtRrWorker >> syncChangesIfRequiredWith: aPharoLinkApplication [ 
	| encodedEvents events remoteAddressString |

	(attributes at: #changesSync ifAbsent: [ false ]) ifFalse: [ ^ self ].
	remoteAddressString := aPharoLinkApplication remoteAddressString.
	GtRrWorkerRetrieveChangesStartingSignal new
		remoteAddressString: remoteAddressString;
		workerId: self uid;
		emit.
	encodedEvents := aPharoLinkApplication newCommandFactory
		setByValue;
		bindingAt: #anOmReference put: 
			(STON toString: GtRrChangesSync headReference);
		<< 'GtAssignedRemoteRunner changesSyncEventsFrom: anOmReference';
		sendAndWait.
	GtRrWorkerRetrieveChangesCompletedSignal new
		remoteAddressString: remoteAddressString;
		workerId: self uid;
		emit.
	GtRrWorkerApplyChangesStartingSignal new
		remoteAddressString: remoteAddressString;
		workerId: self uid;
		emit.
	events  := STON fromString: encodedEvents.
	events do: [ :entry | entry content accept: GtExportedEventApplyVisitor new ].
	GtRrWorkerApplyChangesCompletedSignal new
		remoteAddressString: remoteAddressString;
		workerId: self uid;
		encodedEventsSize: encodedEvents size;
		eventsCount: events size;
		emit.
	^ events
]

{ #category : #accessing }
GtRrWorker >> taskDone: aTaskContext with: anObject [
	| serializedResult executionData serializedExecutionData|

	GtRrWorkerTaskCompletedSignal new
		taskId: aTaskContext taskId;
		message: 'Success: ' , anObject printString;
		emit.
	executionData := GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		additionalData: aTaskContext executionData additionalData.
	serializedExecutionData := [ LeJsonV4 uniqueInstance serialize: executionData ]
		on: Error 
		do: [ :ex | ^ self taskFailed: aTaskContext with: ex ].
	serializedResult := [ LeJsonV4 uniqueInstance serialize: anObject ]
		on: Error 
		do: [ :ex | ^ self taskFailed: aTaskContext with: ex ].
	resultQueue nextPut: (GtRrWorkerResultEntry
		worker: self
		task: aTaskContext
		bindings: { 
			#taskContextId -> aTaskContext taskContextId.
			#executionData -> serializedExecutionData.
			#result -> serializedResult. }
		command: 'GtAssignedRemoteRunner 
			taskDone: taskContextId 
			executionData: (LeJsonV4 uniqueInstance deserialize: executionData readStream)
			result: (LeJsonV4 uniqueInstance deserialize: result readStream). true').

]

{ #category : #accessing }
GtRrWorker >> taskFailed: aTaskContext with: anError [
	| executionData serializedExecutionData |

	Stdio stdout lf; << 'ensured3'; lf; flush.
	GtRrWorkerTaskCompletedSignal new
		taskId: aTaskContext taskId;
		message: 'ERROR: ' , anError printString;
		emit.
	executionData := GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		errorDetails: (GtRrErrorDetails new
						errorMessage: (anError messageText ifEmpty:
							[ anError printString ]);
						trace: anError stackString);
		additionalData: aTaskContext executionData additionalData.
	serializedExecutionData := LeJsonV4 uniqueInstance serialize: executionData.
	resultQueue nextPut: (GtRrWorkerResultEntry
		worker: self
		task: aTaskContext
		bindings: { 
			#taskContextId -> aTaskContext taskContextId.
			#executionData -> serializedExecutionData. }
		command: 'GtAssignedRemoteRunner 
				taskFailed: taskContextId 
				executionData: (LeJsonV4 uniqueInstance deserialize: executionData readStream). true').

]

{ #category : #accessing }
GtRrWorker >> uid [

	^ uid
]

{ #category : #private }
GtRrWorker >> unregisterWith: aPharoLinkApplication [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

	^ aPharoLinkApplication newCommandFactory sendAndWait: 
		'GtAssignedRemoteRunner unregisterWorkerId: ''', uid, ''' reason: ''Worker stopped'''.

]
