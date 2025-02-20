Class {
	#name : #GtRrWorkerTaskFailedMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'taskContextId',
		'executionData',
		'result'
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

{ #category : #processing }
GtRrWorkerTaskFailedMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [

	anOwner remoteRunner
		taskFailed: taskContextId
		workerId: workerId
		executionData: executionData.
	aGtRrProcessor write: mqMessage ackFrame.
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> taskContextId [
	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskFailedMessage >> taskContextId: anObject [
	taskContextId := anObject
]
