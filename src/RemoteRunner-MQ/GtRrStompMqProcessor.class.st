Class {
	#name : #GtRrStompMqProcessor,
	#superclass : #Object,
	#instVars : [
		'mqClient',
		'mqHostName',
		'mqHeartbeatProcess',
		'mqListener',
		'messageCallback',
		'commandCallback',
		'commandSubscription',
		'messageSubscription',
		'replyRegistry',
		'commandChannelName',
		'messageChannelName',
		'owner',
		'rpcRegistry',
		'sharedAccess',
		'mqPort'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #'queue names' }
GtRrStompMqProcessor class >> runnerControlChannelName [
	"The workers (producers) send control messages (such as register or unregister) to the runner (consumer) through this channel"

	^ '/queue/runner_control'
]

{ #category : #'queue names' }
GtRrStompMqProcessor class >> taskQueueName [
	"The runner (producer) sends tasks to the workers (consumers) through this queue"

	^ '/queue/task_queue'
]

{ #category : #'queue names' }
GtRrStompMqProcessor class >> taskResultName [
	"The workers (producers) send task results to the runner (consumer) through this queue"

	^ '/queue/task_result'
]

{ #category : #accessing }
GtRrStompMqProcessor class >> workerControlTopicNameFor: workerId [

	^ '/topic/gtrrWorkerControl.', workerId
]

{ #category : #accessing }
GtRrStompMqProcessor >> commandCallback [
	^ commandCallback
]

{ #category : #accessing }
GtRrStompMqProcessor >> commandCallback: anObject [
	commandCallback := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> commandChannelName [
	^ commandChannelName
]

{ #category : #accessing }
GtRrStompMqProcessor >> commandChannelName: anObject [
	commandChannelName := anObject
]

{ #category : #private }
GtRrStompMqProcessor >> connect [

	self assert: mqClient isNil.
	
	mqClient := StampClient new.
	mqClient optionAt: #gtRrOwner put: self.
	mqClient host: self mqHostName.
	mqClient timeout: 60.
	mqClient open.
	mqClient isConnected ifFalse:
		[ self error: 'Unable to connect to MQ server' ].
	self startMqHeartbeat.
]

{ #category : #private }
GtRrStompMqProcessor >> critical: aBlock [

	^ sharedAccess critical: aBlock
]

{ #category : #initialization }
GtRrStompMqProcessor >> initialize [

	super initialize.
	sharedAccess := Mutex new.
	rpcRegistry := Dictionary new.
	commandCallback := messageCallback :=
		[ :mqMessage :gtMessage :anOwner |
			GtRrStompMqCallbackStartingSignal new
				gtMessagePrintString: gtMessage printString;
				emit.
			gtMessage processMq: mqMessage processor: self for: anOwner.
			GtRrStompMqCallbackCompletedSignal new
				gtMessagePrintString: gtMessage printString;
				emit. ].
]

{ #category : #testing }
GtRrStompMqProcessor >> isRunning [

	^ mqClient isNotNil and:
		[ mqClient isConnected and:
		[ mqListener isNotNil and: 
		[ mqListener isTerminated not ] ] ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> localAddress [

	^ mqClient medium socket localAddress
]

{ #category : #accessing }
GtRrStompMqProcessor >> messageCallback [
	^ messageCallback
]

{ #category : #accessing }
GtRrStompMqProcessor >> messageCallback: anObject [
	messageCallback := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> messageChannelName [
	^ messageChannelName
]

{ #category : #accessing }
GtRrStompMqProcessor >> messageChannelName: anObject [
	messageChannelName := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqHostName [
	^ mqHostName ifNil: [ 'localhost' ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqHostName: anObject [
	mqHostName := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqPort [
	^ mqPort ifNil: [ StampConstants defaultPort ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqPort: anInteger [

	mqPort := anInteger
]

{ #category : #private }
GtRrStompMqProcessor >> mqProcessor [

	^ [ :message | self processMqMessage: message ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> owner [
	^ owner
]

{ #category : #accessing }
GtRrStompMqProcessor >> owner: anObject [
	owner := anObject
]

{ #category : #private }
GtRrStompMqProcessor >> processMqMessage: mqMessage [ 
	| gtMessage |

	gtMessage := (GtWireDecoder on: mqMessage body readStream) next.
	mqMessage destination = commandChannelName ifTrue:
		[ ^ commandCallback value: mqMessage  value: gtMessage value: owner ].
	mqMessage destination = messageChannelName ifTrue:
		[ messageCallback value: mqMessage value: gtMessage value: owner.
		"mqClient write: mqMessage ackFrame."
		^ self ].
	self error: 'Unrecognised message destination: ', mqMessage destination asString.
]

{ #category : #accessing }
GtRrStompMqProcessor >> promiseAt: rpcId [

	^ self critical:
		[ rpcRegistry at: rpcId ]
]

{ #category : #housekeeping }
GtRrStompMqProcessor >> purgeQueue: queueName [
	"Connect the mqClient and read messages until the processor has been idle for 2 seconds."
	| client listener count lastMessageTime subscription |

	client := StampClient new.
	client host: self mqHostName.
	client timeout: 60.
	client open.
	client isConnected ifFalse:
		[ self error: 'Unable to connect to MQ server' ].

	subscription := client newSubscriptionTo: queueName.
	subscription autoAck.
	client writeWithReceipt: subscription subscribeFrame.

	lastMessageTime := DateAndTime now.
	count := 0.
	listener := [ client runWith: [ :message |
		count := count + 1.
		lastMessageTime := DateAndTime now ] ] fork.
	[ (DateAndTime now - lastMessageTime) < 2 seconds ] whileTrue:
		[ 500 milliseconds wait ].
	listener terminate.
	client closeMedium.
	^ count.
]

{ #category : #'as yet unclassified' }
GtRrStompMqProcessor >> remoteAddress [

	^ mqClient medium socket remoteAddress
]

{ #category : #'as yet unclassified' }
GtRrStompMqProcessor >> remoteAddressString [

	^ GtRemoteRunner printIpAddress: self remoteAddress
]

{ #category : #accessing }
GtRrStompMqProcessor >> removePromiseAt: rpcId [

	^ self critical:
		[ rpcRegistry removeKey: rpcId ]
]

{ #category : #actions }
GtRrStompMqProcessor >> sendBlockClosure: aBlockClosure to: commandDestination [

	self sendGtMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: commandDestination.
]

{ #category : #actions }
GtRrStompMqProcessor >> sendCommandRpcBlockClosure: aBlockClosure to: commandDestination [

	^ self sendCommandRpcMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: commandDestination
		response: commandChannelName.
]

{ #category : #actions }
GtRrStompMqProcessor >> sendCommandRpcMessage: aGtRrMessage to: commandDestination [

	^ self sendCommandRpcMessage: aGtRrMessage to: commandDestination response: commandChannelName
]

{ #category : #actions }
GtRrStompMqProcessor >> sendCommandRpcMessage: aGtRrMessage to: commandChannel response: responseDestination [
	| rpcMessage mqMessage rpcId promise |

	rpcId := UUID new.
	rpcMessage := GtRrRpcRequestMessage new
		rpcId: rpcId;
		responseQueue: responseDestination;
		evaluationMessage: aGtRrMessage.
	promise := GtRrMqPromise new
		rpcId: rpcId.
	self critical: [ rpcRegistry at: rpcId put: promise ].
	mqMessage := mqClient newSendFrameTo: commandChannel.
	mqMessage 
		bytes: (GtWireEncoder onByteArray
			nextPut: rpcMessage;
			contents).
	mqClient write: mqMessage.
	^ promise
]

{ #category : #actions }
GtRrStompMqProcessor >> sendGtMessage: aGtRrMessage to: destination [
	| mqMessage |

	mqMessage := mqClient newSendFrameTo: destination.
	mqMessage bytes: (GtWireEncoder onByteArray
		nextPut: aGtRrMessage;
		contents).
	mqClient write: mqMessage.
]

{ #category : #actions }
GtRrStompMqProcessor >> sendRpcBlockClosure: aBlockClosure to: commandDestination [

	^ self sendRpcMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: commandDestination.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> start [
	"Start the receiver.
	Message subscription must be started separately, to allow for handshaking over the command channel"

	self connect.

	"Subscribe to runner command messages"
	commandSubscription := mqClient newSubscriptionTo: commandChannelName.
	commandSubscription autoAck.
	mqClient writeWithReceipt: commandSubscription subscribeFrame.

	self startMqListener.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> startMqHeartbeat [

	self assert: mqHeartbeatProcess isNil.
	mqHeartbeatProcess := [ [ mqClient isConnected ] whileTrue: [
		30 seconds wait.
		mqClient isConnected ifTrue:
			[ mqClient writeHeartbeatIfNeeded ] ] ] fork.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> startMqListener [

	mqListener := 
		[ "Process messages until ConnectionClosed is signalled"
		mqClient runWith: self mqProcessor.
		"a quit message has been received"
		self stopRequested.
		 ] fork.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stop [

	self stopMqHeartbeat.
	mqClient ifNotNil: [ mqClient closeMedium ].
	mqListener ifNotNil: [ mqListener terminate ].
	mqClient := mqListener := messageSubscription := commandSubscription := owner := nil.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stopMqHeartbeat [

	mqHeartbeatProcess ifNotNil:
		[ mqHeartbeatProcess terminate.
		mqHeartbeatProcess := nil ].
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stopRequested [

	owner stopRequested.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> subscribeToMessages [

	self subscribeToMessagesPrefetchCount: nil
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> subscribeToMessagesPrefetchCount: prefetchCountInteger [

	messageSubscription:= mqClient newSubscriptionTo: messageChannelName.
	messageSubscription clientIndividualAck.
	prefetchCountInteger ifNotNil:
		[ messageSubscription prefetchCount: prefetchCountInteger ].
	mqClient write: messageSubscription subscribeFrame.
]

{ #category : #'primitive operations' }
GtRrStompMqProcessor >> write: aStampFrame [

	mqClient write: aStampFrame
]
