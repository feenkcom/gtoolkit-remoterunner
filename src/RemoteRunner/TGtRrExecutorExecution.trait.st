Trait {
	#name : #TGtRrExecutorExecution,
	#instVars : [
		'state',
		'task',
		'runner',
		'timeout',
		'startTime',
		'endTime'
	],
	#category : #'RemoteRunner-Runner-Support'
}

{ #category : #converting }
TGtRrExecutorExecution >> asElement [

	^ BlElement new
		  layout: BlLinearLayout horizontal;
		  constraintsDo: [ :c | 
			  c horizontal fitContent.
			  c vertical fitContent ];
		  in: [ :e | 
			  e addChild: (state gtRrAsElement
						   action: [ :b | b phlow spawnObject: self ];
						   yourself).
			  runner announcer
				  when: GtRrTaskAnnouncement
				  send: #requestUpdate
				  to: (BrElementUpdater new
						   element: e;
						   action: [ 
							   e
								   removeChildren;
								   addChild: (state gtRrAsElement
										    action: [ :b | b phlow spawnObject: self ];
										    yourself) ];
						   yourself) ];
		  yourself
]

{ #category : #evaluating }
TGtRrExecutorExecution >> doExecuteTask [

	"deploy on future is async"

	timeout ifNotNil: [ :d | runner scheduleTimeout: d on: self ]
]

{ #category : #accessing }
TGtRrExecutorExecution >> endTime [

	^ endTime
]

{ #category : #accessing }
TGtRrExecutorExecution >> finishWithFailure: aGtRrError [

	self explicitRequirement
]

{ #category : #accessing }
TGtRrExecutorExecution >> finishWithSuccess: anObject [

	self explicitRequirement
]

{ #category : #'gt-extension' }
TGtRrExecutorExecution >> gtLiveFor: aView [

	<gtView>
	^ aView explicit
		  title: 'Live';
		  priority: 9;
		  stencil: [ self asElement ]
]

{ #category : #initialization }
TGtRrExecutorExecution >> setCancelStateWithReason: aReason [

	super setCancelStateWithReason: aReason.
	runner task: task id failure: aReason.
	endTime := DateAndTime now
]

{ #category : #initialization }
TGtRrExecutorExecution >> setExplicitlyTerminatedStateWithReason: aReason [

	super setExplicitlyTerminatedStateWithReason: aReason.
	runner commandTerminateTaskId: task id.
	runner task: task id failure: aReason.
	endTime := DateAndTime now
]

{ #category : #initialization }
TGtRrExecutorExecution >> setFinishedState [

	super setFinishedState.
	endTime := DateAndTime now
]

{ #category : #initialization }
TGtRrExecutorExecution >> setRunningState [

	state := GtRrExecutorRunningTaskState new.
	startTime := DateAndTime now
]

{ #category : #accessing }
TGtRrExecutorExecution >> startTime [

	^ startTime
]

{ #category : #accessing }
TGtRrExecutorExecution >> timeout [

	^ timeout
]

{ #category : #accessing }
TGtRrExecutorExecution >> timeout: aDuration [

	timeout := aDuration
]
