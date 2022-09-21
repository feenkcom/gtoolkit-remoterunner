Class {
	#name : #GtRrTaskContext,
	#superclass : #GtRrContext,
	#instVars : [
		'taskContextId',
		'task',
		'workerFuture',
		'taskTimeoutTime',
		'workerTimeoutTime',
		'jobContext'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrTaskContext class >> fromStonDictionary: aDictionary [

	^ (super fromStonDictionary: aDictionary)
		taskContextId: (aDictionary at: #taskContextId);
		task: (aDictionary at: #task);
		taskTimeoutTime: (aDictionary at: #taskTimeoutTime);
		workerTimeoutTime: (aDictionary at: #workerTimeoutTime);
		jobContext: (aDictionary at: #jobContext);
		yourself.
]

{ #category : #converting }
GtRrTaskContext >> asDictionary [

	^ super asDictionary
		at: #taskContextId put: taskContextId;
		at: #task put: task;
		at: #taskTimeoutTime put: taskTimeoutTime;
		at: #workerTimeoutTime put: workerTimeoutTime;
		at: #jobContext put: jobContext;
		yourself.
]

{ #category : #converting }
GtRrTaskContext >> asWorkerTaskContext [
	"Answer a GtRrWorkerTaskContext ready for transfer to the worker"

	^ GtRrWorkerTaskContext new
		taskContextId: taskContextId;
		task: task;
		taskTimeout: self taskTimeout.
]

{ #category : #accessing }
GtRrTaskContext >> connection [

	^ workerFuture connection
]

{ #category : #accessing }
GtRrTaskContext >> constraint [

	^ task constraint
]

{ #category : #accessing }
GtRrTaskContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out.
	Actual task timeout is handled by the worker.  On the runner we are checking the worker timeout."
	<return: #DateAndTime>

	^ self workerTimeoutTime
]

{ #category : #accessing }
GtRrTaskContext >> endTime: aDuration [

	task endTime: aDuration
]

{ #category : #accessing }
GtRrTaskContext >> errorDetails: anObject [

	task errorDetails: anObject
]

{ #category : #ui }
GtRrTaskContext >> gtResultFor: aView [
	<gtView>

	task ifNil: [ ^ aView empty ].
	^ aView forward
		  title: 'Result';
		  priority: 20;
		  object: [ task result ifNil: [ task errorDetails ifNil: [ '<No Result>' ] ] ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrTaskContext >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		send: [ :item | item value ];
		updateWhen: GtRrTaskAnnouncement 
			if: [ :announcement | announcement taskId = self taskId ] 
			in: self remoteRunner announcer;
		actionUpdateButton
]

{ #category : #ui }
GtRrTaskContext >> gtTerminateActionFor: anAction [
	<gtAction>

	task state = #started ifFalse: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons close;
		tooltip: 'Terminate task';
		action: [ :aButton | self terminateTask ]
]

{ #category : #initialization }
GtRrTaskContext >> initialize [

	super initialize.
	taskContextId := UUID new asString.
]

{ #category : #testing }
GtRrTaskContext >> isFinished [

	^ task isFinished
]

{ #category : #testing }
GtRrTaskContext >> isTaskContext [

	^ true
]

{ #category : #accessing }
GtRrTaskContext >> jobContext [

	^ jobContext
]

{ #category : #accessing }
GtRrTaskContext >> jobContext: anObject [

	jobContext := anObject
]

{ #category : #accessing }
GtRrTaskContext >> jobTimeout [

	^ jobContext jobTimeout
]

{ #category : #running }
GtRrTaskContext >> markTaskCancelled [

	task markTaskCancelled.
	jobContext markTaskCancelled: self.
]

{ #category : #running }
GtRrTaskContext >> markTaskCompleted [

	task markTaskCompleted.
	jobContext markTaskCompleted: self.
]

{ #category : #running }
GtRrTaskContext >> markTaskStarted [ 

	task markTaskStarted.
	jobContext markTaskStarted: self.
	taskTimeoutTime := task handoverTime + self taskTimeout.
	workerTimeoutTime := task handoverTime + self workerTimeout.
]

{ #category : #printing }
GtRrTaskContext >> printOn: aStream [

	task
		ifNil: [ super printOn: aStream ]
		ifNotNil: 
			[ task printOn: aStream.
			aStream
				<< ', ';
				print: taskContextId ]
]

{ #category : #accessing }
GtRrTaskContext >> remoteRunner [

	^ jobContext remoteRunner
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
GtRrTaskContext >> runInImage [

	self markTaskStarted.
	task runInImage.
	self markTaskCompleted.
]

{ #category : #accessing }
GtRrTaskContext >> startTime: aDuration [

	task startTime: aDuration
]

{ #category : #ui }
GtRrTaskContext >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ Array streamContents: [ :stream |
		task ifNotNil: [ stream nextPutAll: task summaryAttributes ].
		stream nextPut: #TaskContextId -> taskContextId.
		stream nextPut: #TimeoutTime -> self taskTimeoutTime ].
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
		[ jobContext taskTimeout ]
]

{ #category : #accessing }
GtRrTaskContext >> taskTimeoutTime [
	"Answer the absolute time at which the task is considered to have timed out."
	<return: #DateAndTime>

	^ taskTimeoutTime
]

{ #category : #accessing }
GtRrTaskContext >> taskTimeoutTime: anObject [

	taskTimeoutTime := anObject
]

{ #category : #running }
GtRrTaskContext >> terminateTask [
	"Terminate the receiver.
	Despite being in the GtRrTaskContext, this represents a worker timeout"

	task state = #started ifFalse: [ ^ self markTaskCancelled ].
	"If the worker has timed out its state is unknown,
	simply close the connection."
	workerFuture connection stop.
	task hasCompleted ifTrue: [ ^ self ].
	"The worker failed to terminate the task, terminate it on the server"
	self remoteRunner 
		taskFailed: taskContextId
		with: (GtRrErrorDetails new
			errorMessage: 'RemoteRunner forced timeout termination';
			setTrace;
			yourself).
]

{ #category : #private }
GtRrTaskContext >> timeoutContext [
	"Terminate the receiver with worker timeout as the reason"

	task errorDetails: (GtRrErrorDetails new
		errorMessage: 'Worker exceeded time limit';
		setTrace).
	self remoteRunner terminateTaskContextId: taskContextId.
]

{ #category : #accessing }
GtRrTaskContext >> workerAttributes: anObject [

	task workerAttributes: anObject
]

{ #category : #accessing }
GtRrTaskContext >> workerConnection [
	<return: #GtRrWorkerConnection>

	^ workerFuture connection
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture [
	<return: #GtRrFutureWorkerTask>

	^ workerFuture
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture: aGtRrFutureWorkerTask [

	workerFuture := aGtRrFutureWorkerTask.
	task workerAttributes: workerFuture workerAttributes.
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

{ #category : #accessing }
GtRrTaskContext >> workerTimeoutTime: anObject [

	workerTimeoutTime := anObject
]
