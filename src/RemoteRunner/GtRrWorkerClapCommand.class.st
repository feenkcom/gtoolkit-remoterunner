Class {
	#name : #GtRrWorkerClapCommand,
	#superclass : #ClapApplication,
	#category : #'RemoteRunner-Worker'
}

{ #category : #'command line' }
GtRrWorkerClapCommand class >> commandLineCommand [

	^ (ClapCommandSpec id: self commandLineName)
		description: 'Run the RemoteRunner worker';
		addGtGlobalOptions;
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

{ #category : #'command line' }
GtRrWorkerClapCommand class >> commandLineName [

	^ #remoteRunnerWorker
]

{ #category : #execution }
GtRrWorkerClapCommand >> execute [

	self executeWithArgs: (self context match at: self class commandLineName)

]

{ #category : #execution }
GtRrWorkerClapCommand >> executeWithArgs: args [
	"To maintain Pharo 12 compatibility this method still works directly with the clap args (match).
	After Pharo 12 compatibility is dropped it should be converted to use the inherited API."
	| worker connectionStrategyId connectionStrategy serverSocketAddress workerClass |

	args at: #help
		ifPresent: 
			[:help |
			help value.
			help context exitSuccess].
	Stdio stdout
		<< Smalltalk commandLineString;
		lf.
	workerClass := self class environment at: (args
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
