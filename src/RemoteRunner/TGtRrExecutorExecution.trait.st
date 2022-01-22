Trait {
	#name : #TGtRrExecutorExecution,
	#instVars : [
		'state',
		'task',
		'runner',
		'timeout'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #evaluating }
TGtRrExecutorExecution >> doExecuteTask [

	"deploy on future is async"

	timeout ifNotNil: [ :d | runner scheduleTimeout: d on: self ]
]

{ #category : #initialization }
TGtRrExecutorExecution >> setCancelStateWithReason: aReason [

	super setCancelStateWithReason: aReason.
	runner task: task id failure: aReason
]

{ #category : #initialization }
TGtRrExecutorExecution >> setExplicitlyTerminatedStateWithReason: aReason [

	super setExplicitlyTerminatedStateWithReason: aReason.
	runner commandTerminateTaskId: task id.
	runner task: task id failure: aReason
]

{ #category : #initialization }
TGtRrExecutorExecution >> setRunningState [

	state := GtRrExecutorRunningTaskState new
]
