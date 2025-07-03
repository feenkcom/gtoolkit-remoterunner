Class {
	#name : #GtRemoteRunnerStompMqExamples,
	#superclass : #GtRemoteRunnerProcessExamples,
	#category : #'RemoteRunner-NoTest'
}

{ #category : #examples }
GtRemoteRunnerStompMqExamples >> mqCommandMessage [
	"Confirm basic ability to send a command message"
	<gtExample>
	| worker workerCommandChannelDefinition workerSemaphore runner runnerCommandChannelDefinition gtMessage |

	self setUp.
	workerSemaphore := Semaphore new.
	workerCommandChannelDefinition  := GtRrMqQueueDefinition new
		basename: 'gtrrWorkerControl.1';
		stompName: '/topic/gtrrWorkerControl.1';
		prefetchCount: 100.
	worker := GtRrStompMqProcessor new
		commandChannelDefinition: workerCommandChannelDefinition;
		commandCallback: [ :mqMessage1 :gtMessage1 :owner1 |
			gtMessage := gtMessage1.
			workerSemaphore signal ].
	runnerCommandChannelDefinition := GtRrMqQueueDefinition new
		basename: 'runner_control';
		stompName: '/queue/runner_control';
		prefetchCount: 100.
	runner := GtRrStompMqProcessor new
		commandChannelDefinition: runnerCommandChannelDefinition.

	worker start.
	runner start.

	[ runner sendGtMessage: GtRrPingMessage new to: workerCommandChannelDefinition.
	self waitOn: workerSemaphore for: 20 description: 'Command not received'.
	self assert: gtMessage class = GtRrPingMessage. ]
		ensure: [ worker stop. runner stop. ].
]

{ #category : #examples }
GtRemoteRunnerStompMqExamples >> mqCommandRpcMessage [
	"Confirm the ability to send an RPC and receive a response"
	<gtExample>
	| worker workerCommandChannelDefinition runner runnerCommandChannelDefinition result promise |

	self setUp.
	workerCommandChannelDefinition  := GtRrMqQueueDefinition new
		basename: 'gtrrWorkerControl.1';
		stompName: '/topic/gtrrWorkerControl.1';
		prefetchCount: 100.
	worker := GtRrStompMqProcessor new
		commandChannelDefinition: workerCommandChannelDefinition.
	runnerCommandChannelDefinition := GtRrMqQueueDefinition new
		basename: 'runner_control';
		stompName: '/queue/runner_control';
		prefetchCount: 100.
	runner := GtRrStompMqProcessor new
		commandChannelDefinition: runnerCommandChannelDefinition.
	worker start.
	runner start.

	[ promise := runner sendCommandRpcMessage: (GtRrBlockClosureMessage new
		blockClosure: [ 42 ]) 
			to: workerCommandChannelDefinition
			response: runnerCommandChannelDefinition.
	promise wait
		then: [ :value | result := value ]
		otherwise: [ :ex | self error: ex messageText ].
	self assert: result equals: 42 ]
		ensure: [ worker stop. runner stop. ].
]

{ #category : #examples }
GtRemoteRunnerStompMqExamples >> mqTaskMessage [
	"Confirm basic ability to send a command message"
	<gtExample>
	| worker workerCommandChannelDefinition messageChannelDefinition workerSemaphore runner runnerCommandChannelDefinition times |

	self setUp.
	times := OrderedCollection new: 5.
	workerSemaphore := Semaphore new.
	workerCommandChannelDefinition  := GtRrStompMqProcessor workerControlDefinitionFor: '1'.
	messageChannelDefinition  := GtRrStompMqProcessor taskQueueDefinitionFor: GtRrMqServer taskQueueBaseName.
	worker := GtRrStompMqProcessor new
		commandChannelDefinition: workerCommandChannelDefinition;
		commandCallback: [ :mqMessage1 :gtMessage1 :owner1 |
			self error: 'Shouldn''t be called' ];
		messageChannelDefinition: messageChannelDefinition;
		taskCallback: [ :mqMessage1 :gtMessage1 :owner1 |
			gtMessage1 seconds seconds wait.
			times add: Time microsecondClockValue.
			times size = 5 ifTrue:
				[ workerSemaphore signal ].
			worker write: mqMessage1 ackFrame ].
	runnerCommandChannelDefinition := GtRrStompMqProcessor runnerControlChannelDefinitionFor: 'runner_control'.
	runner := GtRrStompMqProcessor new
		commandChannelDefinition: runnerCommandChannelDefinition.

	[ worker start; subscribeToTaskMessages.
	runner start.
	5 timesRepeat:
		[ runner sendGtMessage: (GtRrWaitMessage new seconds: 1)
			to: messageChannelDefinition ].
	self waitOn: workerSemaphore for: 20 description: 'Command not received'.
	self assert: times size equals: 5.
	self assert: (times last - times first / 1000) > 4000
		description: 'Message returned prematurely'. ]
			ensure: [ worker ifNotNil: #stop. runner ifNotNil: #stop. ].
]

{ #category : #'private - helpers' }
GtRemoteRunnerStompMqExamples >> setUp [

	super setUp.
	GtRrMqServer new purgeQueues.
]

{ #category : #'private - helpers' }
GtRemoteRunnerStompMqExamples >> simpleRunner [
	"Answer a started RemoteRunner.
	It is up to the caller to stop the runner (and thus the workers)."
	| manager |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	GtRrStompMqProcessor defaultHost ifNil:
		[ GtRrStompMqProcessor defaultHost: 'localhost' ].
	manager := GtRrPluggableManager new.
	manager 
		serverManager: GtRrMqServerManager new;
		workerManager: (GtRrWorkerManager new
			forStompMq;
			addArguments: {
				'--attribute'.
				GtRrWorker stompMqQueueNames.
				GtRrMqServer stompMqQueueNamesAttribute. };
			autoRestart: false;
			changesSync: false;
			poolSize: 1).
	remoteRunner := GtRemoteRunnerMq new.
	remoteRunner managerStartupAndShutdown: manager.
	remoteRunner startLogging.

	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	^ remoteRunner
]

{ #category : #'as yet unclassified' }
GtRemoteRunnerStompMqExamples >> workerForRunner: aGtRemoteRunner [
	| newWorker |

	newWorker := GtRrWorker new connectionStrategy: GtRrMqWorkerConnectionStrategy new.
	newWorker attributes
		at: 'changesSync' put: false;
		at: 'stompMqQueueNames' put: GtRrMqServer stompMqQueueNamesAttribute;
		at: 'workerJobId' put: 'anyJob'.
	^ newWorker
]
