Class {
	#name : #GtRrTaskContext,
	#superclass : #GtRrContext,
	#instVars : [
		'taskContextId',
		'task',
		'workerFuture',
		'taskTimeoutTime',
		'workerTimeoutTime',
		'jobContext',
		'retryTasks',
		'workerConnection'
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
		jobId: jobContext jobId;
		task: task;
		taskTimeout: self taskTimeout;
		exceptionHandlingStrategy: self jobContext exceptionHandlingStrategy.
]

{ #category : #accessing }
GtRrTaskContext >> connection [

	^ workerFuture ifNotNil: [ workerFuture connection ]
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

{ #category : #accessing }
GtRrTaskContext >> executionData [

	^ task executionData
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
GtRrTaskContext >> isNotStarted [

	^ task isNotStarted
]

{ #category : #testing }
GtRrTaskContext >> isStarted [

	^ task isStarted
]

{ #category : #testing }
GtRrTaskContext >> isTaskContext [

	^ true
]

{ #category : #'as yet unclassified' }
GtRrTaskContext >> job [

	^ jobContext job
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
GtRrTaskContext >> jobId [

	^ jobContext jobId
]

{ #category : #accessing }
GtRrTaskContext >> jobTimeout [

	^ jobContext jobTimeout
]

{ #category : #running }
GtRrTaskContext >> markTaskCancelled [

	self quietlyCancelTask.
	self job announce: (GtRrTaskFailedAnnouncement task: task)
]

{ #category : #running }
GtRrTaskContext >> markTaskCompleted [

	(#(completed cancelled) includes: task state) ifTrue: [ ^ self ].
	task markTaskCompleted.
	jobContext markTaskCompleted: self.
	self job announce: (task hasErrors
		ifTrue: [ self taskFailedAnnouncement ]
		ifFalse: [ self taskCompletedAnnouncement ])
]

{ #category : #running }
GtRrTaskContext >> markTaskFailed [

	(#(completed cancelled) includes: task state) ifTrue: [ ^ self ].
	task markTaskFailed.
	jobContext markTaskCompleted: self.
	self job announce: self taskFailedAnnouncement
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

{ #category : #running }
GtRrTaskContext >> quietlyCancelTask [

	(#(completed cancelled) includes: task state) ifTrue: [ ^ self ].
	task markTaskCancelled.
	jobContext markTaskCancelled: self.
]

{ #category : #running }
GtRrTaskContext >> registerHeartbeat [

	workerFuture registerHeartbeat
]

{ #category : #accessing }
GtRrTaskContext >> remoteRunner [

	^ jobContext remoteRunner
]

{ #category : #accessing }
GtRrTaskContext >> result [

	^ task result
]

{ #category : #accessing }
GtRrTaskContext >> result: anObject [

	task result: anObject
]

{ #category : #accessing }
GtRrTaskContext >> resultWithName: anAssociation [

	^ task resultWithName: anAssociation
]

{ #category : #accessing }
GtRrTaskContext >> retryTasks [
	"Answer the collection of tasks that were generated by the retry strategy"

	^ retryTasks ifNil: [ retryTasks := task retryTasksIn: self ].
]

{ #category : #running }
GtRrTaskContext >> run [
	"Run the receiver's task"

	^ task run
]

{ #category : #accessing }
GtRrTaskContext >> runInImage [
	| running watchdog process |
	self markTaskStarted.
	running := true.
	process := Processor activeProcess.
	task taskTimeout ifNotNil:
		[ watchdog := 
			[ task taskTimeout wait.
			running ifTrue: [ process signalException: GtRrTimeoutTaskError new. ]
		] forkNamed: 'runInImage timeout' ].
	task result: task timedRun.
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
GtRrTaskContext >> taskCompletedAnnouncement [

	^ GtRrTaskCompletedAnnouncement new
		task: self;
		retryTaskInfo: (self job class retryTasksInfoFrom: retryTasks)
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
GtRrTaskContext >> taskFailedAnnouncement [

	^ GtRrTaskFailedAnnouncement new
		task: self;
		retryTaskInfo: (self job class retryTasksInfoFrom: retryTasks)
]

{ #category : #accessing }
GtRrTaskContext >> taskId [

	^ task taskId
]

{ #category : #accessing }
GtRrTaskContext >> taskResult [

	^ task result
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
	| executionData |

	"If the worker has timed out its state is unknown,
	simply close the connection."
	self workerConnection ifNotNil:
		[ :connection | connection stop ].
	executionData := GtRrWorkerExecutionData new
		startTime: task startTime;
		endTime: task endTime;
		resourceReport: task executionData resourceReport;
		errorDetails: (GtRrErrorDetails new
			errorMessage: 'RemoteRunner forced termination';
			setTrace;
			yourself);
		additionalData: task executionData additionalData.
	self remoteRunner
		taskFailed: self taskContextId
		workerId: (self workerConnection ifNotNil: [ : connection | connection  workerId ])
		jobId: jobContext jobId
		taskId: self taskId
		executionData: executionData.
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
	"Answer the receiver's worker connection.
	For MQ runners this will be set directly."
	<return: #GtRrWorkerConnection>

	^ workerConnection
]

{ #category : #accessing }
GtRrTaskContext >> workerConnection: aGrRrWorkerConnection [

	workerConnection := aGrRrWorkerConnection.
	aGrRrWorkerConnection taskContext: self.
	self workerAttributes: aGrRrWorkerConnection attributes.
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture [
	<return: #GtRrFutureWorkerTask>

	^ workerFuture
]

{ #category : #accessing }
GtRrTaskContext >> workerFuture: aGtRrFutureWorkerTask [

	workerFuture := aGtRrFutureWorkerTask.
	self workerConnection: workerFuture connection.
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
