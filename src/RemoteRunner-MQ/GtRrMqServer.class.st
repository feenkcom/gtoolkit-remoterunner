Class {
	#name : #GtRrMqServer,
	#superclass : #Object,
	#instVars : [
		'remoteRunner',
		'mqHostName',
		'mqProcessor'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

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

{ #category : #accessing }
GtRrMqServer >> remoteRunner [
	^ remoteRunner
]

{ #category : #accessing }
GtRrMqServer >> remoteRunner: anObject [
	remoteRunner := anObject
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

{ #category : #'as yet unclassified' }
GtRrMqServer >> sendWorkerTaskContext: aWorkerTaskContext [
	| taskMessage |

	taskMessage := GtRrRunnerTaskMessage new
		task: aWorkerTaskContext.
	mqProcessor sendGtMessage: taskMessage to: GtRrStompMqProcessor taskQueueName.
]

{ #category : #'start - stop' }
GtRrMqServer >> start [

	self assert: mqProcessor isNil.

	mqProcessor := GtRrStompMqProcessor new
		owner: self;
		mqHostName: self mqHostName;
		"mqPort: self mqPort;"
		commandChannelName: GtRrStompMqProcessor runnerControlChannelName;
		messageChannelName: GtRrStompMqProcessor taskResultName.
	mqProcessor start.
	mqProcessor subscribeToMessages.
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
