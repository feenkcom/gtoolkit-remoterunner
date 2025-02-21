Class {
	#name : #GtRemoteRunnerStompMqExamples,
	#superclass : #GtRemoteRunnerProcessExamples,
	#category : #'RemoteRunner-MQ-Examples'
}

{ #category : #examples }
GtRemoteRunnerStompMqExamples >> mqCommandMessage [
	"Confirm basic ability to send a command message"
	<gtExample>
	| worker workerCommandChannel workerSemaphore runner runnerCommandChannel gtMessage |

	workerSemaphore := Semaphore new.
	workerCommandChannel  := '/topic/gtrrWorkerControl.1'.
	worker := GtRrStompMqProcessor new
		commandChannelName: workerCommandChannel;
		commandCallback: [ :mqMessage1 :gtMessage1 :owner1 |
			gtMessage := gtMessage1.
			workerSemaphore signal ].
	runnerCommandChannel := '/queue/runner_control'.
	runner := GtRrStompMqProcessor new
		commandChannelName: runnerCommandChannel.

	worker start.
	runner start.

	[ runner sendGtMessage: GtRrPingMessage new to: workerCommandChannel.
	self waitOn: workerSemaphore for: 20 description: 'Command not received'.
	self assert: gtMessage class = GtRrPingMessage ]
		ensure: [ worker stop. runner stop. ].
]

{ #category : #examples }
GtRemoteRunnerStompMqExamples >> mqCommandRpcMessage [
	"Confirm the ability to send an RPC and receive a response"
	<gtExample>
	| worker workerCommandChannel runner runnerCommandChannel result promise |

	workerCommandChannel  := '/topic/gtrrWorkerControl.1'.
	worker := GtRrStompMqProcessor new
		commandChannelName: workerCommandChannel.
	runnerCommandChannel := '/queue/runner_control'.
	runner := GtRrStompMqProcessor new
		commandChannelName: runnerCommandChannel.

	worker start.
	runner start.

	[ promise := runner sendCommandRpcMessage: (GtRrBlockClosureMessage new
		blockClosure: [ 42 ]) 
			to: workerCommandChannel
			response: runnerCommandChannel.
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
	| worker workerCommandChannel workerSemaphore runner runnerCommandChannel times |

	self purgeQueues.
	times := OrderedCollection new: 5.
	workerSemaphore := Semaphore new.
	workerCommandChannel  := '/topic/gtrrWorkerControl.1'.
	worker := GtRrStompMqProcessor new
		commandChannelName: workerCommandChannel;
		commandCallback: [ :mqMessage1 :gtMessage1 :owner1 |
			self error: 'Shouldn''t be called' ];
		messageChannelName: GtRrStompMqProcessor taskQueueName;
		messageCallback: [ :mqMessage1 :gtMessage1 :owner1 |
			gtMessage1 seconds seconds wait.
			times add: Time microsecondClockValue.
			times size = 5 ifTrue:
				[ workerSemaphore signal ] ].
	runnerCommandChannel := '/queue/runner_control'.
	runner := GtRrStompMqProcessor new
		commandChannelName: runnerCommandChannel.

	worker start; subscribeToMessages.
	runner start.

	[ 5 timesRepeat:
		[ runner sendGtMessage: (GtRrWaitMessage new seconds: 1)
			to: GtRrStompMqProcessor taskQueueName ].
	self waitOn: workerSemaphore for: 20 description: 'Command not received'.
	self assert: times size equals: 5.
	self assert: (times last - times first / 1000) > 4000
		description: 'Message returned prematurely'. ]
			ensure: [ worker stop. runner stop. ].
]

{ #category : #'private - helpers' }
GtRemoteRunnerStompMqExamples >> purgeQueues [
	"Purge the queues that require manual acknowledgement"

	GtRrStompMqProcessor new
		purgeQueue: GtRrStompMqProcessor taskQueueName;
		purgeQueue: GtRrStompMqProcessor runnerControlChannelName;
		purgeQueue: GtRrStompMqProcessor taskResultName.
]

{ #category : #'private - helpers' }
GtRemoteRunnerStompMqExamples >> simpleRunner [
	"Answer a started RemoteRunner.
	It is up to the caller to stop the runner (and thus the workers)."
	| manager |

	self ignoreWorkerExamples ifTrue: [ ^ self ].
	manager := GtRrPluggableManager new.
	manager 
		serverManager: GtRrMqServerManager new;
		workerManager: (GtRrWorkerManager new
			forLocalStompMq;
			autoRestart: false;
			changesSync: false;
			poolSize: 1).
	remoteRunner := GtRemoteRunnerMq new.
	remoteRunner managerStartupAndShutdown: manager.

	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	^ remoteRunner
]

{ #category : #'as yet unclassified' }
GtRemoteRunnerStompMqExamples >> workerForRunner: aGtRemoteRunner [

	^ GtRrWorker new
		connectionStrategy: GtRrMqWorkerConnectionStrategy new
]
