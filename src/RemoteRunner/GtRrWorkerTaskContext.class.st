"
GtRrWorkerTaskContext holds the information required for the worker to execute the task and notify the runner.
"
Class {
	#name : #GtRrWorkerTaskContext,
	#superclass : #TKTTask,
	#instVars : [
		'taskContextId',
		'task',
		'taskTimeout'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrWorkerTaskContext class >> leJsonV4Name [

	^ #workerTaskContext
]

{ #category : #executing }
GtRrWorkerTaskContext >> futureTaskExecutionFor: aRunner [
	^ self configureTaskExecution: BlTktFutureExecution new with: aRunner
]

{ #category : #accessing }
GtRrWorkerTaskContext >> task [

	^ task
]

{ #category : #accessing }
GtRrWorkerTaskContext >> task: anObject [

	task := anObject
]

{ #category : #accessing }
GtRrWorkerTaskContext >> taskContextId [

	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskContext >> taskContextId: anObject [

	taskContextId := anObject
]

{ #category : #accessing }
GtRrWorkerTaskContext >> taskTimeout [

	^ taskTimeout
]

{ #category : #accessing }
GtRrWorkerTaskContext >> taskTimeout: anObject [

	taskTimeout := anObject
]

{ #category : #accessing }
GtRrWorkerTaskContext >> value [

	^ task run
]
