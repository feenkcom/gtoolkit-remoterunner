"
GtRrWorker runs on the worker machines as a PharoLink client, requesting tasks from the runner ({{gtClass:GtRemoteRunner}}).
"
Class {
	#name : #GtRrWorker,
	#superclass : #TKTService,
	#instVars : [
		'uid',
		'attributes',
		'application',
		'taskRunner',
		'currentTaskExecution'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorker class >> commandLine [
	<commandline>
	| worker |

	^ self commandLineCommand meaning: [ :args | 
		  | logger serverSocketAddress |
		  args
			  at: #help ifPresent: [ :help | 
				  help value.
				  help context exitSuccess ];
			  at: #log ifPresent: [ 
				  SignalLogger resetAllInstances.
				  logger := RestartingStreamLogger stdout.
				  logger startFor: GtRemoteRunnerAnnouncement , PharoLinkSignal ].
		  serverSocketAddress := ((args at: #serverSocketAddress) at:
			                          #address) value.
		  StringSignal emit: 'Server address: ' , serverSocketAddress.
		  worker := self serverSocketAddress: serverSocketAddress.
		  args occurrencesOf: #attribute do: [ :arg | 
			  worker attributes
				  at: (arg at: #key) value
				  put: (arg at: #value) value ].
		  args at: #codeSync ifPresent: [ worker codeSync: true ].
		  StringSignal emit: 'Running'.
		  worker start.
		  "Hibernate until the process exits"
		  Semaphore new wait ]
]

{ #category : #accessing }
GtRrWorker class >> commandLineCommand [

	^ (ClapCommand id: #remoteRunnerWorker)
		  description: 'Run the RemoteRunner worker';
		  add: ClapFlag forHelp;
		  add: ((ClapFlag id: #log) description: 'Enable logging to stdout');
		  add: ((ClapFlag id: #codeSync) description: 'Enable code-sync');
		  add: ((ClapFlag id: #serverSocketAddress)
				   description:
					   'The server socket address on which to connect for requests';
				   add: (ClapPositional id: #address);
				   yourself);
		  add: ((ClapFlag id: #attribute)
				   description: 'add key/value pairs to attributes';
				   multiple: true;
				   add: (ClapPositional id: #key);
				   add: (ClapPositional id: #value);
				   yourself);
		  yourself
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
GtRrWorker class >> serverSocketAddress: aString [

	^ self new
		application: (self newPharoApplication: aString)
]

{ #category : #observer }
GtRrWorker >> addObserver [
	| commandFactory observer |

	commandFactory := application newCommandFactory.
	observer := commandFactory observerFromCallback: [ :message | 
		            self command: message ].
	observer setByValue.
	"register needs to keep request alive to keep observer alive"
	^ commandFactory send: ('GtAssignedRemoteRunner addObserver: {1}' format:
			   { observer pharoLinkFormattedCode })
]

{ #category : #accessing }
GtRrWorker >> application: aPharoLinkApplication [

	application := aPharoLinkApplication
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

	^ currentTaskExecution ifNotNil: [ currentTaskExecution task taskContextId ]
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
	currentTaskExecution ifNil:
		[ GtRrWorkerCommandAnnouncement new
			message: taskContextId printString, ': can''t terminate: currentTaskExecution isNil';
			emit.
		canTerminate := false. ]
	ifNotNil:
		[ currentTaskExecution task taskContextId = taskContextId ifFalse:
			[ GtRrWorkerCommandAnnouncement new
				message: (String streamContents: [ :stream |
					stream
						print: taskContextId;
						<< ': can''t terminate: current taskContextId = ';
						print: currentTaskExecution task taskContextId ]);
				emit.
			canTerminate := false. ] ].
	canTerminate ifTrue: 
		[ currentTaskExecution terminateWithReason: 'received TerminateCurrentTask from RemoteRunner' ] ]
			ensure: [ Processor activeProcess priority: priority ].
	^ canTerminate
]

{ #category : #private }
GtRrWorker >> currentProcessId [
	"Answer the PID of this OS process"

	^ OSPlatform current name = #Win32
		  ifTrue: [ 0 ]
		  ifFalse: [ LibC uniqueInstance currentProcessId ]
]

{ #category : #accessing }
GtRrWorker >> initialize [

	super initialize.
	uid := UUID new asString.
	taskRunner := TKTNewProcessTaskRunner new.
	"Attributes is a dictionary of information can be json encoded.
	Additional values can be provided, or existing values overwritten, by the command line.
	This is used by the remote runner to determine which workers can run a given task (the constraints).
	Naming is inconsistent at the moment - 'attributes' are called 'details' GtRemoteRunner."
	attributes := Dictionary new
		at: #workingDirectory
		put: FileLocator workingDirectory resolve fullName;
		at: #id put: uid;
		at: #pid put: self currentProcessId;
		at: #platform put: OSPlatform current name;
		yourself
]

{ #category : #private }
GtRrWorker >> kill [

	super kill.
	application stop.
	taskRunner stop
]

{ #category : #accessing }
GtRrWorker >> name [

	^ 'GtRrWorker poll service'
]

{ #category : #private }
GtRrWorker >> nextTask [
	| promise |
	
	promise := application newCommandFactory send:
		'GtAssignedRemoteRunner nextTaskSerializedForCurrentWorker'.
	^ LeJsonV4 uniqueInstance deserialize: promise waitForValue readStream

]

{ #category : #private }
GtRrWorker >> registerWithRunner [
	"Register the receiver with the remote runner"

	application newCommandFactory 
		bindingAt: #attributes put: attributes;
		sendAndWait: 'GtAssignedRemoteRunner registerWorkerWithDetails: attributes'.

]

{ #category : #observer }
GtRrWorker >> removeObserver [

	^ application newCommandFactory send: 'GtAssignedRemoteRunner removeObserver'
]

{ #category : #private }
GtRrWorker >> stackString [

	^ String streamContents: [ :stream |
		thisContext stack do: [ :stackItem |
			stream print: stackItem; cr ] ]
]

{ #category : #starting }
GtRrWorker >> start [

	application start.
	self registerWithRunner.
	self addObserver.
	super start
]

{ #category : #stepping }
GtRrWorker >> stepService [
	| task |

	task := self nextTask.

	GtRrWorkerTaskStartedAnnouncement new
		task: task;
		emit.
	currentTaskExecution := task asTask futureTaskExecutionFor: taskRunner.
	currentTaskExecution timeout: task taskTimeout.
	taskRunner scheduleTaskExecution: currentTaskExecution.
	currentTaskExecution future
		onSuccessDo: [ :result | 
			GtRrWorkerTaskCompletedAnnouncement new
				task: task;
				message: 'Success: ', result printString;
				emit.
			self taskDone: task with: result ];
		onFailureDo: [ :error | 
			GtRrWorkerTaskCompletedAnnouncement new
				task: task;
				message: 'ERROR: ', error printString;
				emit.
			self taskFailed: task with: error ];
		waitForCompletion: 1 day.
	currentTaskExecution := nil.
]

{ #category : #stopping }
GtRrWorker >> stop [

	super stop.
	application stop.

]

{ #category : #accessing }
GtRrWorker >> taskDone: aTask with: anObject [

	StringSignal emit: ('done {1} with {2}' format: { 
				 aTask.
				 anObject }).
	^ application newCommandFactory
		  bindingAt: #taskContextId put: aTask taskContextId;
		  bindingAt: #result
		  put: (LeJsonV4 uniqueInstance serialize: anObject);
		  sendAndWait:
			  'GtAssignedRemoteRunner taskDone: taskContextId with: (LeJsonV4 uniqueInstance deserialize: result readStream). true'
]

{ #category : #accessing }
GtRrWorker >> taskFailed: aTask with: anError [

	StringSignal emit: ('failed {1} with {2}' format: { 
				 aTask.
				 anError }).
	^ application newCommandFactory
		  bindingAt: #taskContextId put: aTask taskContextId;
		  bindingAt: #errorDetails put: (LeJsonV4 uniqueInstance serialize: 
				(GtRrErrorDetails new
					errorMessage: anError messageText;
					trace: anError stackString));
		  sendAndWait:
			  'GtAssignedRemoteRunner taskFailed: taskContextId with: (LeJsonV4 uniqueInstance deserialize: errorDetails readStream). true'
]

{ #category : #accessing }
GtRrWorker >> uid [

	^ uid
]
