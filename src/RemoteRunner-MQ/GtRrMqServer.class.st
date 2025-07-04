Class {
	#name : #GtRrMqServer,
	#superclass : #Object,
	#instVars : [
		'remoteRunner',
		'mqHostName',
		'mqProcessor',
		'mqTaskProcessor',
		'runnerControlChannelDefinition',
		'taskResultDefinition',
		'taskQueueDefinition'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrMqServer class >> runnerControlChannelBaseName [

	^ NetNameResolver localHostName, '_runner_control'
]

{ #category : #accessing }
GtRrMqServer class >> runnerControlChannelDefinition [

	^ GtRrStompMqProcessor runnerControlChannelDefinitionFor: 
		self runnerControlChannelBaseName
]

{ #category : #accessing }
GtRrMqServer class >> runnerControlChannelStompName [

	^ self runnerControlChannelDefinition stompName
]

{ #category : #accessing }
GtRrMqServer class >> stompMqQueueNamesAttribute [
	"Answer the queue names as passed to the worker on the command line"
	
	^ String streamContents: [ :sStream |
		sStream 
			<< self runnerControlChannelStompName;
			<< ':';
			<< self taskQueueStompName;
			<< ':';
			<< self taskResultStompName ]
]

{ #category : #accessing }
GtRrMqServer class >> taskQueueBaseName [

	^ NetNameResolver localHostName, '_task_queue'
]

{ #category : #accessing }
GtRrMqServer class >> taskQueueDefinition [

	^ GtRrStompMqProcessor taskQueueDefinitionFor: 
		self taskQueueBaseName
]

{ #category : #accessing }
GtRrMqServer class >> taskQueueStompName [

	^ self taskQueueDefinition stompName
]

{ #category : #accessing }
GtRrMqServer class >> taskResultBaseName [

	^ NetNameResolver localHostName, '_task_result'
]

{ #category : #accessing }
GtRrMqServer class >> taskResultDefinition [

	^ GtRrStompMqProcessor taskResultDefinitionFor: 
		self taskResultBaseName
]

{ #category : #accessing }
GtRrMqServer class >> taskResultStompName [

	^ self taskResultDefinition stompName
]

{ #category : #'start - stop' }
GtRrMqServer >> deleteQueues [
	"Delete the permanent queues.
	This isn't as severe as it sounds - they will all be automatically created again on the next run."
	| rabbitManager |

	rabbitManager := RabbitMqHttpClient 
		host: self mqHostName
		port: 15672
		user: self mqUsername
		password: self mqPassword.
	"Queues are created the first time that STOMP accesses them, so may not exist yet.
	Ignore Not Found errors here."
	[ rabbitManager
		deleteQueue: self class taskQueueBaseName vhost: '/';
		deleteQueue: self class runnerControlChannelBaseName vhost: '/';
		deleteQueue: self class taskResultBaseName vhost: '/' ]
			on: RabbitMqClientError
			do: [ :ex | | response |
				response := ex client response.
				(response code = 404 and: [ response statusLine reason = 'Not Found' ]) ifTrue:
					[ ex resume ]
				ifFalse:
					[ ex pass ] ].
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> gtResultQueueSummaryFor: aView [
	<gtView>
	^ aView forward
		title: 'Result Queue';
		priority: 10;
		object: [ self mqMonitor ];
		view: #gtResultQueueSummaryFor:
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> gtRrStopOnWorker [

	self stop.
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> gtRunnerControlSummaryFor: aView [
	<gtView>
	^ aView forward
		title: 'Runner Control';
		priority: 10;
		object: [ self mqMonitor ];
		view: #gtRunnerControlSummaryFor:
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> gtTaskQueueSummaryFor: aView [
	<gtView>
	^ aView forward
		title: 'Task Queue';
		priority: 10;
		object: [ self mqMonitor ];
		view: #gtTaskQueueSummaryFor:
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
	mqTaskProcessor := GtRrMqTaskProcessor new
		gtRrMqServer: self;
		gtRrMqProcessor: mqProcessor.
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

{ #category : #'as yet unclassified' }
GtRrMqServer >> mqMonitor [

	^ GtRrRabbitMqMonitor new
		mqServer: self
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
	| rabbitManager |

	rabbitManager := RabbitMqHttpClient 
		host: self mqHostName
		port: 15672
		user: self mqUsername
		password: self mqPassword.
	"Queues are created the first time that STOMP accesses them, so may not exist yet.
	Ignore Not Found errors here."
	[ rabbitManager
		purgeQueue: self class taskQueueBaseName vhost: '/';
		purgeQueue: self class runnerControlChannelBaseName vhost: '/';
		purgeQueue: self class taskResultBaseName vhost: '/' ]
			on: RabbitMqClientError
			do: [ :ex | | response |
				response := ex client response.
				(response code = 404 and: [ response statusLine reason = 'Not Found' ]) ifTrue:
					[ ex resume ]
				ifFalse:
					[ ex pass ] ].
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
GtRrMqServer >> runnerControlChannelDefinition [
	"This is just caching the value, and should not be changed from what the class method returns."

	^ runnerControlChannelDefinition ifNil: 
		[ runnerControlChannelDefinition := self class runnerControlChannelDefinition ]
]

{ #category : #'as yet unclassified' }
GtRrMqServer >> sendBlockClosure: aBlockClosure to: aGtRrMqQueueDefinition [

	mqProcessor sendGtMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: aGtRrMqQueueDefinition.
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
	mqProcessor sendGtMessage: taskMessage to: self taskQueueDefinition.
	GtRrMqQueueTaskCompletedSignal new
		taskId: aWorkerTaskContext taskId;
		emit.
]

{ #category : #private }
GtRrMqServer >> sendWorkerTaskContextFirst: aWorkerTaskContext [
	| taskMessage |

	GtRrMqQueueTaskStartingSignal new
		taskId: aWorkerTaskContext taskId;
		emit.
	taskMessage := GtRrRunnerTaskMessage new
		task: aWorkerTaskContext.
	mqProcessor 
		sendGtMessage: taskMessage 
		to: self taskQueueDefinition
		headers: { 'priority' -> '2' } asDictionary.
	GtRrMqQueueTaskCompletedSignal new
		taskId: aWorkerTaskContext taskId;
		emit.
]

{ #category : #'start - stop' }
GtRrMqServer >> start [
	"Connect to the MessageQueue and start listening for messages"

	self purgeQueues.
	"Temporary work-around...
	Queue max priority can't be changed, so ensure the old queue isn't in the way."
	self deleteQueues.

	mqProcessor
		commandChannelDefinition: self runnerControlChannelDefinition;
		messageChannelDefinition: self taskResultDefinition.
	mqProcessor start.
	mqProcessor subscribeToTaskMessages.
]

{ #category : #accessing }
GtRrMqServer >> stompMqAdditonalOptionsFor: aGtRrJobContext [
	"Answer the addtional command line options for workers using RabbitMQ"
	| mqLargeMessageUrl |

	mqLargeMessageUrl := aGtRrJobContext job propertyAt: 'mqLargeMessageDirectory'
		ifPresent: [ :aUrl | aUrl ]
		ifAbsent: [ (FileLocator imageDirectory resolve / 'MQ') asZnUrl ].
	mqLargeMessageUrl asFileReference ensureCreateDirectory.
	^ Array streamContents: [ :aStream |
		aStream
			nextPut: '--connectionStrategy';
			nextPut: 'stompMq';
			nextPut: '--attribute';
			nextPut: GtRrWorker stompMqQueueNames;
			nextPut: self stompMqQueueNamesAttribute;
			nextPut: '--attribute';
			nextPut: 'mqLargeMessageUrl';
			nextPut: mqLargeMessageUrl asString ]
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
			<< self runnerControlChannelDefinition stompName;
			<< ':';
			<< self taskQueueDefinition stompName;
			<< ':';
			<< self taskResultDefinition stompName ]
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
		to: (GtRrStompMqProcessor workerControlDefinitionFor: workerId).
]

{ #category : #accessing }
GtRrMqServer >> taskQueueDefinition [
	"This is just caching the value, and should not be changed from what the class method returns."

	^ taskQueueDefinition ifNil: 
		[ taskQueueDefinition := self class taskQueueDefinition ]
]

{ #category : #accessing }
GtRrMqServer >> taskResultDefinition [
	"This is just caching the value, and should not be changed from what the class method returns."

	^ taskResultDefinition ifNil: 
		[ taskResultDefinition := self class taskResultDefinition ]
]
