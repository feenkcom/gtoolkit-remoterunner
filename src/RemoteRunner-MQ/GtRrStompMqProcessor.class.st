Class {
	#name : #GtRrStompMqProcessor,
	#superclass : #Object,
	#instVars : [
		'mqClient',
		'mqHostName',
		'mqHeartbeatProcess',
		'mqListener',
		'commandSubscription',
		'messageSubscription',
		'owner',
		'rpcRegistry',
		'sharedAccess',
		'mqPort',
		'mqUsername',
		'mqPassword',
		'closingException',
		'socketAccess',
		'state',
		'listenerStopping',
		'callbackProcess',
		'taskCallback',
		'commandCallback',
		'largeMessageUrl',
		'commandChannelDefinition',
		'messageChannelDefinition'
	],
	#classVars : [
		'DefaultHost',
		'DefaultPassword',
		'DefaultUsername',
		'MaxMessageSize',
		'MessageTtl',
		'QueueTtl'
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
	^ segments first.
]

{ #category : #accessing }
GtRrStompMqProcessor class >> maxMessageSize [
	^MaxMessageSize ifNil: [ StampConstants maxBodySize]
]

{ #category : #accessing }
GtRrStompMqProcessor class >> maxMessageSize: anObject [
	MaxMessageSize := anObject
]

{ #category : #accessing }
GtRrStompMqProcessor class >> messageTtl [
	"Answer the time (ms) that messages can live on the MQ server"

	^ MessageTtl ifNil: [ 3 * 60 * 60 * 1000 ]
]

{ #category : #accessing }
GtRrStompMqProcessor class >> messageTtl: anIntegerMs [

	MessageTtl := anIntegerMs
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

{ #category : #accessing }
GtRrStompMqProcessor class >> queueTtl [
	"Answer the time (ms) that messages can live on the MQ server"

	^ QueueTtl ifNil: [ 12 * 60 * 60 * 1000 ]
]

{ #category : #accessing }
GtRrStompMqProcessor class >> queueTtl: anIntegerMs [

	QueueTtl := anIntegerMs
]

{ #category : #accessing }
GtRrStompMqProcessor class >> runnerControlChannelDefinitionFor: basename [

	^ GtRrMqQueueDefinition new
		basename: basename;
		stompName: '/queue/', basename;
		headerAt: 'x-message-ttl' put: self messageTtl asString;
		headerAt: 'x-expires' put: self queueTtl asString;
		prefetchCount: 200.
]

{ #category : #accessing }
GtRrStompMqProcessor class >> taskQueueDefinitionFor: basename [
	^(GtRrMqQueueDefinition new)
		basename: basename;
		stompName: '/queue/' , basename;
		headerAt: 'x-max-priority' put: '2';
		headerAt: 'x-message-ttl' put: self messageTtl asString;
		headerAt: 'x-expires' put: self queueTtl asString;
		prefetchCount: 1
]

{ #category : #accessing }
GtRrStompMqProcessor class >> taskResultDefinitionFor: basename [

	^ GtRrMqQueueDefinition new
		basename: basename;
		stompName: '/queue/', basename;
		headerAt: 'x-message-ttl' put: self messageTtl asString;
		headerAt: 'x-expires' put: self queueTtl asString;
		prefetchCount: 200.
]

{ #category : #accessing }
GtRrStompMqProcessor class >> workerControlDefinitionFor: workerId [
	"Workers use a transient topic for control channels.
	The topic is automatically deleted after the worker disconnects."

	^ GtRrMqQueueDefinition new
		basename: 'gtrrWorkerControl.', workerId;
		stompName: (self workerControlTopicNameFor: workerId);
		prefetchCount: 100.
]

{ #category : #accessing }
GtRrStompMqProcessor class >> workerControlTopicNameFor: workerId [
	"Workers use a transient topic for control channels.
	The topic is automatically deleted after the worker disconnects."

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
GtRrStompMqProcessor >> commandChannelDefinition [
	^ commandChannelDefinition
]

{ #category : #accessing }
GtRrStompMqProcessor >> commandChannelDefinition: anObject [
	commandChannelDefinition := anObject
]

{ #category : #private }
GtRrStompMqProcessor >> connect [
	"Connect to the Stomp MQ"
	| retryCount maxRetries |
	self assert: mqClient isNil.

	"This signal should be more generic"
	LlEsConnectStartingSignal new emit.

	maxRetries := 2.
	retryCount := 0.

	[ mqClient := StampClient new.
	mqClient optionAt: #gtRrOwner put: self.
	self mqHostName ifNotNil: [ :hn | mqClient host: hn ].
	self mqPort ifNotNil: [ :port | mqClient port: port ].
	self mqUsername ifNotNil: [ :un | mqClient login: un ].
	self mqPassword ifNotNil: [ :pwd | mqClient passcode: pwd ].
	mqClient open.
	"Set the timeout to a quarter of the heartbeat.
	The timeout is in seconds, while the heartbeat is milliSeconds."
	mqClient timeout: (mqClient heartbeat / 4000) rounded. ]
		on: ConnectionTimedOut, ConnectionClosed
		do: [ :ex |
			retryCount := retryCount + 1.
			retryCount <= maxRetries
				ifTrue: [ 5 seconds wait.  ex retry ]
				ifFalse: [ ex pass ] ].
	mqClient isConnected ifFalse:
		[ self error: 'Unable to connect to MQ server' ].
	self startMqHeartbeat.
	LlEsConnectCompletedSignal new
		isConnected: mqClient isConnected;
		emit.
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
	"Define callbacks as Blocks so they can be modified for testing"
	taskCallback := [ :mqMessage :gtMessage :anOwner |
		self processTaskMqMessage: mqMessage gtMessage: gtMessage owner: anOwner ].
	commandCallback := [ :mqMessage :gtMessage :anOwner |
		self processCommandMqMessage: mqMessage gtMessage: gtMessage owner: anOwner ].
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

{ #category : #testing }
GtRrStompMqProcessor >> isStopping [

	^ self isStopped or: [ self isStopRequested ]
]

{ #category : #accessing }
GtRrStompMqProcessor >> largeMessageUrl [
	^ largeMessageUrl
]

{ #category : #accessing }
GtRrStompMqProcessor >> largeMessageUrl: aZnUrl [

	largeMessageUrl := aZnUrl asZnUrl
]

{ #category : #accessing }
GtRrStompMqProcessor >> localAddress [

	^ mqClient medium socket localAddress
]

{ #category : #accessing }
GtRrStompMqProcessor >> messageChannelDefinition [
	^ messageChannelDefinition
]

{ #category : #accessing }
GtRrStompMqProcessor >> messageChannelDefinition: anObject [
	messageChannelDefinition := anObject
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

{ #category : #'as yet unclassified' }
GtRrStompMqProcessor >> processCommandMqMessage: mqMessage gtMessage: gtMessage owner: anOwner [

	GtRrStompMqTaskCallbackStartingSignal new
		gtMessagePrintString: gtMessage printString;
		emit.
	"Save the process that runs the callback for debugging"
	callbackProcess := [ [ gtMessage processMq: mqMessage processor: self for: anOwner ]
		ensure: [ self write: mqMessage ackFrame ] ]
			forkNamed: 'GtRrMq Command Message Process'.
	GtRrStompMqTaskCallbackCompletedSignal new
		gtMessagePrintString: gtMessage printString;
		emit.
]

{ #category : #private }
GtRrStompMqProcessor >> processMqMessage: mqMessage [ 
	| gtMessage |

	gtMessage := (GtWireDecoder on: mqMessage body readStream) next.
	GtRrMessageStatsSignal new
		messageClassName: gtMessage class name;
		encodedSize: mqMessage body size;
		emit.
	mqMessage destination = commandChannelDefinition stompName ifTrue:
		[ ^ commandCallback value: mqMessage  value: gtMessage value: owner ].
	mqMessage destination = messageChannelDefinition stompName ifTrue:
		[ ^ taskCallback value: mqMessage value: gtMessage value: owner ].
	self error: 'Unrecognised message destination: ', mqMessage destination asString.
]

{ #category : #'as yet unclassified' }
GtRrStompMqProcessor >> processTaskMqMessage: mqMessage gtMessage: gtMessage owner: anOwner [

	GtRrStompMqTaskCallbackStartingSignal new
		gtMessagePrintString: gtMessage printString;
		emit.
	gtMessage processMq: mqMessage processor: self for: anOwner.
	GtRrStompMqTaskCallbackCompletedSignal new
		gtMessagePrintString: gtMessage printString;
		emit.
]

{ #category : #accessing }
GtRrStompMqProcessor >> promiseAt: rpcId [

	^ self critical:
		[ rpcRegistry at: rpcId ]
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
GtRrStompMqProcessor >> sendBlockClosure: aBlockClosure to: aGtRrMqQueueDefinition [

	self sendGtMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: aGtRrMqQueueDefinition.
]

{ #category : #actions }
GtRrStompMqProcessor >> sendCommandRpcBlockClosure: aBlockClosure to: commandDestination [

	^ self sendCommandRpcMessage: (GtRrBlockClosureMessage new
			blockClosure: aBlockClosure)
		to: commandDestination
		response: commandChannelDefinition stompName.
]

{ #category : #actions }
GtRrStompMqProcessor >> sendCommandRpcMessage: aGtRrMessage to: commandDestination [

	^ self sendCommandRpcMessage: aGtRrMessage to: commandDestination response: commandChannelDefinition
]

{ #category : #actions }
GtRrStompMqProcessor >> sendCommandRpcMessage: aGtRrMessage to: commandGtRrMqQueueDefinition response: responseGtRrMqQueueDefinition [
	| rpcMessage rpcId promise |

	rpcId := UUID new.
	rpcMessage := GtRrRpcRequestMessage new
		rpcId: rpcId;
		responseQueue: responseGtRrMqQueueDefinition;
		evaluationMessage: aGtRrMessage.
	promise := GtRrMqPromise new
		rpcId: rpcId.
	self critical: [ rpcRegistry at: rpcId put: promise ].
	self sendGtMessage: rpcMessage to: commandGtRrMqQueueDefinition.
	^ promise
]

{ #category : #actions }
GtRrStompMqProcessor >> sendGtMessage: aGtRrMessage to: aGtRrMqQueueDefinition [

	self sendGtMessage: aGtRrMessage to: aGtRrMqQueueDefinition headers: nil
]

{ #category : #actions }
GtRrStompMqProcessor >> sendGtMessage: aGtRrMessage to: aGtRrMqQueueDefinition headers: aDictionary [
	| mqMessage |

	GtRrStompMqSendMessageStartingSignal new
		gtMessagePrintString: aGtRrMessage printString;
		emit.
	mqMessage := mqClient newSendFrameTo: aGtRrMqQueueDefinition stompName.
	mqMessage bytes: (self serializedGtMessage: aGtRrMessage).
	aGtRrMqQueueDefinition setHeadersIn: mqMessage.
	self setHeaders: aDictionary in: mqMessage.
	GtRrMessageStatsSignal new
		messageClassName: aGtRrMessage class name;
		encodedSize: mqMessage body size;
		emit.
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

{ #category : #private }
GtRrStompMqProcessor >> serializedGtMessage: aGtRrMessage [
	"Answer the serialised message.
	If the buffer is >= MaxMessageSize, send the message via the specified store Url."
	| messageBuffer urlMessage |

	messageBuffer := GtWireEncoder onByteArray
		nextPut: aGtRrMessage;
		contents.
	messageBuffer size < self class maxMessageSize ifTrue: [ ^ messageBuffer ].

	largeMessageUrl ifNil: [ self error: 'MQ large message store not configured' ].

	urlMessage := self storeLargeMessage: messageBuffer.
	^ GtWireEncoder onByteArray
		nextPut: urlMessage;
		contents.
]

{ #category : #private }
GtRrStompMqProcessor >> setHeaders: aDictionary in: mqMessage [

	aDictionary ifNil: [ ^ self ].
	aDictionary keysAndValuesDo: [ :key :value |
		mqMessage headerAt: key put: value ].
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> setStopRequested [

	state := #stopRequested
]

{ #category : #accessing }
GtRrStompMqProcessor >> socketStatus [

	mqClient ifNotNil: [ :theMqClient | theMqClient medium ifNotNil: [ :theMedium |
		^ theMedium socket statusString ] ].
	^ 'Connection already closed'
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> start [
	"Start the receiver.
	Task message subscription must be started separately, to allow for handshaking over the command channel"

	"Subscribe to runner command messages"
	state := #starting.
	listenerStopping := false.
	self connect.
	self subscribeToCommandMessages.
	self startMqListener.
	state := #running
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> startMqHeartbeat [

	self assert: mqHeartbeatProcess isNil.
	mqHeartbeatProcess := [ [ mqClient isConnected ] whileTrue: [
		mqClient timeout seconds wait.
		mqClient isConnected ifTrue:
			[ socketAccess critical: 
				[ [ mqClient writeHeartbeatIfNeeded ]
					on: Error
					do: [ :ex |
						self isRunning ifTrue: [ ex pass ] ] ] ] ] ] 
		forkAt: Processor lowIOPriority
			named: self class name asString, ' MQ heartbeat'.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> startMqListener [

	mqListener := 
		[ "Process messages until ConnectionClosed is signalled"
		[ mqClient runWith: self mqProcessor ]
			on: ZnIncomplete, SocketError
			do: [ :ex | 
				closingException := ex freeze.
				StampHeartbeatSignal new
					lastReadActivity: mqClient lastReadActivity;
					lastWriteActivity: mqClient lastWriteActivity;
					exception: closingException;
					emit. ].
		listenerStopping := true.
		"Ask the owner to take over.
		The receiver should either be shut down or reconnected.
		Either way, this process should terminate once the processing is complete, and not continue to be used."
		owner ifNotNil: [ :anOwner |
			anOwner handleMqListenerException: closingException ].
		 ] forkNamed: 'GtRrMq message listener'.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> stop [

	state := #stopRequested.
	socketAccess critical:
		[ self stopMqHeartbeat.
		(listenerStopping or: [ mqListener isNil ]) ifFalse: 
			[ mqListener signalException: ConnectionClosed new ].
		commandSubscription := messageSubscription := nil.
		state := #stopped ].
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

{ #category : #private }
GtRrStompMqProcessor >> storeLargeMessage: messageBuffer [

	^ GtRrUrlMessage storeBuffer: messageBuffer in: largeMessageUrl.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> subscribeToCommandMessages [

	commandSubscription := mqClient newSubscriptionTo: commandChannelDefinition stompName.
	commandSubscription clientIndividualAck.
	commandSubscription prefetchCount: commandChannelDefinition prefetchCount.
	commandChannelDefinition setHeadersIn: commandSubscription subscribeFrame.
	mqClient writeWithReceipt: commandSubscription subscribeFrame.
]

{ #category : #'start - stop' }
GtRrStompMqProcessor >> subscribeToTaskMessages [
	"Subscribe to task messages.
	This is left to the client application to allow for handshaking over the command channel."

	messageSubscription:= mqClient newSubscriptionTo: messageChannelDefinition stompName.
	messageSubscription clientIndividualAck.
	messageSubscription prefetchCount: messageChannelDefinition prefetchCount.
	messageChannelDefinition setHeadersIn: messageSubscription subscribeFrame.
	self write: messageSubscription subscribeFrame.
]

{ #category : #accessing }
GtRrStompMqProcessor >> taskCallback [
	^ taskCallback
]

{ #category : #accessing }
GtRrStompMqProcessor >> taskCallback: anObject [
	taskCallback := anObject
]

{ #category : #'primitive operations' }
GtRrStompMqProcessor >> write: aStampFrame [

	socketAccess critical:
		[ mqClient write: aStampFrame ]
]
