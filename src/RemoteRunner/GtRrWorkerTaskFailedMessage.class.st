Class {
	#name : #GtRrWorkerTaskFailedMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'taskContextId',
		'executionData',
		'result',
		'jobId',
		'taskId'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> executionData [
	^ executionData
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> executionData: anObject [
	executionData := anObject
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> jobId [
	^jobId
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> jobId: anObject [
	jobId := anObject
]

{ #category : #processing }
GtRrWorkerTaskFailedMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [

	anOwner remoteRunner
		taskFailed: taskContextId
		workerId: workerId
		jobId: jobId
		taskId: taskId
		executionData: executionData.
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> taskContextId [
	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> taskContextId: anObject [
	taskContextId := anObject
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> taskId [
	^taskId
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> taskId: anObject [
	taskId := anObject
]
