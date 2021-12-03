"
GtRrWorker runs on the worker machines as a PharoLink client, requesting tasks from the runner ({{gtClass:GtRrRemoteRunner}}).
"
Class {
	#name : #GtRrWorker,
	#superclass : #PharoLinkApplication,
	#instVars : [
		'uid',
		'rrPlatform'
	],
	#category : #'RemoteRunner-Model'
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
				  logger start ].
		  serverSocketAddress := (args at: #serverSocketAddress) value.
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

	^ (ClapCommand id: 'pharoLinkWorker')
		  description: 'Run the PharoLink worker';
		  add: ClapFlag forHelp;
		  add: ((ClapFlag id: 'log') description: 'Enable logging to stdout');
		  add: ((ClapFlag id: 'taskPollForever') description: 'Poll tasks forever');
		  add: ((ClapPositional id: 'serverSocketAddress') description:
					   'The server socket address on which to connect for requests');
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
GtRrWorker >> taskDone: aTask with: anObject [

	StringSignal emit: ('done {1} with {2}' format: { 
				 aTask.
				 anObject }).
	^ self newCommandFactory
		  bindingAt: #taskId put: aTask id;
		  bindingAt: #result
		  put: (LeJsonV4 uniqueInstance serialize: anObject);
		  sendAndWait:
			  'GtAssignedRemoteRunner taskDone: taskId with: (LeJsonV4 uniqueInstance deserialize: result readStream). true'
]

{ #category : #accessing }
GtRrWorker >> taskFailed: aTask with: anError [

	StringSignal emit: ('failed {1} with {2}' format: { 
				 aTask.
				 anError }).
	^ self newCommandFactory
		  bindingAt: #taskId put: aTask id;
		  bindingAt: #stackString put: anError stackString;
		  sendAndWait:
			  'taskQueue taskFailed: taskId with: stackString. true'
]

{ #category : #accessing }
GtRrWorker >> taskPoll [

	| promise |
	promise := self newCommandFactory send: 
		(String streamContents: [ :stream |
			stream
				<< 'GtAssignedRemoteRunner nextTaskSerializedFor: ';
				<< uid;
				<< ' platform: ';
				<< rrPlatform ]).
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
