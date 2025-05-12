"
GtRrWorkerConnection is the runner's representation of a worker.  The term 'proxy' isn't used as it isn't a PharoLink proxy object - it will use the worker's control channel to send messages back to the worker.
"
Class {
	#name : #GtRrWorkerConnection,
	#superclass : #Object,
	#traits : 'TGtWorkerConnectionUI',
	#classTraits : 'TGtWorkerConnectionUI classTrait',
	#instVars : [
		'connection',
		'workerPriority',
		'remoteRunner',
		'remoteAddress',
		'observer',
		'observerProcess',
		'observerSemaphore',
		'lastHeartbeat',
		'attributes'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrWorkerConnection class >> connection: aConnection runner: aGtRemoteRunner [

	^ self new 
		connection: aConnection;
		remoteRunner: aGtRemoteRunner
]

{ #category : #accessing }
GtRrWorkerConnection class >> connectionLostMessage [

	^ 'Worker connection lost'
]

{ #category : #accessing }
GtRrWorkerConnection >> addObserver: aBlock [

	"Waits until semaphore of observer is signalled to keep request alive, as observers live in the request-response life-cycle."

	self assert: [ observer isNil ].
	self assert: [ observerProcess isNil ].
	observer := aBlock.
	observerProcess := Processor activeProcess.
	observerSemaphore := Semaphore new.
	^ true
]

{ #category : #accessing }
GtRrWorkerConnection >> attributes [

	^ attributes
]

{ #category : #accessing }
GtRrWorkerConnection >> attributes: aDictionary [

	attributes := aDictionary
]

{ #category : #commands }
GtRrWorkerConnection >> commandCurrentTaskContextId [
	"Answer the taskContextId from the worker.
	Will be nil if a task hasn't started yet on the worker."

	^ self sendControlMessage: (Message selector: #commandCurrentTaskContextId)
]

{ #category : #commands }
GtRrWorkerConnection >> commandEvaluate: aString [
	| context result |

	context := GtRrWorkerContext workerConnection: self.
	self timeoutManager addContext: context.
	result := self sendControlMessage: (Message
			   selector: #commandEvaluate:
			   argument: aString).
	context isFinished: true.
	^ result.
]

{ #category : #commands }
GtRrWorkerConnection >> commandPharoLinkServer: anInteger [
	"Start a PharoLinkServer on the worker with the supplied port number"
	| response |

	response := self sendControlMessage: (Message
			   selector: #commandPharoLinkServer:
			   argument: anInteger).
	(response at: #succeeded) ifFalse:
		[ self error: (response at: #messageText) ].
]

{ #category : #commands }
GtRrWorkerConnection >> commandPing [

	"If the worker service responds, it is is there. If something fails, you get an error."

	^ self sendControlMessage: (Message selector: #commandPing)
]

{ #category : #commands }
GtRrWorkerConnection >> commandQuitSmalltalk [

	"Except the connection to close on the worker service end."

	^ self sendControlMessage: (Message selector: #commandQuitSmalltalk)
]

{ #category : #commands }
GtRrWorkerConnection >> commandTerminateTaskContextId: taskContextId [

	^ self sendControlMessage: (Message
		selector: #commandTerminateTaskContextId:
		argument: taskContextId)
]

{ #category : #accessing }
GtRrWorkerConnection >> connection [

	^ connection
]

{ #category : #accessing }
GtRrWorkerConnection >> connection: aPharoLinkServerConnection [

	connection := aPharoLinkServerConnection.
	remoteAddress := connection remoteAddress.
	connection
		when: PharoLinkServerConnectionDisconnectedAnnouncement 
		send: #onConnectionLost 
		to: self.
]

{ #category : #accessing }
GtRrWorkerConnection >> detailAt: aString ifAbsent: absentBlock [

	^ attributes at: aString ifAbsent: absentBlock
]

{ #category : #accessing }
GtRrWorkerConnection >> details [

	^ attributes
]

{ #category : #accessing }
GtRrWorkerConnection >> details: anObject [

	attributes := anObject.

]

{ #category : #ui }
GtRrWorkerConnection >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item third ];
			actionUpdateButton 
]

{ #category : #testing }
GtRrWorkerConnection >> hasObserver [

	^ observer isNotNil
]

{ #category : #initialization }
GtRrWorkerConnection >> initialize [

	super initialize.
	attributes := Dictionary new.
	lastHeartbeat := DateAndTime now.
]

{ #category : #testing }
GtRrWorkerConnection >> isConnected [

	^ connection isConnected
]

{ #category : #accessing }
GtRrWorkerConnection >> lastHeartbeat [

	^ lastHeartbeat
]

{ #category : #private }
GtRrWorkerConnection >> observerWait [
	"Wait on the observer semaphore.
	This is called by the worker to keep the observer valid."

	observerSemaphore wait.
]

{ #category : #'private - events' }
GtRrWorkerConnection >> onConnectionLost [
	"Handle the worker disconnection.
	Ignored if not a single connection"

	remoteRunner critical:
		[ ((attributes at: #workerConnectionStrategy ifAbsent: [ '' ])
			sameContentAs: GtRrWorkerSingleConnectionStrategy strategyName)
			ifFalse: [ ^ self ].
	
		self hasObserver ifTrue: [ self removeObserver ].
		self remoteRunner
			unregisterWorkerId: self workerId
			reason: 'Worker connection lost' ]
]

{ #category : #debugging }
GtRrWorkerConnection >> pharoLinkServerOnPort: anInteger [
	"Start a PharoLink server on the worker and connect"
	| settings application |

	"Start the server on the worker"
	self commandPharoLinkServer: anInteger.

	"Give the server a chance to fire up"
	1 second wait.

	"Start the client"
	settings := LanguageLinkSettings pharoDefaultSettings.
	settings
		serverProcessClass: LanguageLinkManualProcess;
		serverSocketAddress: (LanguageLinkSocketAddress
				ipOrName: (GtRemoteRunner printIpAddress: remoteAddress)
				port: anInteger).
	application := PharoLinkApplication newWith: settings.
	application start.
	^ application.
]

{ #category : #accessing }
GtRrWorkerConnection >> pid [

	^ attributes at: #pid ifAbsent: []
]

{ #category : #printing }
GtRrWorkerConnection >> printOn: aStream [

	(remoteAddress isNil and: [ (attributes includesKey: #workingDirectory) not ]) ifTrue: 
		[ ^ super printOn: aStream ].

	aStream
		<< (GtRemoteRunner printIpAddress: remoteAddress);
		<< ':';
		<< (attributes at: #workingDirectory ifAbsent: [ '' ]).
]

{ #category : #accessing }
GtRrWorkerConnection >> registerHeartbeat [

	GtRemoteRunnerTraceAnnouncement new
		message: 'Heartbeat received for: ', self workerId;
		emit.
	lastHeartbeat := DateAndTime now.
]

{ #category : #accessing }
GtRrWorkerConnection >> remoteAddress [

	^ remoteAddress
]

{ #category : #accessing }
GtRrWorkerConnection >> remoteAddressString [

	^ GtRemoteRunner printIpAddress: remoteAddress
]

{ #category : #accessing }
GtRrWorkerConnection >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrWorkerConnection >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #accessing }
GtRrWorkerConnection >> removeObserver [

	[ observerProcess ifNotNil: #terminate ]
		on: ProcessAlreadyTerminating
		do: [ :ex | "nothing" ].
	observerProcess := nil.
	observer := nil.
	^ true
]

{ #category : #private }
GtRrWorkerConnection >> sendControlMessage: aMessage [

	observer ifNil: [ self error: 'The control channel hasn''t been enabled' ].

	^ observer value: { aMessage selector. aMessage arguments. aMessage lookupClass }
]

{ #category : #'start-stop' }
GtRrWorkerConnection >> stop [

	self stopWithReason: 'Worker stopped'

]

{ #category : #'start-stop' }
GtRrWorkerConnection >> stopWithReason: aString [

	self hasObserver ifTrue: [ self removeObserver ].
	connection stop.
	self remoteRunner unregisterWorkerId: self workerId reason: aString

]

{ #category : #ui }
GtRrWorkerConnection >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream nextPut: { #Connected. self isConnected. connection. }.
		attributes ifNotNil:
			[ attributes associationsDo: [ :assoc |
				stream nextPut: { assoc key. assoc value. self. } ] ] ].
]

{ #category : #accessing }
GtRrWorkerConnection >> taskContext: ignored [
	"Ignored.  For PharoLink connections, the future holds on to the context"
]

{ #category : #private }
GtRrWorkerConnection >> timeoutManager [ 

	^ remoteRunner timeoutManager 
]

{ #category : #accessing }
GtRrWorkerConnection >> workerId [

	^ attributes at: #id
]

{ #category : #accessing }
GtRrWorkerConnection >> workerPriority [
	"Answer the priority of the worker.
	Larger number = higher priority.
	50 = default priority.
	Cache the priority in an instance variable since it is frequently accessed as part of the availableWorkers"

	^ workerPriority ifNil:
		[ workerPriority := attributes at: #workerPriority ifAbsent: [ 50 ] ].
]
