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

{ #category : #converting }
TGtRrExecutorExecution >> asElement [

	^ BlElement new
		  layout: BlLinearLayout horizontal;
		  constraintsDo: [ :c | 
			  c horizontal fitContent.
			  c vertical fitContent ];
		  when: BlClickEvent do: [ :e | e target phlow spawnObject: self ];
		  in: [ :e | 
			  e addChild: state gtRrAsElement.
			  runner announcer
				  when: GtRrTaskAnnouncement
				  send: #requestUpdate
				  to: (BrElementUpdater new
						   element: e;
						   action: [ 
							   e
								   removeChildren;
								   addChild: state gtRrAsElement ];
						   yourself) ];
		  yourself
]

{ #category : #evaluating }
TGtRrExecutorExecution >> doExecuteTask [

	"deploy on future is async"

	timeout ifNotNil: [ :d | runner scheduleTimeout: d on: self ]
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
