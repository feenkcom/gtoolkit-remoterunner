Class {
	#name : #GtRrTaskContext,
	#superclass : #GtRrContext,
	#instVars : [
		'platformContext',
		'taskContextId',
		'task',
		'workerFuture',
		'taskTimeoutTime',
		'workerTimeoutTime'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #jsonV3 }
GtRrTaskContext class >> leJsonV4AttributeMapping [
	"Answer the collection of attribute to store keys."

	^ OrderedCollection new
		add: #taskContextId -> #taskContextId;
		add: #task -> #task;
		yourself.
]

{ #category : #accessing }
GtRrTaskContext class >> leJsonV4Name [

	^ #taskContext
]

{ #category : #accessing }
GtRrTaskContext >> connection [

	^ workerFuture connection
]

{ #category : #accessing }
GtRrTaskContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out.
	Actual task timeout is handled by the worker.  On the runner we are checking the worker timeout."
	<return: #DateAndTime>

	^ self workerTimeoutTime
]

{ #category : #accessing }
GtRrTaskContext >> errorDetails: anObject [

	task errorDetails: anObject
]

{ #category : #initialization }
GtRrTaskContext >> initialize [

	super initialize.
	taskContextId := UUID new asString.
]

{ #category : #testing }
GtRrTaskContext >> isFinished [

	^ task hasCompleted
]

{ #category : #testing }
GtRrTaskContext >> isTaskContext [

	^ true
]

{ #category : #accessing }
GtRrTaskContext >> jobContext [

	^ platformContext jobContext
]

{ #category : #accessing }
GtRrTaskContext >> jobTimeout [

	^ platformContext jobTimeout
]

{ #category : #running }
GtRrTaskContext >> markTaskCancelled [

	task markTaskCancelled.
	platformContext markTaskCancelled: self.
]

{ #category : #running }
GtRrTaskContext >> markTaskCompleted [

	task markTaskCompleted.
	platformContext markTaskCompleted: self.
]

{ #category : #running }
GtRrTaskContext >> markTaskStarted [ 

	task markTaskStarted.
	platformContext markTaskStarted: self.
	taskTimeoutTime := task startTime + self taskTimeout.
	workerTimeoutTime := task startTime + self workerTimeout.
]

{ #category : #accessing }
GtRrTaskContext >> platformContext [

	^ platformContext
]

{ #category : #accessing }
GtRrTaskContext >> platformContext: anObject [

	platformContext := anObject
]

{ #category : #printing }
GtRrTaskContext >> printOn: aStream [

	task
		ifNil: [ super printOn: aStream ]
		ifNotNil: [ task printOn: aStream ]
]

{ #category : #accessing }
GtRrTaskContext >> remoteRunner [

	^ platformContext remoteRunner
]

{ #category : #accessing }
GtRrTaskContext >> result: anObject [

	task result: anObject
]

{ #category : #running }
GtRrTaskContext >> run [
	"Run the receiver's task"

	^ task run
]

{ #category : #accessing }
GtRrTaskContext >> task [

	^ task
]

{ #category : #accessing }
GtRrTaskContext >> task: anObject [

	task := anObject
]

{ #category : #accessing }
GtRrTaskContext >> taskContextId [
	<return: #String>

	^ taskContextId
]

{ #category : #accessing }
GtRrTaskContext >> taskContextId: anObject [

	taskContextId := anObject
]

{ #category : #accessing }
GtRrTaskContext >> taskId [

	^ task taskId
]

{ #category : #accessing }
GtRrTaskContext >> taskTimeout [

	^ task taskTimeout ifNil:
		[ platformContext taskTimeout ]
]

{ #category : #accessing }
GtRrTaskContext >> taskTimeoutTime [
	"Answer the absolute time at which the task is considered to have timed out."
	<return: #DateAndTime>

	^ taskTimeoutTime
]

{ #category : #private }
GtRrTaskContext >> timeoutContext [
	"Terminate the receiver without timeout as the reason"

	task errorDetails: (GtRrErrorDetails new
		errorMessage: 'Worker exceeded time limit';
		setTrace).
	self remoteRunner terminateTaskContextId: taskContextId.
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture [
	<return: #GtRrFutureWorkerTask>

	^ workerFuture
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture: aGtRrFutureWorkerTask [

	workerFuture := aGtRrFutureWorkerTask.
	task workerIpAddress: workerFuture remoteAddress.
]

{ #category : #accessing }
GtRrTaskContext >> workerIpAddress: anObject [

	task workerIpAddress: anObject
]

{ #category : #accessing }
GtRrTaskContext >> workerTimeout [

	^ self remoteRunner workerTimeout
]

{ #category : #accessing }
GtRrTaskContext >> workerTimeoutTime [
	"Answer the absolute time at which the worker is considered to have timed out."
	<return: #DateAndTime>

	^ workerTimeoutTime
]
