Class {
	#name : #GtRrExecutorRunningTaskState,
	#superclass : #TKTRunningTaskState,
	#category : #'RemoteRunner-Runner-Support'
}

{ #category : #cancelling }
GtRrExecutorRunningTaskState >> cancelTaskExecution: aTaskExecution reason: aReason [

	self error: 'cannot cancel running execution, you may want to use terminate'
]

{ #category : #cancelling }
GtRrExecutorRunningTaskState >> terminateTaskExecution: aTaskExecution reason: aReason [

	aTaskExecution setExplicitlyTerminatedStateWithReason: aReason
]
