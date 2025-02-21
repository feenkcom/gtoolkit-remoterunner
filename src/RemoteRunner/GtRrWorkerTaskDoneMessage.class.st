Class {
	#name : #GtRrWorkerTaskDoneMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'taskContextId',
		'executionData',
		'result'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> executionData [
	^ executionData
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> executionData: anObject [
	executionData := anObject
]

{ #category : #processing }
GtRrWorkerTaskDoneMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [

	anOwner remoteRunner
		taskDone: taskContextId
		workerId: workerId
		executionData: executionData
		result: result.
	aGtRrProcessor write: mqMessage ackFrame.
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> result [
	^ result
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> result: anObject [
	result := anObject
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> taskContextId [
	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> taskContextId: anObject [
	taskContextId := anObject
]
