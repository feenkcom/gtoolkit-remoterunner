Class {
	#name : #GtRrExecutorReadyTaskState,
	#superclass : #TKTReadyTaskState,
	#category : #'RemoteRunner-Runner-Support'
}

{ #category : #executing }
GtRrExecutorReadyTaskState >> performTaskExecution: aTaskExecution [

	aTaskExecution setRunningState.
	aTaskExecution doExecuteTask
]
