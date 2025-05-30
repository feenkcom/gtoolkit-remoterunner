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

{ #category : #accessing }
GtRrMqServer class >> runnerControlChannelName [

	^ '/queue/', NetNameResolver localHostName, '_runner_control'
]

{ #category : #accessing }
GtRrMqServer class >> stompMqQueueNamesAttribute [
	"Answer the queue names as passed to the worker on the command line"
	
	^ String streamContents: [ :sStream |
		sStream 
			<< self runnerControlChannelName;
			<< ':';
			<< self taskQueueName;
			<< ':';
			<< self taskResultName ]
]

{ #category : #accessing }
GtRrMqServer class >> taskQueueName [

	^ '/queue/', NetNameResolver localHostName, '_task_queue'
]

{ #category : #accessing }
GtRrMqServer class >> taskResultName [

	^ '/queue/', NetNameResolver localHostName, '_task_result'
]

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

{ #category : #'as yet unclassified' }
GtRrMqServer >> initialize [

	super initialize.
	mqProcessor := GtRrStompMqProcessor new
		owner: self.
]

{ #category : #testing }
GtRrMqServer >> isRunning [

	^ mqProcessor isNotNil and:
		[ mqProcessor isRunning ]
]

{ #category : #accessing }
GtRrMqServer >> mqHostName [
	^ mqProcessor mqHostName
]

{ #category : #accessing }
GtRrMqServer >> mqHostName: aString [

	mqProcessor mqHostName: aString
]

{ #category : #accessing }
GtRrMqServer >> mqPassword [

	^ mqProcessor mqPassword
]

{ #category : #accessing }
GtRrMqServer >> mqPassword: aString [

	mqProcessor mqPassword: aString
]

{ #category : #accessing }
GtRrMqServer >> mqPort [
	^ mqProcessor mqPort
]

{ #category : #accessing }
GtRrMqServer >> mqPort: anInteger [

	mqProcessor mqPort: anInteger
]

{ #category : #private }
GtRrMqServer >> mqProcessor [

	^ [ :message | self processMqMessage: message ]
]

{ #category : #accessing }
GtRrMqServer >> mqUsername [

	^ mqProcessor mqUsername
]

{ #category : #accessing }
GtRrMqServer >> mqUsername: aString [

	mqProcessor mqUsername: aString
]

{ #category : #accessing }
GtRrMqServer >> newWorkerConnection [

	^ GtRrMqWorkerConnection new
]

{ #category : #'start - stop' }
GtRrMqServer >> purgeQueues [
	"Purge the permanent queues"

	GtRrStompMqProcessor new
		mqUsername: self mqUsername;
		mqPassword: self mqPassword;
		mqHostName: self mqHostName;
		mqPort: self mqPort;
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
	"This is just caching the value, and should not be changed from what the class method returns."

	^ runnerControlChannelName ifNil: 
		[ runnerControlChannelName := self class runnerControlChannelName ]
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

	self purgeQueues.

	mqProcessor
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
			nextPut: GtRrWorker stompMqQueueNames;
			nextPut: self stompMqQueueNamesAttribute ]
]

{ #category : #accessing }
GtRrMqServer >> stompMqQueueNames [
	"Answer the queue names as passed to the worker on the command line.
	29.05.25 temporary backward compatibility"
	
	^ self stompMqQueueNamesAttribute
]

{ #category : #accessing }
GtRrMqServer >> stompMqQueueNamesAttribute [
	"Answer the queue names as passed to the worker on the command line"
	
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
	"This is just caching the value, and should not be changed from what the class method returns."

	^ taskQueueName ifNil: 
		[ taskQueueName := self class taskQueueName ]
]

{ #category : #accessing }
GtRrMqServer >> taskResultName [
	"This is just caching the value, and should not be changed from what the class method returns."

	^ taskResultName ifNil: 
		[ taskResultName := '/queue/', NetNameResolver localHostName, '_task_result' ]
]
