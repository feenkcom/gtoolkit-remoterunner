Trait {
	#name : #TGtRrWorkerExecution,
	#instVars : [
		'scheduler'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #evaluating }
TGtRrWorkerExecution >> doExecuteTask [

	"deploy on future is async"

	self timeout ifNotNil: [ :d | scheduler scheduleTimeout: d on: self ]
]

{ #category : #accessing }
TGtRrWorkerExecution >> finishWithFailure: aGtRrError [

	^ self explicitRequirement
]

{ #category : #accessing }
TGtRrWorkerExecution >> finishWithSuccess: anObject [

	^ self explicitRequirement
]

{ #category : #accessing }
TGtRrWorkerExecution >> runner [

	^ self explicitRequirement
]

{ #category : #private }
TGtRrWorkerExecution >> schedule [

	self setRunningState.
	self doExecuteTask
]

{ #category : #accessing }
TGtRrWorkerExecution >> scheduler [

	^ scheduler
]

{ #category : #accessing }
TGtRrWorkerExecution >> scheduler: anObject [

	scheduler := anObject
]

{ #category : #initialization }
TGtRrWorkerExecution >> setCancelStateWithReason: aReason [

	super setCancelStateWithReason: aReason.
	self runner task: self task id failure: aReason.
	scheduler announceAndLog:
		(GtRrTaskFailedAnnouncement task: self task reason: aReason)
]

{ #category : #initialization }
TGtRrWorkerExecution >> setExplicitlyTerminatedStateWithReason: aReason [

	super setExplicitlyTerminatedStateWithReason: aReason.
	self runner isConnected
		ifTrue: [ self runner commandTerminateTaskId: self task id ]
		ifFalse: [ 
			self setExplicitlyTerminatedStateWithReason: aReason.
			self runner task: self task id failure: aReason ].
	(self runner commandTerminateTaskId: self task id) ifFalse: [ 
		self runner task: self task id failure: aReason ].
	scheduler announceAndLog:
		(GtRrTaskFailedAnnouncement task: self task reason: aReason)
]

{ #category : #initialization }
TGtRrWorkerExecution >> setFinishedState [

	super setFinishedState.
	scheduler announceAndLog:
		(GtRrTaskFinishedAnnouncement task: self task)
]

{ #category : #initialization }
TGtRrWorkerExecution >> setRunningState [

	super setRunningState.
	scheduler announceAndLog:
		(GtRrTaskRunningAnnouncement task: self task)
]

{ #category : #accessing }
TGtRrWorkerExecution >> stop [

	self isFinished ifFalse: [ 
		self terminateWithReason: 'worker runner stopped' gtRrAsError ]
]

{ #category : #accessing }
TGtRrWorkerExecution >> timeout [

	^ self explicitRequirement
]
