"
GtRrWorkerConnectionStrategys are responsible for maintaining the connection to the {{gtClass:GtRemoteRunner}}.

Strategies might include:

- permanently connected
- new connection per message

"
Class {
	#name : #GtRrLlWorkerConnectionStrategy,
	#superclass : #GtRrWorkerConnectionStrategy,
	#instVars : [
		'llSocketAddress'
	],
	#category : 'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrLlWorkerConnectionStrategy class >> serverSocketAddress: aString worker: aGtRrWorker [

	^ self new
		socketAddress: aString;
		worker: aGtRrWorker
]

{ #category : #naming }
GtRrLlWorkerConnectionStrategy class >> strategyName [

	^ self subclassResponsibility 
]

{ #category : #'api - running' }
GtRrLlWorkerConnectionStrategy >> connectDuring: aBlock [
	"Evaluate aBlock passing in a connected PharoLinkApplication"

	^ self subclassResponsibility 
]

{ #category : #accessing }
GtRrLlWorkerConnectionStrategy >> llSocketAddress [
	<return: #LanguageLinkSocketAddress>

	^ llSocketAddress
]

{ #category : #accessing }
GtRrLlWorkerConnectionStrategy >> llSocketAddress: anObject [

	llSocketAddress := anObject
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> newApplication [
	"Answer a new PharoLinkApplication.
	Subclasses will determine its lifetime"

	^ PharoLinkApplication newWith:
		  (PharoLinkApplication defaultSettings
			   serverProcessClass: LanguageLinkManualProcess;
			   serverSocketAddress: llSocketAddress;
			   connectionExceptionHandler: GtRrWorkerConnectionExceptionHandler new;
			   debugMode: true;
			   yourself)
]

{ #category : #'api - running' }
GtRrLlWorkerConnectionStrategy >> nextTask [
	"Send any queued results and get the next task"
	| promise result serializedTask |
	
	^ self connectDuring: [ :application |
		[ result := worker resultQueue nextOrNil ] whileNotNil:
			[ result sendThroughApplication: application ].

		GtRrWorkerWaitForTaskAnnouncement new emit.
		promise := application newCommandFactory send:
			'GtAssignedRemoteRunner nextTaskSerializedForWorkerId: ''', worker uid, ''''.
		serializedTask := promise waitForValue.
		worker lastHeartbeat: DateAndTime now.
		LeJsonV4 uniqueInstance deserialize: serializedTask readStream ].
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> registerWith: aPharoLinkApplication [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"
	| result |

	worker syncChangesWith: aPharoLinkApplication.
	GtRrWorkerRegisterStartingSignal new emit.
	result := aPharoLinkApplication newCommandFactory 
			bindingAt: #attributes put: worker attributes;
			sendAndWait: 'GtAssignedRemoteRunner registerWorkerWithDetails: attributes controlChannelAvailable: false'.
	GtRrWorkerRegisterCompletedSignal new emit.
	^ result
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> retrieveChangesFromServerWith: aPharoLinkApplication [
	<return: #GtRrImageSync>
	| encodedEntries |

	GtRrWorkerRetrieveChangesStartingSignal new
		workerId: worker uid;
		emit.
	encodedEntries := aPharoLinkApplication newCommandFactory
		setByValue;
		bindingAt: #anOmReference put: 
			(STON toString: GtRrChangesSync headReference);
		bindingAt: #workerId put: worker uid;
		<< 'LeJsonV4 uniqueInstance serialize: (GtAssignedRemoteRunner encodedChangesSyncEventsFrom: (STON fromString: anOmReference) workerId: workerId)';
		sendAndWait.
	GtRrWorkerRetrieveChangesCompletedSignal new
		workerId: worker uid;
		emit.
	
	^ LeJsonV4 uniqueInstance deserialize: encodedEntries readStream
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> sendHeartbeat [
	| start end |

	start := Time microsecondClockValue.
	GtRrWorkerHeatbeatStartingSignal new emit.
	self connectDuring: [ :application |
		worker lastHeartbeat: DateAndTime now.
		application newCommandFactory send:
			'GtAssignedRemoteRunner heartbeatForWorkerId: ''', worker uid, '''' ].
	end := Time microsecondClockValue.
	GtRrWorkerHeartbeatCompletedSignal new
		milliseconds: ((end - start) / 1000) rounded;
		emit.
]

{ #category : #accessing }
GtRrLlWorkerConnectionStrategy >> socketAddress: aString [

	self llSocketAddress: (LanguageLinkSocketAddress from: aString)
]

{ #category : #'start-stop' }
GtRrLlWorkerConnectionStrategy >> start [

	self subclassResponsibility 
]

{ #category : #'start-stop' }
GtRrLlWorkerConnectionStrategy >> stop [

	self subclassResponsibility 
]

{ #category : #naming }
GtRrLlWorkerConnectionStrategy >> strategyName [

	^ self class strategyName
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> taskDone: aTaskContext with: anObject [
	| serializedResult executionData serializedExecutionData |
	GtRrWorkerTaskCompletedSignal new
		taskId: aTaskContext taskId;
		message: 'Success: ' , anObject printString;
		emit.
	executionData := self executionDataFromTaskContext: aTaskContext.
	serializedExecutionData := [ LeJsonV4 uniqueInstance serialize: executionData ]
			on: Error
			do: [ :ex | ^ self taskFailed: aTaskContext with: ex ].
	serializedResult := [ LeJsonV4 uniqueInstance serialize: anObject ]
			on: Error
			do: [ :ex | ^ self taskFailed: aTaskContext with: ex ].
	worker postTaskProcessing.
	worker resultQueue
		nextPut: (GtRrWorkerResultEntry
				worker: worker
				task: aTaskContext
				bindings: {#taskContextId -> aTaskContext taskContextId.
						#jobId -> aTaskContext jobId.
						#taskId -> aTaskContext taskId.
						#executionData -> serializedExecutionData.
						#result -> serializedResult.
						#workerId -> worker uid.}
				command: 'GtAssignedRemoteRunner 
			taskDone: taskContextId 
			workerId: workerId
			jobId: jobId
			taskId: taskId
			executionData: (LeJsonV4 uniqueInstance deserialize: executionData readStream)
			result: (LeJsonV4 uniqueInstance deserialize: result readStream). true')
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> taskFailed: aTaskContext with: anError [
	| executionData serializedExecutionData |

	Stdio stdout lf; << 'ensured3'; lf; flush.
	GtRrWorkerTaskCompletedSignal new
		taskId: aTaskContext taskId;
		message: 'ERROR: ' , anError printString;
		emit.
	executionData := GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		errorDetails: (GtRrErrorDetails new
						errorMessage: (anError messageText ifEmpty:
							[ anError printString ]);
						trace: anError stackString);
		additionalData: aTaskContext executionData additionalData.
	serializedExecutionData := LeJsonV4 uniqueInstance serialize: executionData.
	worker  postTaskProcessing.
	worker resultQueue nextPut: (GtRrWorkerResultEntry
		worker: worker
		task: aTaskContext
		bindings: { 
			#taskContextId -> aTaskContext taskContextId.
			#executionData -> serializedExecutionData.
			#workerId -> worker uid.
			#jobId -> aTaskContext jobId.
			#taskId -> aTaskContext taskId. }
		command: 'GtAssignedRemoteRunner 
				taskFailed: taskContextId
				workerId: workerId
				jobId: jobId
				taskId: taskId
				executionData: (LeJsonV4 uniqueInstance deserialize: executionData readStream). true').
]

{ #category : #private }
GtRrLlWorkerConnectionStrategy >> unregisterWith: aPharoLinkApplication [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

	^ aPharoLinkApplication newCommandFactory sendAndWait: 
		'GtAssignedRemoteRunner unregisterWorkerId: ''', worker uid, ''' reason: ''Worker stopped'''.
]

{ #category : #accessing }
GtRrLlWorkerConnectionStrategy >> worker [
	<return: #GtRrWorker>

	^ worker
]

{ #category : #accessing }
GtRrLlWorkerConnectionStrategy >> worker: anObject [

	worker := anObject
]
