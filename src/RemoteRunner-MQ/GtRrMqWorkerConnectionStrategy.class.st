Class {
	#name : #GtRrMqWorkerConnectionStrategy,
	#superclass : #GtRrWorkerConnectionStrategy,
	#instVars : [
		'mqHost',
		'nextTask',
		'nextTaskSemaphore',
		'mqProcessor',
		'ackFrame',
		'runnerControlChannelName',
		'taskQueueName',
		'taskResultName',
		'largeMessageUrl'
	],
	#category : #'RemoteRunner-MQ-Worker'
}

{ #category : #commands }
GtRrMqWorkerConnectionStrategy >> commandCurrentTaskContextId [

	^ mqProcessor sendRpcBlockClosure: [ :mqMessage :gtProcessor :owner |
		owner worker ]
]

{ #category : #'api - running' }
GtRrMqWorkerConnectionStrategy >> connectDuring: aBlock [
	"Evaluate aBlock passing in a connected PharoLinkApplication"

	^ aBlock value: self
]

{ #category : #'as yet unclassified' }
GtRrMqWorkerConnectionStrategy >> handleMqListenerException: closingException [
	"Shut down the worker (and potentially exit the image)"

	mqProcessor ifNotNil: [ :anMqProcessor |
		anMqProcessor isStopRequested ifTrue: [ ^ self ].
		anMqProcessor setStopRequested.
		closingException class = ConnectionClosed
			ifTrue: [ self stopRequested ]
			ifFalse: [ self error: 'Unexpected loss of connection: ',
				closingException printString ] ].
]

{ #category : #'as yet unclassified' }
GtRrMqWorkerConnectionStrategy >> initialize [

	super initialize.
	nextTaskSemaphore := Semaphore new.
	mqProcessor := GtRrStompMqProcessor new
		owner: self.
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> largeMessageUrl [
	^largeMessageUrl
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> largeMessageUrl: aZnUrl [
	largeMessageUrl := aZnUrl
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqHostName [

	^ mqProcessor mqHostName
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqHostName: aString [

	mqProcessor mqHostName: aString
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqPassword [

	^ mqProcessor mqPassword
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqPassword: aString [

	mqProcessor mqPassword: aString
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqPort [

	^ mqProcessor mqPort
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqPort: anInteger [

	mqProcessor mqPort: anInteger
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqUsername [

	^ mqProcessor mqUsername
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqUsername: aString [

	mqProcessor mqUsername: aString
]

{ #category : #'api - running' }
GtRrMqWorkerConnectionStrategy >> nextTask [

	GtRrWorkerWaitForTaskAnnouncement new emit.
	nextTaskSemaphore wait.
	mqProcessor sendGtMessage: (GtRrWorkerTaskStartedMessage new
			taskContextId: nextTask taskContextId;
			taskId: nextTask taskId;
			workerId: worker uid)
		to: self taskResultStompName.
	^ nextTask.
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> registerWith: ignored [
	| registerMessage result promise |

	GtRrWorkerRegisterStartingSignal new emit.
	worker syncChangesWith: ignored.
	registerMessage := GtRrWorkerRegisterMessage new 
		attributes: worker attributes.
	promise := mqProcessor sendCommandRpcMessage: registerMessage 
		to: self runnerControlChannelStompName 
		response: self workerControlTopicName.
	promise wait
		then: [ :aResult | result := aResult ]
		otherwise: [ result := false ].
	result ifFalse: [ worker
		stop;
		logAndQuit: 'Registration Rejected' ].
	GtRrWorkerRegisterCompletedSignal new emit.
]

{ #category : #'api - running' }
GtRrMqWorkerConnectionStrategy >> rejectRedeliveredTask: task ackFrame: anAckFrame [
	"Tasks are typically redelivered because the original worker died or lost connection.
	Mark the task as failed and notify the runner so it can decide what to do based on the retry strategy."

	ackFrame := anAckFrame.
	self taskFailed: task with: (Error new messageText: 'Task redelivered').
]

{ #category : #'as yet unclassified' }
GtRrMqWorkerConnectionStrategy >> remoteAddressString [

	^ mqHost ifNil: [ mqProcessor remoteAddressString ].
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> retrieveChangesFromServerWith: myself [ 
	| events encodedChangesMessage promise |


	GtRrWorkerRetrieveChangesStartingSignal new
		workerId: worker uid;
		emit.
	encodedChangesMessage := GtRrWorkerEncodedChangesMessage new 
		workerId: worker uid;
		headReference: GtRrChangesSync headReference.
	promise := mqProcessor sendCommandRpcMessage: encodedChangesMessage 
		to: self runnerControlChannelStompName 
		response: self workerControlTopicName.
	promise wait
		then: [ :aResult | events := aResult ]
		otherwise: [ :ex | self error: 'Unable to retrieve changes: ', ex messageText ].
	GtRrWorkerRetrieveChangesCompletedSignal new
		workerId: worker uid;
		emit.
	
	^ events
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> runnerControlChannelStompName [

	^ runnerControlChannelName ifNil: 
		[ runnerControlChannelName := (':' split: (worker attributes at: GtRrWorker stompMqQueueNames)) first ]
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> sendHeartbeat [
	| start end heartbeatMessage |

	start := Time microsecondClockValue.
	GtRrWorkerHeatbeatStartingSignal new emit.
	worker lastHeartbeat: DateAndTime now.
	heartbeatMessage := GtRrWorkerHeatbeatMessage new workerId: worker uid.
	mqProcessor sendGtMessage: heartbeatMessage to: self runnerControlChannelStompName.
	end := Time microsecondClockValue.
	GtRrWorkerHeartbeatCompletedSignal new
		milliseconds: ((end - start) / 1000) rounded;
		emit.
]

{ #category : #'api - running' }
GtRrMqWorkerConnectionStrategy >> setNextTask: aGtRrTask ackFrame: anAckFrame [
	"Save the supplied task & ackFrame and notify the worker that the task is available.
	The ackFrame will be sent back to the MQ to notify it that the task is complete and the next one can be delivered."

Stdio stdout
	<< Time now asString;
	<< ': set next task start';
	lf.
	self assert: nextTask isNil.
	nextTask := aGtRrTask.
	ackFrame := anAckFrame.
	nextTaskSemaphore signal.
Stdio stdout
	<< Time now asString;
	<< ': set next task done';
	lf.
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> socketAddress: aString [

	mqHost := aString
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> start [

	mqProcessor
		commandChannelName: self workerControlTopicName;
		messageChannelName: self taskQueueStompName.
	largeMessageUrl ifNotNil: [ mqProcessor largeMessageUrl: largeMessageUrl ].
	mqProcessor start.
	worker attributes
		at: #workerIpAddress
		ifAbsentPut: [ mqProcessor localAddress ].
	worker registerWith: self.
	mqProcessor subscribeToTaskMessages.
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> stop [

	mqProcessor ifNotNil: [ mqProcessor stop ].
	mqProcessor := nil.
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> stopRequested [

	mqProcessor setStopRequested.
	worker stop.
]

{ #category : #naming }
GtRrMqWorkerConnectionStrategy >> strategyName [

	^ #mqConnectionStrategy
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> taskDone: aTaskContext with: anObject [
	| taskDoneMessage currentAckFrame |

	taskDoneMessage := GtRrWorkerTaskDoneMessage new
		taskContextId: aTaskContext taskContextId;
		workerId: worker uid;
		executionData: (self executionDataFromTaskContext:  aTaskContext);
		result: anObject.
	mqProcessor sendGtMessage: taskDoneMessage to: self taskResultStompName.
	"Ensure that nextTask and ackFrame are nil'd before writing in case the next message starts before this one finishes"
	currentAckFrame := ackFrame.
	nextTask := ackFrame := nil.
	currentAckFrame ifNotNil:
		[ mqProcessor write: currentAckFrame ].
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> taskFailed: aTaskContext with: anError [
	| taskFailedMessage executionData |

	executionData := self executionDataFromTaskContext:  aTaskContext.
	executionData errorDetails: (GtRrErrorDetails new
						errorMessage: (anError messageText ifEmpty:
							[ anError printString ]);
						trace: anError stackString).
	taskFailedMessage := GtRrWorkerTaskFailedMessage new
		taskContextId: aTaskContext taskContextId;
		workerId: worker uid;
		executionData: executionData.
	mqProcessor sendGtMessage: taskFailedMessage to: self taskResultStompName.
	ackFrame ifNotNil:
		[ mqProcessor write: ackFrame ].
	nextTask := ackFrame := nil.
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> taskQueueStompName [

	^ taskQueueName ifNil: 
		[ taskQueueName := (':' split: (worker attributes at: GtRrWorker stompMqQueueNames)) second ]
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> taskResultStompName [

	^ taskResultName ifNil: 
		[ taskResultName := (':' split: (worker attributes at: GtRrWorker stompMqQueueNames)) third ]
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> taskSubscriptionId [
	^ 'task-', worker uid
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> unregisterWith: aPharoLinkApplication [

	self notYetImplemented.
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> workerControlTopicName [

	^ GtRrStompMqProcessor workerControlTopicNameFor: worker uid.
]
