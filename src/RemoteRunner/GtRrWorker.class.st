"
GtRrWorker runs on the worker machines as a PharoLink client, requesting tasks from the runner ({{gtClass:GtRemoteRunner}}).
"
Class {
	#name : #GtRrWorker,
	#superclass : #PharoLinkApplication,
	#instVars : [
		'uid',
		'rrPlatform'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorker class >> commandLine [
	<commandline>
	| application |

	^ self commandLineCommand meaning: [ :args | 
		  | logger serverSocketAddress |
		  args
			  at: #help ifPresent: [ :help | 
				  help value.
				  help context exitSuccess ];
			  at: #log ifPresent: [ 
				  SignalLogger resetAllInstances.
				  logger := RestartingStreamLogger stdout.
				  logger startFor: GtRrBeaconSignal, PharoLinkSignal ].
		  serverSocketAddress := ((args at: #serverSocketAddress) at: #address) value.
		  StringSignal emit:
			  'Connect server socket address: ' , serverSocketAddress.
		  application := self newWith: (self defaultSettings
				                  serverProcessClass: LanguageLinkManualProcess;
				                  serverSocketAddress:
					                  (LanguageLinkSocketAddress from:
							                   serverSocketAddress);
				                  yourself).
		  StringSignal emit: 'Running'.
		  application start.
		  args
			  at: #taskPollForever
			  ifPresent: [ application taskPollForever ] ]
]

{ #category : #accessing }
GtRrWorker class >> commandLineCommand [

	^ (ClapCommand id: #remoteRunnerWorker)
		  description: 'Run the RemoteRunner worker';
		  add: ClapFlag forHelp;
		  add: ((ClapFlag id: #log) description: 'Enable logging to stdout');
		  add: ((ClapFlag id: #taskPollForever) description: 'Poll tasks forever');
		  add: ((ClapFlag id: #serverSocketAddress) 
					description: 'The server socket address on which to connect for requests';
					add: (ClapPositional id: #address);
					yourself);
		  yourself
]

{ #category : #initialization }
GtRrWorker >> initialize [

	super initialize.
	uid := UUID new asString.
	rrPlatform := OSPlatform current name.
]

{ #category : #accessing }
GtRrWorker >> rrPlatform [

	^ rrPlatform
]

{ #category : #accessing }
GtRrWorker >> rrPlatform: anObject [

	rrPlatform := anObject
]

{ #category : #accessing }
GtRrWorker >> start [

	super start.
	self newCommandFactory sendAndWait:
		'GtAssignedRemoteRunner registerWorkerWithPlatform: ''', rrPlatform, ''''.
]

{ #category : #accessing }
GtRrWorker >> taskDone: aTask with: anObject [

	StringSignal emit: ('done {1} with {2}' format: { 
				 aTask.
				 anObject }).
	^ self newCommandFactory
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
	^ self newCommandFactory
		  bindingAt: #taskContextId put: aTask taskContextId;
		  bindingAt: #errorDetails put: (LeJsonV4 uniqueInstance serialize: 
				(GtRrErrorDetails new
					errorMessage: anError messageText;
					trace: anError stackString));
		  sendAndWait:
			  'GtAssignedRemoteRunner taskFailed: taskContextId with: (LeJsonV4 uniqueInstance deserialize: errorDetails readStream). true'
]

{ #category : #accessing }
GtRrWorker >> taskPoll [
	| promise |

	promise := self newCommandFactory send: 
		(String streamContents: [ :stream |
			stream
				<< 'GtAssignedRemoteRunner nextTaskSerializedFor: ';
				print: rrPlatform ]).
	^ LeJsonV4 uniqueInstance deserialize: promise waitForValue readStream
]

{ #category : #accessing }
GtRrWorker >> taskPollForever [

	[ self taskRun: self taskPoll ] repeat
]

{ #category : #accessing }
GtRrWorker >> taskRun: aTask [

	| result error |
	StringSignal emit: ('run {1}' format: { aTask }).
	[ result := aTask run ]
		on: Error
		do: [ :e | 
			e freeze.
			error := e ].
	error
		ifNil: [ self taskDone: aTask with: result ]
		ifNotNil: [ self taskFailed: aTask with: error ]
]

{ #category : #accessing }
GtRrWorker >> uid [

	^ uid
]
