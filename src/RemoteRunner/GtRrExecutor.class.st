"
GtRrWorkerConnection is the runner's representation of a worker.  The term 'proxy' isn't used as it isn't a PharoLink proxy object - it will use the worker's control channel to send messages back to the worker.
"
Class {
	#name : #GtRrExecutor,
	#superclass : #TKTAbstractExecutor,
	#instVars : [
		'connection',
		'observer',
		'observerProcess',
		'observerSemaphore',
		'attributes',
		'currentTaskExecution',
		'timeoutQueue'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrExecutor class >> connection: aConnection attributes: aDictionary observer: aBlock timeoutQueue: aTimeoutQueue [

	^ self new
		  initializeConnection: aConnection
		  attributes: aDictionary
		  observer: aBlock
		  timeoutQueue: aTimeoutQueue;
		  yourself
]

{ #category : #accessing }
GtRrExecutor >> attributes [

	^ attributes
]

{ #category : #commands }
GtRrExecutor >> commandApplyCodeChanges: aFuelStringOfCollection [

	^ self sendControlMessage: (Message
			   selector: #commandApplyCodeChanges:
			   argument: aFuelStringOfCollection)
]

{ #category : #commands }
GtRrExecutor >> commandConnected [

	^ self sendControlMessage: (Message selector: #commandConnected)
]

{ #category : #commands }
GtRrExecutor >> commandPing [

	"If the worker service responds, it is is there. If something fails, you get an error."

	^ self sendControlMessage: (Message selector: #commandPing)
]

{ #category : #commands }
GtRrExecutor >> commandQuitSmalltalk [

	"Except the connection to close on the worker service end."

	^ self sendControlMessage: (Message selector: #commandQuitSmalltalk)
]

{ #category : #commands }
GtRrExecutor >> commandTerminateTaskId: aTaskId [

	^ self sendControlMessage:
		  (Message selector: #commandTerminateTaskId: argument: aTaskId)
]

{ #category : #accessing }
GtRrExecutor >> currentTask [

	^ currentTaskExecution task
]

{ #category : #accessing }
GtRrExecutor >> currentTaskExecution [

	^ currentTaskExecution
]

{ #category : #ui }
GtRrExecutor >> gtSummaryFor: aView [
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

{ #category : #initialization }
GtRrExecutor >> initializeConnection: aConnection attributes: aDictionary observer: aBlock timeoutQueue: aTimeoutQueue [

	connection := aConnection.
	attributes := aDictionary.
	observer := aBlock.
	timeoutQueue := aTimeoutQueue.
	observerSemaphore := Semaphore new
]

{ #category : #testing }
GtRrExecutor >> isConnected [

	^ connection isConnected
]

{ #category : #printing }
GtRrExecutor >> printOn: aStream [

	(self remoteAddress isNil and: [ 
		 (attributes includesKey: #workingDirectory) not ]) ifTrue: [ 
		^ super printOn: aStream ].

	aStream
		<< (GtRrScheduler printIpAddress: self remoteAddress);
		<< ':';
		<< (attributes at: #workingDirectory ifAbsent: [ '' ])
]

{ #category : #accessing }
GtRrExecutor >> remoteAddress [

	^ connection remoteAddress
]

{ #category : #schedulling }
GtRrExecutor >> schedule: aTask [

	"needed for future callbacks, runner should use #scheduleTaskExecution:"

	[ aTask value ]
		on: Error
		do: [ :error | self exceptionHandler handleException: error ]
]

{ #category : #schedulling }
GtRrExecutor >> scheduleTaskExecution: aTaskExecution [

	self assert: [ busy not ].
	self assert: [ currentTaskExecution isNil ].
	self noteBusy.
	currentTaskExecution := aTaskExecution
		                        runner: self;
		                        schedule;
		                        yourself
]

{ #category : #schedulling }
GtRrExecutor >> scheduleTimeout: aTimeout on: aTaskExecution [

	"release the task execution, check later"

	| weak |
	weak := aTaskExecution asWeakReference.
	timeoutQueue
		schedule: [ 
			weak first ifNotNil: [ :taskExecution | 
				taskExecution isFinished ifFalse: [ 
					self isConnected
						ifTrue: [ 
							(self commandTerminateTaskId: taskExecution task id) ifFalse: [ 
								self flag: 'TODO should not happen' ] ]
						ifFalse: [ 
							taskExecution terminateWithReason:
								'Timeout after: ' , aTimeout asString ] ] ] ]
		at: DateAndTime now + aTimeout
]

{ #category : #private }
GtRrExecutor >> sendControlMessage: aMessage [

	^ observer value: { aMessage selector. aMessage arguments. aMessage lookupClass }
]

{ #category : #'start-stop' }
GtRrExecutor >> stop [

	currentTaskExecution ifNotNil: #stop.
	currentTaskExecution := nil.
	observerSemaphore ifNotNil: #signalAll.
	observerSemaphore := nil.
	observerProcess ifNotNil: #terminate.
	observerProcess := nil.
	observer := nil.
	connection stop.
	self noteFree
]

{ #category : #ui }
GtRrExecutor >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		stream
			nextPut: { #Connected. self isConnected. connection. };
			nextPut: { 'Remote Address'. GtRrScheduler printIpAddress:  self remoteAddress. self. }.
		attributes ifNotNil:
			[ attributes associationsDo: [ :assoc |
				stream nextPut: { assoc key. assoc value. self. } ] ] ].
]

{ #category : #running }
GtRrExecutor >> task: aTaskId failure: aGtRrError [

	self assert: [ busy ].
	self assert: [ currentTaskExecution task id = aTaskId ].
	currentTaskExecution finishWithFailure: aGtRrError.
	currentTaskExecution := nil.
	self noteFree
]

{ #category : #running }
GtRrExecutor >> task: aTaskId success: anObject [

	self assert: [ busy ].
	self assert: [ currentTaskExecution task id = aTaskId ].
	currentTaskExecution finishWithSuccess: anObject.
	currentTaskExecution := nil.
	self noteFree
]

{ #category : #private }
GtRrExecutor >> waitOnObserver [

	"Wait on the observer semaphore.
	This is called by the worker to keep the observer valid."

	self assert: [ observerProcess isNil ].
	observerProcess := Processor activeProcess.
	observerSemaphore wait
]
