Class {
	#name : #GtRrExecutorTaskExecution,
	#superclass : #TKTTaskExecution,
	#traits : 'TGtRrExecutorExecution',
	#classTraits : 'TGtRrExecutorExecution classTrait',
	#instVars : [
		'timeout'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrExecutorTaskExecution >> finishWithFailure: aGtRrError [

	self isFinished ifFalse: [ self setFinishedState ]
]

{ #category : #accessing }
GtRrExecutorTaskExecution >> finishWithSuccess: anObject [

	self isFinished ifFalse: [ self setFinishedState ]
]

{ #category : #'gt-extension' }
GtRrExecutorTaskExecution >> gtLiveFor: aView [

	<gtView>
	^ aView explicit
		  title: 'Live';
		  priority: 9;
		  stencil: [ self asElement ]
]

{ #category : #initialization }
GtRrExecutorTaskExecution >> initialize [

	super initialize.
	state := GtRrExecutorReadyTaskState new
]

{ #category : #accessing }
GtRrExecutorTaskExecution >> timeout [

	^ timeout
]

{ #category : #accessing }
GtRrExecutorTaskExecution >> timeout: anObject [

	timeout := anObject
]
