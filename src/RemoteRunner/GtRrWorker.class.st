"
GtRrWorker runs on the worker machines as a PharoLink client, requesting tasks from the runner ({{gtClass:GtRemoteRunner}}).
"
Class {
	#name : #GtRrWorker,
	#superclass : #TKTService,
	#instVars : [
		'uid',
		'application',
		'attributes',
		'taskWorker',
		'connected'
	],
	#category : #'RemoteRunner-Runner'
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
				  logger startFor: GtRrAnnouncement , PharoLinkSignal ].
		  args
			  at: #serverSocketAddress
			  ifPresent: [ :arg | 
			  serverSocketAddress := (arg at: #address) value ]
			  ifAbsent: [ 
				  self flag: 'TODO maenu figure out how to make commands required'.
				  args context exitFailure: '--serverSocketAddress is required' ].
		  worker := self serverSocketAddress: serverSocketAddress.
		  args occurrencesOf: #attribute do: [ :arg | 
			  worker attributes
				  at: (arg at: #key) value
				  put: (arg at: #value) value ].
		  StringSignal emit: 'Connecting to : ' , serverSocketAddress.
		  worker launch.
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

{ #category : #accessing }
GtRrWorker >> application: aPharoLinkApplication [

	application := aPharoLinkApplication
]

{ #category : #accessing }
GtRrWorker >> attributes [

	^ attributes
]

{ #category : #commands }
GtRrWorker >> command: anArray [

	"Execute the command sent from the remote runner.
	The message is encoded as { selector. arguments. lookupClass }"

	| message priority |
	message := Message
		           selector: anArray first asSymbol
		           arguments: anArray second.
	message lookupClass: anArray third.
	"commands take priority over workers"
	priority := Processor activeProcess priority.
	^ [ 
	  Processor activeProcess priority: worker processPriority + 1.
	  message sendTo: self ] ensure: [ 
		  Processor activeProcess priority: priority ]
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
GtRrWorker >> commandConnected [

	"Signals the end of the initial connection, can now pull tasks"

	connected signal.
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
GtRrWorker >> commandTerminateTaskId: aTaskId [

	"Terminate the current task, confirming the context id"

	| currentTaskExecution |
	currentTaskExecution := taskWorker currentTaskExecution.
	currentTaskExecution ifNil: [ ^ false ].
	currentTaskExecution task id = aTaskId ifFalse: [ ^ false ].
	currentTaskExecution terminateWithReason:
		'received TerminateTaskId: from RemoteRunner'.
	^ true
]

{ #category : #private }
GtRrWorker >> connect [

	"Register the receiver with the remote runner.
	Register needs to keep request alive to keep observer alive"

	| commandFactory observer |
	commandFactory := application newCommandFactory.
	observer := commandFactory observerFromCallback: [ :message | 
		            self command: message ].
	^ commandFactory
		  bindingAt: #attributes put: attributes;
		  send:
			  ('GtAssignedRemoteRunner connectWithAttributes: attributes observer: {1}. true' 
				   format: { observer pharoLinkFormattedCode })
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
	connected := Semaphore new.
	"put this at lower priority, but to what? taskWorker runs tasks, worker runs service steps"
	taskWorker := TKTWorker new
		              name: 'GtRrWorker task worker';
		              processPriority: Processor activeProcess priority;
		              yourself.
	worker processPriority: Processor activeProcess priority.
	"Details is a dictionary of information can be json encoded.
	Apart from the platform, this is mostly useful for debugging."
	attributes := Dictionary new
		              at: #workingDirectory
		              put: FileLocator workingDirectory resolve fullName;
		              at: #pid put: self currentProcessId;
		              at: #platform put: OSPlatform current name;
		              yourself
]

{ #category : #accessing }
GtRrWorker >> name [

	^ 'GtRrWorker poll service'
]

{ #category : #starting }
GtRrWorker >> setUp [

	super setUp.
	application start.
	taskWorker start.
	self connect.
	connected wait
]

{ #category : #stepping }
GtRrWorker >> stepService [

	| task |
	"#taskNext and #waitForCompletion: wait"
	task := self taskNext.
	(taskWorker future: task timeout: task timeout)
		onSuccessDo: [ :result | self task: task success: result ];
		onFailureDo: [ :error | self task: task failure: error ];
		waitForCompletion: 1 day
]

{ #category : #accessing }
GtRrWorker >> task: aTask failure: anError [

	StringSignal emit: ('failed {1} with {2}' format: { 
				 aTask.
				 anError }).
	^ application newCommandFactory
		  bindingAt: #id put: aTask id;
		  bindingAt: #error
		  put: (LeJsonV4 uniqueInstance serialize: anError gtRrAsError);
		  sendAndWait:
			  'GtAssignedRemoteRunner task: id failure: (LeJsonV4 uniqueInstance deserialize: error readStream). true'
]

{ #category : #accessing }
GtRrWorker >> task: aTask success: anObject [

	StringSignal emit: ('done {1} with {2}' format: { 
				 aTask.
				 anObject }).
	^ application newCommandFactory
		  bindingAt: #id put: aTask id;
		  bindingAt: #result
		  put: (LeJsonV4 uniqueInstance serialize: anObject);
		  sendAndWait:
			  'GtAssignedRemoteRunner task: id success: (LeJsonV4 uniqueInstance deserialize: result readStream). true'
]

{ #category : #private }
GtRrWorker >> taskNext [

	| promise |
	promise := application newCommandFactory send:
		           'LeJsonV4 uniqueInstance serialize: GtAssignedRemoteRunner taskNext'.
	^ LeJsonV4 uniqueInstance deserialize:
		  promise waitForValue readStream
]

{ #category : #stopping }
GtRrWorker >> tearDown [

	taskWorker stop.
	application stop.
	super tearDown
]

{ #category : #accessing }
GtRrWorker >> uid [

	^ uid
]
