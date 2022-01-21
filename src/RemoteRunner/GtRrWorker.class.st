"
GtRrWorker runs on the worker machines as a PharoLink client, requesting tasks from the runner ({{gtClass:GtRemoteRunner}}).
"
Class {
	#name : #GtRrWorker,
	#superclass : #TKTService,
	#instVars : [
		'uid',
		'rrPlatform',
		'application',
		'taskRunner',
		'currentTaskExecution',
		'codeSync'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorker class >> commandLine [

	<commandline>
	| service |
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
		  StringSignal emit:
			  'Connect server socket address: ' , serverSocketAddress.
		  service := self serverSocketAddress: serverSocketAddress.
		  args at: #codeSync ifPresent: [ service codeSync: true ].
		  StringSignal emit: 'Running'.
		  service start.
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

{ #category : #accessing }
GtRrWorker >> codeSync [

	^ codeSync
]

{ #category : #accessing }
GtRrWorker >> codeSync: anObject [

	codeSync := anObject
]

{ #category : #observer }
GtRrWorker >> command: anArray [
	"Execute the command sent from the remote runner.
	The message is encoded as { selector. arguments. lookupClass. }"
	| message |

	message := Message
		selector: anArray first asSymbol
		arguments: anArray second.
	message lookupClass: anArray third.
	^ message sendTo: self
]

{ #category : #accessing }
GtRrWorker >> commandApplyCodeChanges: aFuelStringOfCollection [

	| changes |
	changes := LanguageLinkUtils base64Decode:
		           aFuelStringOfCollection readStream.
	changes do: #applyCodeChange.
	^ true
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
	| result priority |

	result := false.
	"Once we start we don't want to be interrupted by the task, since it may change"
	priority := Processor activeProcess priority.
	[ Processor activeProcess priority: priority + 1.
	(currentTaskExecution isNotNil and: [ currentTaskExecution task taskContextId = taskContextId ]) ifTrue: 
		[ currentTaskExecution terminateWithReason: 'received TerminateCurrentTask from RemoteRunner'.
		result := true ] ]
			ensure: [ Processor activeProcess priority: priority ].
	^ result.
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
	rrPlatform := OSPlatform current name.
	taskRunner := TKTNewProcessTaskRunner new.
	codeSync := false
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
		(String streamContents: [ :stream |
			stream
				<< 'GtAssignedRemoteRunner nextTaskSerializedFor: ';
				print: rrPlatform ]).
	^ LeJsonV4 uniqueInstance deserialize: promise waitForValue readStream

]

{ #category : #private }
GtRrWorker >> registerWithRunner [
	"Register the receiver with the remote runner"
	| details |

	"Details is a dictionary of information can be json encoded.
	Apart from the platform, this is mostly useful for debugging."
	details := Dictionary new
		at: #workingDirectory put: FileLocator workingDirectory resolve fullName;
		at: #pid put: self currentProcessId;
		at: #platform put: rrPlatform;
		at: #codeSync put: codeSync;
		at: #vmBuildDate put: Smalltalk vm buildDate;
		at: #gtVersion put: GtImage instance version versionString;
		at: #imageVersion put: SystemVersion current asString;
		yourself.
	application newCommandFactory 
		bindingAt: #details put: details;
		sendAndWait: 'GtAssignedRemoteRunner registerWorkerWithDetails: details'.

]

{ #category : #observer }
GtRrWorker >> removeObserver [

	^ application newCommandFactory send: 'GtAssignedRemoteRunner removeObserver'
]

{ #category : #accessing }
GtRrWorker >> rrPlatform [

	^ rrPlatform
]

{ #category : #accessing }
GtRrWorker >> rrPlatform: anObject [

	rrPlatform := anObject
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

	currentTaskExecution := task asTask futureTaskExecutionFor: taskRunner.
	currentTaskExecution timeout: task taskTimeout.
	taskRunner scheduleTaskExecution: currentTaskExecution.
	currentTaskExecution future
		onSuccessDo: [ :result | self taskDone: task with: result ];
		onFailureDo: [ :error | self taskFailed: task with: error ];
		waitForCompletion: 1 day
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
