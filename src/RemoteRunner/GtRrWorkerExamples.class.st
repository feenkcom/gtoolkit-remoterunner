Class {
	#name : #GtRrWorkerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#instVars : [
		'runner',
		'process'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #private }
GtRrWorkerExamples >> cleanUp [

	runner ifNotNil:
		[ runner stop.
		runner := nil ].
	process ifNotNil:
		[ process isTerminated ifFalse: [ process terminate ].
		process := nil ]
]

{ #category : #examples }
GtRrWorkerExamples >> commandLineWithAttributes [
	"Demonstrate parsing the Remote Runner Worker command line"
	<gtExample>
	| commandLine attributes |

	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker' 
		'--serverSocketAddress' '7084'
		'--attribute' 'attr1' 'v1'
		'--attribute' 'attr2' 'v2').

	self assert: (commandLine at: #log) value equals: false.
	self assert: ((commandLine at: #serverSocketAddress) at: #address) value equals: '7084'.
	attributes := commandLine occurrencesOf: #attribute collect:
		[ :attr | { (attr at: #key) value. (attr at: #value) value. } ].
	self assert: attributes asArray equals:
		#(('attr1' 'v1') ('attr2' 'v2')).

	^ commandLine
]

{ #category : #examples }
GtRrWorkerExamples >> commandLineWithStrategy [
	"Demonstrate parsing the Remote Runner Worker command line"
	<gtExample>
	| commandLine connectionStrategyId |

	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker').

	connectionStrategyId := commandLine 
		at: #connectionStrategy
		ifPresent: [ :arg | (arg at: #strategyId) value ]
		ifAbsent: [ #perMessage ].

	self assert: connectionStrategyId equals: #perMessage.


	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker' 
		'--connectionStrategy' 'single').

	connectionStrategyId := commandLine 
		at: #connectionStrategy
		ifPresent: [ :arg | (arg at: #strategyId) value ]
		ifAbsent: [ #perMessage ].

	self assert: connectionStrategyId equals: #single.


	^ commandLine
]

{ #category : #examples }
GtRrWorkerExamples >> commandLineWithoutAttributes [
	"Demonstrate parsing the Remote Runner Worker command line"
	<gtExample>
	| commandLine |

	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker' '--log' '--serverSocketAddress' '7084').

	self assert: (commandLine at: #log) value equals: true.
	self assert: ((commandLine at: #serverSocketAddress) at: #address) value equals: '7084'.

	^ commandLine
]

{ #category : #private }
GtRrWorkerExamples >> waitOn: aSemaphore description: descriptionString [

	(aSemaphore waitTimeoutSeconds: 10)
		ifTrue: [ self error: descriptionString ]
]

{ #category : #examples }
GtRrWorkerExamples >> workerControlChannelCommandTimeout [
	"Demonstrate timing out the worker when a control channel command doesn't respond in time"
	<gtExample>
	<noTest>
	<after: #cleanUp>
	| workerConnection semaphore registered timeoutScheduled timeoutAnnounced unregistered |

	self assert: runner isNil.
	semaphore := Semaphore new.
	registered := timeoutScheduled := timeoutAnnounced := unregistered := false.
	runner := GtRemoteRunner new
		port: 7082;
		managerStartupAndShutdown: GtRrLocalManagerStartupAndShutdown new;
		workerTimeout: 2 seconds.
	runner managerStartupAndShutdown
		poolSize: 1;
		connectionStrategyId: #single;
		autoRestart: false.
	runner
		when: GtRrWorkerControlChannelRegisteredAnnouncement 
			do: [ :ann | 
				registered := true.
				semaphore signal ] 
			for: self;
		when: GtRrTimeoutScheduledAnnouncement
			do: [ :ann | 
				timeoutScheduled := true.
				semaphore signal ] 
			for: self;
		when: GtRrWorkerTimeoutAnnouncement
			do: [ :ann | 
				timeoutAnnounced := true.
				semaphore signal ] 
			for: self;
		when: GtRrWorkerUnregisteredAnnouncement
			do: [ :ann | 
				unregistered := true.
				semaphore signal ] 
			for: self.
	runner start.
	self waitOn: semaphore description: 'Didn''t get worker control channel'.
	self assert: registered.
	workerConnection := runner registeredWorkers anyOne.

	process := [ 
		[ workerConnection commandEvaluate: '1 minute wait' ]
			on: PharoLinkServerConnectionLost 
			do: [ :ex | ] ] fork.

	#(GtRrTimeoutScheduledAnnouncement GtRrWorkerTimeoutAnnouncement GtRrWorkerUnregisteredAnnouncement) do: [ :announcement |
		self waitOn: semaphore description: 'Didn''t receive: ', announcement printString ].

	self assert: timeoutScheduled.
	self assert: timeoutAnnounced.
	self assert: unregistered.
	self assert: runner registeredWorkerCount equals: 0.
	^ runner.
]
