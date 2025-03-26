Class {
	#name : #GtRrMqWorkerConnectionStrategy,
	#superclass : #GtRrWorkerConnectionStrategy,
	#instVars : [
		'mqHost',
		'nextTask',
		'nextTaskSemaphore',
		'mqProcessor',
		'ackFrame'
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
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqHostName [

	^ GtRrStompMqProcessor hostNameFrom: mqHost
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> mqPortNumber [

	^ GtRrStompMqProcessor portFrom: mqHost
]

{ #category : #'api - running' }
GtRrMqWorkerConnectionStrategy >> nextTask [

	GtRrWorkerWaitForTaskAnnouncement new emit.
	nextTaskSemaphore wait.
	mqProcessor sendGtMessage: (GtRrWorkerTaskStartedMessage new
			taskContextId: nextTask taskContextId;
			taskId: nextTask taskId;
			workerId: worker uid)
		to: GtRrStompMqProcessor runnerControlChannelName.
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
		to: GtRrStompMqProcessor runnerControlChannelName 
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
		to: GtRrStompMqProcessor runnerControlChannelName 
		response: self workerControlTopicName.
	promise wait
		then: [ :aResult | events := aResult ]
		otherwise: [ :ex | self error: 'Unable to retrieve changes: ', ex messageText ].
	GtRrWorkerRetrieveChangesCompletedSignal new
		workerId: worker uid;
		emit.
	
	^ events
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> sendHeartbeat [
	| start end heartbeatMessage |

	start := Time microsecondClockValue.
	GtRrWorkerHeatbeatStartingSignal new emit.
	worker lastHeartbeat: DateAndTime now.
	heartbeatMessage := GtRrWorkerHeatbeatMessage new workerId: worker uid.
	mqProcessor sendGtMessage: heartbeatMessage to: GtRrStompMqProcessor runnerControlChannelName.
	end := Time microsecondClockValue.
	GtRrWorkerHeartbeatCompletedSignal new
		milliseconds: ((end - start) / 1000) rounded;
		emit.
]

{ #category : #'api - running' }
GtRrMqWorkerConnectionStrategy >> setNextTask: aGtRrTask ackFrame: anAckFrame [
	"Save the supplied task & ackFrame and notify the worker that the task is available.
	The ackFrame will be sent back to the MQ to notify it that the task is complete and the next one can be delivered."

	self assert: nextTask isNil.
	nextTask := aGtRrTask.
	ackFrame := anAckFrame.
	nextTaskSemaphore signal.
]

{ #category : #accessing }
GtRrMqWorkerConnectionStrategy >> socketAddress: aString [

	mqHost := aString
]

{ #category : #'start-stop' }
GtRrMqWorkerConnectionStrategy >> start [

	self assert: mqProcessor isNil.

	mqProcessor := GtRrStompMqProcessor new
		owner: self;
		mqHostName: self mqHostName;
		mqPort: self mqPortNumber;
		commandChannelName: self workerControlTopicName;
		messageChannelName: GtRrStompMqProcessor taskQueueName.
	mqProcessor start.
	worker attributes
		at: #workerIpAddress
		ifAbsentPut: [ mqProcessor localAddress ].
	worker registerWith: self.
	mqProcessor subscribeToMessagesPrefetchCount: 1.
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
	currentAckFrame := ackFrame.
	nextTask := ackFrame := nil.
	currentAckFrame ifNotNil:
		[ mqProcessor write: currentAckFrame ].
	mqProcessor sendGtMessage: taskDoneMessage to: GtRrStompMqProcessor taskResultName.
]

{ #category : #private }
GtRrMqWorkerConnectionStrategy >> taskFailed: aTaskContext with: anError [
	| taskDoneMessage executionData |

	executionData := self executionDataFromTaskContext:  aTaskContext.
	executionData errorDetails: (GtRrErrorDetails new
						errorMessage: (anError messageText ifEmpty:
							[ anError printString ]);
						trace: anError stackString).
	taskDoneMessage := GtRrWorkerTaskFailedMessage new
		taskContextId: aTaskContext taskContextId;
		workerId: worker uid;
		executionData: executionData.
	ackFrame ifNotNil:
		[ mqProcessor write: ackFrame ].
	mqProcessor sendGtMessage: taskDoneMessage to: GtRrStompMqProcessor taskResultName.
	nextTask := ackFrame := nil.
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
