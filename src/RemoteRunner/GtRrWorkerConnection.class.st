"
GtRrWorkerConnection is the runner's representation of a worker.  The term 'proxy' isn't used as it isn't a PharoLink proxy object - it will use the worker's control channel to send messages back to the worker.
"
Class {
	#name : #GtRrWorkerConnection,
	#superclass : #Object,
	#instVars : [
		'connection',
		'platform',
		'remoteAddress',
		'details',
		'observer',
		'observerProcess',
		'observerSemaphore'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrWorkerConnection class >> connection: aConnection [

	^ self new connection: aConnection
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
]

{ #category : #accessing }
GtRrWorkerConnection >> detailAt: aString ifAbsent: absentBlock [

	^ details at: aString ifAbsent: absentBlock
]

{ #category : #accessing }
GtRrWorkerConnection >> details [

	^ details
]

{ #category : #accessing }
GtRrWorkerConnection >> details: anObject [

	details := anObject.
	platform := details at: #platform.
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
	details := Dictionary new.
]

{ #category : #testing }
GtRrWorkerConnection >> isConnected [

	^ connection isConnected
]

{ #category : #private }
GtRrWorkerConnection >> observerWait [
	"Wait on the observer semaphore.
	This is called by the worker to keep the observer valid."

	observerSemaphore wait.
]

{ #category : #accessing }
GtRrWorkerConnection >> platform [

	^ platform
]

{ #category : #printing }
GtRrWorkerConnection >> printOn: aStream [

	(remoteAddress isNil and: [ (details includesKey: #workingDirectory) not ]) ifTrue: 
		[ ^ super printOn: aStream ].

	aStream
		<< (GtRemoteRunner printIpAddress: remoteAddress);
		<< ':';
		<< (details at: #workingDirectory ifAbsent: [ '' ]).
]

{ #category : #accessing }
GtRrWorkerConnection >> remoteAddress [

	^ remoteAddress
]

{ #category : #accessing }
GtRrWorkerConnection >> removeObserver [

	observerProcess ifNotNil: #terminate.
	observerProcess := nil.
	observer := nil.
	^ true
]

{ #category : #private }
GtRrWorkerConnection >> sendControlMessage: aMessage [

	^ observer value: { aMessage selector. aMessage arguments. aMessage lookupClass }
]

{ #category : #'start-stop' }
GtRrWorkerConnection >> stop [

	self hasObserver ifTrue: [ self removeObserver ].
	connection stop.

]

{ #category : #ui }
GtRrWorkerConnection >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream
			nextPut: { #Connected. self isConnected. connection. };
			nextPut: { 'Remote Address'. GtRemoteRunner printIpAddress:  remoteAddress. self. }.
		details ifNotNil:
			[ details associationsDo: [ :assoc |
				stream nextPut: { assoc key. assoc value. self. } ] ] ].
]
