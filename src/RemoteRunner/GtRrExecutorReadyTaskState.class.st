Class {
	#name : #GtRrExecutorReadyTaskState,
	#superclass : #TKTReadyTaskState,
	#category : #'RemoteRunner-Runner'
}

{ #category : #executing }
GtRrExecutorReadyTaskState >> performTaskExecution: aTaskExecution [

	aTaskExecution setRunningState.
	aTaskExecution doExecuteTask
]
