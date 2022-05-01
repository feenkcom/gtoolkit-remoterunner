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
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorkerTaskContext class >> leJsonV4Name [

	^ #workerTaskContext
]

{ #category : #accessing }
GtRrWorkerTaskContext >> endTime [

	^ task endTime
]

{ #category : #running }
GtRrWorkerTaskContext >> evaluateOn: anExecution [

	^ self value
]

{ #category : #executing }
GtRrWorkerTaskContext >> futureTaskExecutionFor: aRunner [
	^ self configureTaskExecution: GtRrFutureTimeoutableTaskExecution new with: aRunner
]

{ #category : #accessing }
GtRrWorkerTaskContext >> startTime [

	^ task startTime
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
GtRrWorkerTaskContext >> taskId [

	^ task taskId
]

{ #category : #accessing }
GtRrWorkerTaskContext >> taskTimeout [

	^ taskTimeout
]

{ #category : #accessing }
GtRrWorkerTaskContext >> taskTimeout: anObject [

	taskTimeout := anObject
]

{ #category : #executing }
GtRrWorkerTaskContext >> value [
	| result |

	"Lower the priority of the receiver so that commands get priority."
	"Processor activeProcess priority: Processor userBackgroundPriority."
	result := task timedRun.
	^ result.
]
