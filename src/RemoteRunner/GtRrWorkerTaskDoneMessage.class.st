Class {
	#name : #GtRrWorkerTaskDoneMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'taskContextId',
		'executionData',
		'result',
		'jobId',
		'taskId'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> executionData [
	^ executionData
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> executionData: anObject [
	executionData := anObject
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> jobId [
	^jobId
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> jobId: anObject [
	jobId := anObject
]

{ #category : #processing }
GtRrWorkerTaskDoneMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [

	anOwner remoteRunner
		taskDone: taskContextId
		workerId: workerId
		jobId: jobId
		taskId: taskId
		executionData: executionData
		result: result.
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

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> taskId [
	^taskId
]

{ #category : #accessing }
GtRrWorkerTaskDoneMessage >> taskId: anObject [
	taskId := anObject
]
