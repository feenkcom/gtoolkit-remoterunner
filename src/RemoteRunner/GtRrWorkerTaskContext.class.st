"
GtRrWorkerTaskContext holds the information required for the worker to execute the task and notify the runner.
"
Class {
	#name : #GtRrWorkerTaskContext,
	#superclass : #TKTTask,
	#instVars : [
		'taskContextId',
		'task',
		'taskTimeout',
		'exceptionHandlingStrategy',
		'jobId'
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

{ #category : #accessing }
GtRrWorkerTaskContext >> exceptionHandlingStrategy [

	^ exceptionHandlingStrategy
]

{ #category : #accessing }
GtRrWorkerTaskContext >> exceptionHandlingStrategy: anObject [

	exceptionHandlingStrategy := anObject
]

{ #category : #accessing }
GtRrWorkerTaskContext >> executionData [

	^ task executionData
]

{ #category : #executing }
GtRrWorkerTaskContext >> futureTaskExecutionFor: aRunner [
	^ self configureTaskExecution: GtRrFutureTimeoutableTaskExecution new with: aRunner
]

{ #category : #accessing }
GtRrWorkerTaskContext >> jobId [
	^jobId
]

{ #category : #accessing }
GtRrWorkerTaskContext >> jobId: anObject [
	jobId := anObject
]

{ #category : #accessing }
GtRrWorkerTaskContext >> postCopy [
	"The task context is copied by the in-image worker to get a copy of the task.
	Don't generate a new UID."

	super postCopy.
	task := task copy.
]

{ #category : #printing }
GtRrWorkerTaskContext >> printOn: aStream [

	super printOn: aStream.
	taskContextId ifNotNil:
		[ aStream
			nextPut: $(;
			print: taskContextId;
			nextPut: $) ].
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
	Processor activeProcess priority: Processor userBackgroundPriority.
	result := task timedRun.
	^ result.
]
