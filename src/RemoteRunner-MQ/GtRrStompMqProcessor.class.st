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
		'commandChannelName',
		'messageChannelName',
		'owner',
		'rpcRegistry',
		'sharedAccess',
		'mqPort',
		'mqUsername',
		'mqPassword',
		'closingException',
		'socketAccess',
		'state',
		'listenerStopping'
	],
	#classVars : [
		'DefaultHost',
		'DefaultPassword',
		'DefaultUsername'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultHost [
	^DefaultHost
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultHost: anObject [
	DefaultHost := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultHostName [

	^ self hostNameFrom: DefaultHost
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultPassword [
	^DefaultPassword
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultPassword: anObject [
	DefaultPassword := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultPort [

	^ self portFrom: DefaultHost
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultUsername [
	^DefaultUsername
]

{ #category : #accessing }
GtRrStompMqProcessor class >> defaultUsername: anObject [
	DefaultUsername := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor class >> hostNameFrom: aHostString [
	| segments |

	aHostString ifNil: [ ^ nil ].
	segments := $: split: aHostString.
	segments size > 2 ifTrue: [ 
		self error: aHostString printString , ' must be formatted <host>[:<port>]' ].
	^ segments size = 1
		ifTrue: [ segments first ]
		ifFalse: [ nil ].
]

{ #category : #accessing }
GtRrStompMqProcessor class >> portFrom: aHostString [
	| segments |

	aHostString ifNil: [ ^ StampConstants defaultPort ].
	segments := $: split: aHostString.
	segments size > 2 ifTrue: [ 
		self error: aHostString printString , ' must be formatted <host>:[<port>]' ].
	^ segments size = 1 ifTrue: 
		[ StampConstants defaultPort ]
	ifFalse: [ | port |
		port := segments second.
		(port allSatisfy: #isDigit) ifFalse: [ 
			self error: aHostString printString , ' the port must be a number' ].
		port asInteger ]
]

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
	self mqHostName ifNotNil: [ :hn | mqClient host: hn ].
	self mqPort ifNotNil: [ :port | mqClient port: port ].
	self mqUsername ifNotNil: [ :un | mqClient login: un ].
	self mqPassword ifNotNil: [ :pwd | mqClient passcode: pwd ].
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
	socketAccess := Mutex new.
	sharedAccess := Mutex new.
	rpcRegistry := Dictionary new.
	state := #notStarted.
	listenerStopping := false.
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

{ #category : #testing }
GtRrStompMqProcessor >> isStopRequested [

	^ state = #stopRequested
]

{ #category : #testing }
GtRrStompMqProcessor >> isStopped [

	^ state = #stopped
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
	^ mqHostName ifNil: [ self class defaultHostName ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqHostName: anObject [
	mqHostName := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqPassword [
	^mqPassword ifNil: [ self class defaultPassword ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqPassword: anObject [
	mqPassword := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqPort [
	^ mqPort ifNil: [ self class defaultPort ]
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
GtRrStompMqProcessor >> mqUsername [
	^mqUsername ifNil: [ self class defaultUsername ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> mqUsername: anObject [
	mqUsername := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor >> owner [
	^ owner
]

{ #category : #accessing }
GtRrStompMqProcessor >> owner: anObject [
	owner := anObject
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> privateStop [

	self stopMqHeartbeat.
	mqClient ifNotNil: [ mqClient closeMedium ].
	mqClient := messageSubscription := commandSubscription := owner := nil.
	state := #stopped.
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
	"Connect the mqClient and read messages until the processor has been idle for 2 seconds.
	This is a hack until proper control of the server is possible."
	| listener count lastMessageTime subscription |

	self assert: mqClient isNil
		description: 'Purging is only supported while not connected'.

	self connect.

	subscription := mqClient newSubscriptionTo: queueName.
	subscription autoAck.
	mqClient writeWithReceipt: subscription subscribeFrame.

	lastMessageTime := DateAndTime now.
	count := 0.
	listener := [ mqClient runWith: [ :message |
		count := count + 1.
		lastMessageTime := DateAndTime now ] ] fork.
	[ (DateAndTime now - lastMessageTime) < 2 seconds ] whileTrue:
		[ 500 milliseconds wait ].
	self stopMqHeartbeat.
	listener terminate.
	mqClient closeMedium.
	mqClient := nil.
	^ count.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> reconnect [

	self notYetImplemented.
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
	self sendGtMessage: rpcMessage to: commandChannel.
	^ promise
]

{ #category : #actions }
GtRrStompMqProcessor >> sendGtMessage: aGtRrMessage to: destination [
	| mqMessage |

	GtRrStompMqSendMessageStartingSignal new
		gtMessagePrintString: aGtRrMessage printString;
		emit.
	mqMessage := mqClient newSendFrameTo: destination.
	mqMessage bytes: (GtWireEncoder onByteArray
		nextPut: aGtRrMessage;
		contents).
	self write: mqMessage.
	GtRrStompMqSendMessageCompletedSignal new
		gtMessagePrintString: aGtRrMessage printString;
		emit.
]

{ #category : #actions }
GtRrStompMqProcessor >> sendRpcBlockClosure: aBlockClosure to: commandDestination [

	^ self sendRpcMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: commandDestination.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> setStopRequested [

	state := #stopRequested
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> start [
	"Start the receiver.
	Message subscription must be started separately, to allow for handshaking over the command channel"

	state := #starting.
	listenerStopping := false.
	self connect.

	"Subscribe to runner command messages"
	commandSubscription := mqClient newSubscriptionTo: commandChannelName.
	commandSubscription autoAck.
	mqClient writeWithReceipt: commandSubscription subscribeFrame.

	self startMqListener.
	state := #running.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> startMqHeartbeat [

	self assert: mqHeartbeatProcess isNil.
	mqHeartbeatProcess := [ [ mqClient isConnected ] whileTrue: [
		30 seconds wait.
		mqClient isConnected ifTrue:
			[ socketAccess critical: 
				[ mqClient writeHeartbeatIfNeeded ] ] ] ] fork.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> startMqListener [

	mqListener := 
		[ "Process messages until ConnectionClosed is signalled"
		[ mqClient runWith: self mqProcessor ]
			on: ZnIncomplete, SocketError
			do: [ :ex | 
			Stdio stdout
				<< Time now asString;
				<< (' AKG Received mqListener exception: ', ex messageText asString);
				lf; flush.
			"ex logStackToFile."
			closingException := ex freeze ].
		listenerStopping := true.
		"Ask the owner to take over.
		The receiver should either be shut down or reconnected.
		Either way, this process should terminate once the processing is complete, and not continue to be used."
		owner ifNotNil: [ :anOwner |
			anOwner handleMqListenerException: closingException ].
		 ] fork.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stop [

	state := #stopRequested.
	self stopMqHeartbeat.
	listenerStopping ifFalse: [ mqListener signalException: ConnectionClosed new ].
	commandSubscription := messageSubscription := nil.
	state := #stopped.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stopMqHeartbeat [

	mqHeartbeatProcess ifNotNil:
		[ mqHeartbeatProcess terminate.
		mqHeartbeatProcess := nil ].
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stopRequested [

	state := #stopRequested.
	owner 
		ifNil: [ self stop ]
		ifNotNil: [ owner stopRequested ].
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
	self write: messageSubscription subscribeFrame.
]

{ #category : #'primitive operations' }
GtRrStompMqProcessor >> write: aStampFrame [

	socketAccess critical:
		[ mqClient write: aStampFrame ]
]
