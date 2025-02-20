Class {
	#name : #GtRrMqWorkerConnection,
	#superclass : #Object,
	#traits : 'TGtWorkerConnectionUI',
	#classTraits : 'TGtWorkerConnectionUI classTrait',
	#instVars : [
		'workerPriority',
		'remoteRunner',
		'remoteAddress',
		'observer',
		'observerProcess',
		'observerSemaphore',
		'lastHeartbeat',
		'attributes'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrMqWorkerConnection class >> connectionLostMessage [

	^ 'Worker connection lost'
]

{ #category : #accessing }
GtRrMqWorkerConnection >> attributes [

	^ attributes
]

{ #category : #accessing }
GtRrMqWorkerConnection >> attributes: aDictionary [

	attributes := aDictionary
]

{ #category : #commands }
GtRrMqWorkerConnection >> commandCurrentTaskContextId [
	| promise |
	promise := remoteRunner server sendRpcBlockClosure: [ :mqMessage :gtProcessor :owner |
		owner worker commandCurrentTaskContextId ]
			to: (GtRrStompMqProcessor workerControlTopicNameFor: self workerId).
	promise wait
		then: [ :aResult | ^ aResult ]
		otherwise: [ :ex | self error: 'Unable to retrieve current task id: ', ex messageString ].
]

{ #category : #commands }
GtRrMqWorkerConnection >> commandCurrentTaskContextIdTimeout: secondsInteger [
	| promise |
	promise := remoteRunner server sendRpcBlockClosure: [ :mqMessage :gtProcessor :owner |
		owner worker commandCurrentTaskContextId ]
			to: (GtRrStompMqProcessor workerControlTopicNameFor: self workerId).
	(promise waitTimeoutSeconds: secondsInteger)
		then: [ :aResult | ^ aResult ]
		otherwise: [ :ex | self error: 'Unable to retrieve current task id: ', ex messageString ].
]

{ #category : #commands }
GtRrMqWorkerConnection >> commandPing [
	| promise |
	promise := self sendRpcMessage: GtRrPingMessage new.
	promise wait
		then: [ :aResult | ^ aResult ]
		otherwise: [ :ex |
			self error: ex messageString ].
]

{ #category : #'as yet unclassified' }
GtRrMqWorkerConnection >> connection: aPharoLinkServerConnection [

	self assert: aPharoLinkServerConnection isNil.
]

{ #category : #ui }
GtRrMqWorkerConnection >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item last ];
			actionUpdateButton 
]

{ #category : #initialization }
GtRrMqWorkerConnection >> initialize [

	super initialize.
	attributes := Dictionary new.
	lastHeartbeat := DateAndTime now.
]

{ #category : #accessing }
GtRrMqWorkerConnection >> lastHeartbeat [

	^ lastHeartbeat
]

{ #category : #accessing }
GtRrMqWorkerConnection >> pid [

	^ attributes at: #pid ifAbsent: []
]

{ #category : #accessing }
GtRrMqWorkerConnection >> registerHeartbeat [

	GtRemoteRunnerTraceAnnouncement new
		message: 'Heartbeat received for: ', self workerId;
		emit.
	lastHeartbeat := DateAndTime now.
]

{ #category : #accessing }
GtRrMqWorkerConnection >> remoteAddress [

	^ attributes at: #workerIpAddress
]

{ #category : #accessing }
GtRrMqWorkerConnection >> remoteAddressString [

	^ GtRemoteRunner printIpAddress: self remoteAddress
]

{ #category : #accessing }
GtRrMqWorkerConnection >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrMqWorkerConnection >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #'as yet unclassified' }
GtRrMqWorkerConnection >> sendRpcMessage: aGtRrMessage [

	^ remoteRunner server sendRpcMessage: aGtRrMessage 
		to: (GtRrStompMqProcessor workerControlTopicNameFor: self workerId)
]

{ #category : #'start-stop' }
GtRrMqWorkerConnection >> stop [

	self stopWithReason: 'Worker stopped'
]

{ #category : #'start-stop' }
GtRrMqWorkerConnection >> stopWithReason: aString [

	remoteRunner server stopWorker: self workerId.
	self remoteRunner unregisterWorkerId: self workerId reason: aString
]

{ #category : #ui }
GtRrMqWorkerConnection >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream nextPut: { #LastHeartbeat. lastHeartbeat. }.
		attributes ifNotNil:
			[ attributes associationsDo: [ :assoc |
				stream nextPut: { assoc key. assoc value. self. } ] ] ].
]

{ #category : #private }
GtRrMqWorkerConnection >> timeoutManager [ 

	^ remoteRunner timeoutManager 
]

{ #category : #accessing }
GtRrMqWorkerConnection >> workerId [

	^ attributes at: #id
]

{ #category : #accessing }
GtRrMqWorkerConnection >> workerPriority [
	"Answer the priority of the worker.
	Larger number = higher priority.
	50 = default priority.
	Cache the priority in an instance variable since it is frequently accessed as part of the availableWorkers"

	^ workerPriority ifNil:
		[ workerPriority := attributes at: #workerPriority ifAbsent: [ 50 ] ].
]
