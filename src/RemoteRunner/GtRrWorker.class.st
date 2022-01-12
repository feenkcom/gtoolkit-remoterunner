"
GtRrWorker runs on the worker machines as a PharoLink client, requesting tasks from the runner ({{gtClass:GtRemoteRunner}}).
"
Class {
	#name : #GtRrWorker,
	#superclass : #TKTService,
	#instVars : [
		'uid',
		'application',
		'taskRunner',
		'currentTaskExecution',
		'attributes'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorker class >> commandLine [

	<commandline>
	^ self commandLineCommand meaning: [ :args | 
		  | worker serverSocketAddress |
		  args
			  at: #help ifPresent: [ :help | 
				  help value.
				  help context exitSuccess ];
			  at: #log ifPresent: [ 
				  | logger |
				  SignalLogger resetAllInstances.
				  logger := RestartingStreamLogger stdout.
				  logger startFor: GtRemoteRunnerAnnouncement , PharoLinkSignal ].
		  args
			  at: #serverSocketAddress
			  ifPresent: [ :arg | 
			  serverSocketAddress := (arg at: #address) value ]
			  ifAbsent: [ 
				  self flag: 'TODO maenu figure out how to make commands required'.
				  args context exitFailure: '--serverSocketAddress is required' ].
		  worker := self serverSocketAddress: serverSocketAddress.
		  args occurrencesOf: #attribute do: [ :arg | 
			  worker
				  attributeAt: (arg at: #key) value
				  put: (arg at: #value) value ].
		  StringSignal emit: 'Connecting to : ' , serverSocketAddress.
		  worker start.
		  StringSignal emit: 'Connected'.
		  "Hibernate until the process exits"
		  Semaphore new wait ]
]

{ #category : #accessing }
GtRrWorker class >> commandLineCommand [

	^ (ClapCommand id: #remoteRunnerWorker)
		  description: 'Run the RemoteRunner worker';
		  add: ClapFlag forHelp;
		  add: ((ClapFlag id: #log) description: 'Enable logging to stdout');
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
	"register needs to keep request alive to keep observer alive"
	^ commandFactory send: ('GtAssignedRemoteRunner addObserver: {1}' format:
			   { observer pharoLinkFormattedCode })
]

{ #category : #accessing }
GtRrWorker >> application: aPharoLinkApplication [

	application := aPharoLinkApplication
]

{ #category : #accessing }
GtRrWorker >> attributeAt: aString [

	^ attributes at: aString
]

{ #category : #accessing }
GtRrWorker >> attributeAt: aString ifAbsent: absentBlock [

	^ attributes at: aString ifAbsent: absentBlock
]

{ #category : #accessing }
GtRrWorker >> attributeAt: aString ifPresent: aBlock [

	^ attributes at: aString ifPresent: aBlock
]

{ #category : #accessing }
GtRrWorker >> attributeAt: aString ifPresent: aBlock ifAbsent: anotherBlock [

	^ attributes at: aString ifPresent: aBlock ifAbsent: anotherBlock
]

{ #category : #accessing }
GtRrWorker >> attributeAt: aSimpleObject put: anotherSimpleObject [

	attributes at: aSimpleObject put: anotherSimpleObject
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
	taskRunner := TKTNewProcessTaskRunner new.
	"Details is a dictionary of information can be json encoded.
	Apart from the platform, this is mostly useful for debugging."
	attributes := Dictionary new
		              at: #workingDirectory
		              put: FileLocator workingDirectory resolve fullName;
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
	promise := application newCommandFactory
		           bindingAt: #attributes put: attributes;
		           send:
			           'GtAssignedRemoteRunner nextTaskSerializedFor: attributes'.
	^ LeJsonV4 uniqueInstance deserialize:
		  promise waitForValue readStream
]

{ #category : #private }
GtRrWorker >> registerWithRunner [

	"Register the receiver with the remote runner"

	application newCommandFactory
		bindingAt: #attributes put: attributes;
		sendAndWait:
			'GtAssignedRemoteRunner registerWorkerWithAttributes: attributes'
]

{ #category : #observer }
GtRrWorker >> removeObserver [

	^ application newCommandFactory send: 'GtAssignedRemoteRunner removeObserver'
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
	currentTaskExecution := task asTask futureTaskExecutionFor:
		                        taskRunner.
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
