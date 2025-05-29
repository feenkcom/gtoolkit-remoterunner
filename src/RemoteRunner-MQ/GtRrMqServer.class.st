Class {
	#name : #GtRrMqServer,
	#superclass : #Object,
	#instVars : [
		'remoteRunner',
		'mqHostName',
		'mqProcessor',
		'runnerControlChannelName',
		'taskQueueName',
		'taskResultName'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #'as yet unclassified' }
GtRrMqServer >> gtRrStopOnWorker [

	self stop.
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> handleMqListenerException: closingException [

	GtRrWorker isCommandLineWorker ifTrue: [ ^ remoteRunner stop ].
	(mqProcessor isNil or:
		[ mqProcessor isStopRequested or: 
		[ mqProcessor isStopped ] ]) ifTrue: [ ^ self ].
	closingException class = ConnectionClosed
		ifTrue: [ self error: 'Unexpected close request' ]
		ifFalse: [ self error: 'Unexpected loss of connection'
			"mqProcessor reconnect" ].
]

{ #category : #testing }
GtRrMqServer >> isRunning [

	^ mqProcessor isNotNil and:
		[ mqProcessor isRunning ]
]

{ #category : #accessing }
GtRrMqServer >> mqHostName [
	^ mqHostName ifNil: [ 'localhost' ]
]

{ #category : #accessing }
GtRrMqServer >> mqHostName: anObject [
	mqHostName := anObject
]

{ #category : #private }
GtRrMqServer >> mqProcessor [

	^ [ :message | self processMqMessage: message ]
]

{ #category : #accessing }
GtRrMqServer >> newWorkerConnection [

	^ GtRrMqWorkerConnection new
]

{ #category : #'start - stop' }
GtRrMqServer >> purgeQueues [
	"Purge the permanent queues"

	GtRrStompMqProcessor new
		purgeQueue: self taskQueueName;
		purgeQueue: self runnerControlChannelName;
		purgeQueue: self taskResultName.
]

{ #category : #accessing }
GtRrMqServer >> remoteRunner [
	^ remoteRunner
]

{ #category : #accessing }
GtRrMqServer >> remoteRunner: anObject [
	remoteRunner := anObject
]

{ #category : #accessing }
GtRrMqServer >> runnerControlChannelName [

	^ runnerControlChannelName ifNil: 
		[ runnerControlChannelName := '/queue/', NetNameResolver localHostName, '_runner_control' ]
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> sendBlockClosure: aBlockClosure to: workerCommandDestination [

	mqProcessor sendGtMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: workerCommandDestination.
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> sendRpcBlockClosure: aBlockClosure to: workerCommandDestination [

	^ self sendRpcMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: workerCommandDestination.
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> sendRpcMessage: aGtRrMessage to: workerCommandDestination [

	^ mqProcessor sendCommandRpcMessage: aGtRrMessage 
		to: workerCommandDestination.
]

{ #category : #private }
GtRrMqServer >> sendWorkerTaskContext: aWorkerTaskContext [
	| taskMessage |

	GtRrMqQueueTaskStartingSignal new
		taskId: aWorkerTaskContext taskId;
		emit.
	taskMessage := GtRrRunnerTaskMessage new
		task: aWorkerTaskContext.
	mqProcessor sendGtMessage: taskMessage to: self taskQueueName.
	GtRrMqQueueTaskCompletedSignal new
		taskId: aWorkerTaskContext taskId;
		emit.
]

{ #category : #'start - stop' }
GtRrMqServer >> start [

	self assert: mqProcessor isNil.
	self purgeQueues.

	mqProcessor := GtRrStompMqProcessor new
		owner: self;
		commandChannelName: self runnerControlChannelName;
		messageChannelName: self taskResultName.
	mqProcessor start.
	mqProcessor subscribeToTaskMessages.
]

{ #category : #accessing }
GtRrMqServer >> stompMqAdditonalOptions [
	"Answer the addtional command line options for workers using RabbitMQ"
	
	^ Array streamContents: [ :aStream |
		aStream
			nextPut: '--connectionStrategy';
			nextPut: 'stompMq';
			nextPut: '--attribute';
			nextPut: 'stompMqQueueNames';
			nextPut: (String streamContents: [ :sStream |
				sStream 
					<< self runnerControlChannelName;
					<< ':';
					<< self taskQueueName;
					<< ':';
					<< self taskResultName ]) ]
]

{ #category : #accessing }
GtRrMqServer >> stompMqQueueNames [
	"Answer the control channel, task and result queue names, colon separated"
	
	^ String streamContents: [ :sStream |
		sStream 
			<< self runnerControlChannelName;
			<< ':';
			<< self taskQueueName;
			<< ':';
			<< self taskResultName ]
]

{ #category : #'start - stop' }
GtRrMqServer >> stop [

	mqProcessor ifNotNil: [ mqProcessor stop ].
	mqProcessor := nil.
]

{ #category : #'start - stop' }
GtRrMqServer >> stopRequested [
	"The remote runner isn't stopped by the MQ.  Do nothing."
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> stopWorker: workerId [

	self isRunning ifFalse: [ ^ self ].
	mqProcessor sendGtMessage: GtRrRunnerQuitMessage new 
		to: (GtRrStompMqProcessor workerControlTopicNameFor: workerId).
]

{ #category : #accessing }
GtRrMqServer >> taskQueueName [

	^ taskQueueName ifNil: 
		[ taskQueueName := '/queue/', NetNameResolver localHostName, '_task_queue' ]
]

{ #category : #accessing }
GtRrMqServer >> taskResultName [

	^ taskResultName ifNil: 
		[ taskResultName := '/queue/', NetNameResolver localHostName, '_task_result' ]
]
