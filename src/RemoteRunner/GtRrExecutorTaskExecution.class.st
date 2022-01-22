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

{ #category : #converting }
GtRrExecutorTaskExecution >> asElement [

	^ state gtRrAsElement
]

{ #category : #accessing }
GtRrExecutorTaskExecution >> finishWithFailure: aGtRrError [

	self isFinished ifFalse: [ self setFinishedState ]
]

{ #category : #accessing }
GtRrExecutorTaskExecution >> finishWithSuccess: anObject [

	self isFinished ifFalse: [ self setFinishedState ]
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
