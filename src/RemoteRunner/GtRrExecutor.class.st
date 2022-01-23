"
GtRrWorkerConnection is the runner's representation of a worker.  The term 'proxy' isn't used as it isn't a PharoLink proxy object - it will use the worker's control channel to send messages back to the worker.
"
Class {
	#name : #GtRrExecutor,
	#superclass : #TKTAbstractExecutor,
	#instVars : [
		'announcer',
		'connection',
		'timeoutQueue',
		'attributes',
		'observer',
		'observerProcess',
		'currentTaskExecution'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrExecutor class >> connection: aConnection attributes: aDictionary observer: aBlock timeoutQueue: aQueue announcerScheduler: aScheduler [

	^ self new
		  initializeConnection: aConnection
		  attributes: aDictionary
		  observer: aBlock
		  timeoutQueue: aQueue
		  announcerScheduler: aScheduler;
		  yourself
]

{ #category : #accessing }
GtRrExecutor >> announcer [

	^ announcer
]

{ #category : #accessing }
GtRrExecutor >> asBusyElement [

	^ BrButton new
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  icon: self asBusyIcon;
		  label: self asBusyText;
		  in: [ :e | 
			  announcer
				  when: GtRrTaskAnnouncement , GtRrWorkerAnnouncement
				  send: #requestUpdate
				  to: (BrElementUpdater new
						   element: e;
						   action: [ 
							   e
								   icon: self asBusyIcon;
								   label: self asBusyText ];
						   yourself) ];
		  yourself
]

{ #category : #converting }
GtRrExecutor >> asBusyIcon [

	^ busy
		  ifTrue: [ BrGlamorousIcons yellowcircle ]
		  ifFalse: [ BrGlamorousIcons graycircle ]
]

{ #category : #converting }
GtRrExecutor >> asBusyText [

	^ busy
		  ifTrue: [ 'busy' ]
		  ifFalse: [ 'idle' ]
]

{ #category : #converting }
GtRrExecutor >> asConnectedElement [

	^ BrButton new
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  icon: self asConnectedIcon;
		  label: self asConnectedText;
		  in: [ :e | 
			  announcer
				  when: GtRrWorkerAnnouncement
				  send: #requestUpdate
				  to: (BrElementUpdater new
						   element: e;
						   action: [ 
							   e
								   icon: self asConnectedIcon;
								   label: self asConnectedText ];
						   yourself) ];
		  yourself
]

{ #category : #converting }
GtRrExecutor >> asConnectedIcon [

	^ self isConnected 
		  ifTrue: [ BrGlamorousIcons greencircle ]
		  ifFalse: [ BrGlamorousIcons redcircle ]
]

{ #category : #converting }
GtRrExecutor >> asConnectedText [

	^ self isConnected
		  ifTrue: [ 'connected' ]
		  ifFalse: [ 'disconnected' ]
]

{ #category : #converting }
GtRrExecutor >> asCurrentTaskElement [

	^ BlElement new
		  layout: BlLinearLayout horizontal;
		  constraintsDo: [ :c | 
			  c horizontal fitContent.
			  c vertical fitContent ];
		  in: [ :e | 
			  currentTaskExecution ifNotNil: [ :t | e addChild: t asElement ].
			  announcer
				  when: GtRrTaskAnnouncement , GtRrWorkerAnnouncement
				  send: #requestUpdate
				  to: (BrElementUpdater new
						   element: e;
						   action: [ 
							   e removeChildren.
							   currentTaskExecution ifNotNil: [ :t | 
									   e addChild: t asElement ] ];
						   yourself) ];
		  yourself
]

{ #category : #accessing }
GtRrExecutor >> asElement [

	^ BlElement new
		  layout: BlLinearLayout horizontal;
		  constraintsDo: [ :c | 
			  c horizontal fitContent.
			  c vertical fitContent ];
		  when: BlClickEvent do: [ :e | e target phlow spawnObject: self ];
		  addChild: self asConnectedElement as: #connected;
		  addChild: self asBusyElement as: #busy;
		  addChild: self asCurrentTaskElement as: #currentTask;
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

{ #category : #connecting }
GtRrExecutor >> connect [

	"keeps the request alive by waiting on semaphore, just kill the process on disconnect."

	self assert: [ observerProcess isNil ].
	connection
		when: PharoLinkServerConnectionDisconnectedAnnouncement
		send: #disconnect:
		to: self.
	self commandConnected.
	announcer announce: (GtRrWorkerConnectedAnnouncement executor: self).
	observerProcess := Processor activeProcess.
	Semaphore new wait
]

{ #category : #accessing }
GtRrExecutor >> connection [

	^ connection
]

{ #category : #accessing }
GtRrExecutor >> currentTask [

	^ currentTaskExecution task
]

{ #category : #accessing }
GtRrExecutor >> currentTaskExecution [

	^ currentTaskExecution
]

{ #category : #'start-stop' }
GtRrExecutor >> disconnect: anPharoLinkAnnouncement [

	currentTaskExecution ifNotNil: [ 
		currentTaskExecution finishWithFailure: 'disconnected' gtRrAsError ].
	currentTaskExecution := nil.
	"the connection is dead, there is nothing we can do but cutting ties with our collaborators"
	observerProcess ifNotNil: #terminate.
	observerProcess := nil.
	observer := nil.
	self noteBusy.
	announcer announce:
		(GtRrWorkerDisconnectedAnnouncement executor: self)
]

{ #category : #accessing }
GtRrExecutor >> gtLiveFor: aView [

	<gtView>
	^ aView explicit
		  title: 'Live';
		  priority: 9;
		  stencil: [ self asElement ]
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
GtRrExecutor >> initializeConnection: aConnection attributes: aDictionary observer: aBlock timeoutQueue: aQueue announcerScheduler: aScheduler [

	connection := aConnection.
	attributes := aDictionary.
	observer := aBlock.
	timeoutQueue := aQueue.
	announcer := GtRrAsyncAnnouncer scheduler: aScheduler
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

	"needed for future callbacks, scheduler should use #scheduleTaskExecution:"

	[ aTask value ]
		on: Error
		do: [ :error | self exceptionHandler handleException: error ]
]

{ #category : #schedulling }
GtRrExecutor >> scheduleTaskExecution: aTaskExecution [

	self assert: [ busy not ].
	self assert: [ currentTaskExecution isNil ].
	self noteBusy.
	currentTaskExecution := aTaskExecution.
	currentTaskExecution runner: self.
	currentTaskExecution executeTask.
	announcer announce:
		(GtRrTaskRunningAnnouncement task: currentTaskExecution task)
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
					taskExecution terminateWithReason:
						'Timeout after: ' , aTimeout asString ] ] ]
		at: DateAndTime now + aTimeout
]

{ #category : #private }
GtRrExecutor >> sendControlMessage: aMessage [

	^ observer value: { aMessage selector. aMessage arguments. aMessage lookupClass }
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

	| task |
	currentTaskExecution ifNil: [ ^ self ].
	currentTaskExecution task id = aTaskId ifFalse: [ ^ self ].
	task := currentTaskExecution task.
	currentTaskExecution finishWithFailure: aGtRrError.
	currentTaskExecution := nil.
	self noteFree.
	announcer announce:
		(GtRrTaskFailedAnnouncement task: task reason: aGtRrError)
]

{ #category : #running }
GtRrExecutor >> task: aTaskId success: anObject [

	| oldTaskExecution |
	currentTaskExecution ifNil: [ ^ self ].
	currentTaskExecution task id = aTaskId ifFalse: [ ^ self ].
	currentTaskExecution finishWithSuccess: anObject.
	oldTaskExecution := currentTaskExecution.
	currentTaskExecution := nil.
	self noteFree.
	announcer announce:
		(GtRrTaskSucceededAnnouncement task: oldTaskExecution task)
]
