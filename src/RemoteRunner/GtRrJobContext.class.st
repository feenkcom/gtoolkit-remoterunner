"
GtRrJobContext holds the current state of a job during execution.
"
Class {
	#name : #GtRrJobContext,
	#superclass : #GtRrContext,
	#instVars : [
		'job',
		'remoteRunner',
		'jobTimeoutTime',
		'taskContexts',
		'taskCompletedCount',
		'jobTimeout'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrJobContext class >> fromStonDictionary: aDictionary [

	^ (super fromStonDictionary: aDictionary)
		job: (aDictionary at: #job);
		jobTimeoutTime: (aDictionary at: #jobTimeoutTime);
		taskContexts: (aDictionary at: #taskContexts);
		yourself.
]

{ #category : #converting }
GtRrJobContext >> asDictionary [

	^ super asDictionary
		at: #job put: job;
		at: #jobTimeoutTime put: jobTimeoutTime;
		at: #taskContexts put: taskContexts;
		yourself.
]

{ #category : #'as yet unclassified' }
GtRrJobContext >> changesSync [

	^ job changesSync
]

{ #category : #accessing }
GtRrJobContext >> checkJobCompleted [
	"Ask the RemoteRunner to check whether the receiver is complete.
	Convenience method for debugging."
	
	self remoteRunner checkJobCompleted: self.
]

{ #category : #accessing }
GtRrJobContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"
	<return: #DateAndTime>

	^ self jobTimeoutTime
]

{ #category : #accessing }
GtRrJobContext >> exceptionHandlingStrategy [

	^ job exceptionHandlingStrategy
]

{ #category : #accessing }
GtRrJobContext >> gtActionCancelFor: anAction [
	"Terminate the receiver's job"
	<gtAction>
	(self job state = #started) ifFalse: [ 
		^ anAction noAction ].
	^ anAction button
		  tooltip: 'Cancel';
		  icon: BrGlamorousVectorIcons cancel;
		  priority: 3;
		  action: [ :aButton | 
		  	self terminate.
			  aButton phlow fireToolUpdateWish ]
]

{ #category : #accessing }
GtRrJobContext >> gtActionStartFor: anAction [

	<gtAction>
	(self job state = #notStarted) ifFalse: [ 
		^ anAction noAction].
	^ anAction button
		  label: 'Start';
		  priority: 2;
		  action: [ :aButton | 
		  	remoteRunner submitJob: job.
			  aButton phlow fireToolUpdateWish ]
]

{ #category : #ui }
GtRrJobContext >> gtErrorsFor: aView [
	<gtView>

	job ifNil: [ ^ aView empty ].
	^ aView list
		title: 'Errors';
		priority: 16;
		items: [ job resultsWithErrors ];
		updateWhen: GtRrJobAnnouncement 
			if: [ :announcement | announcement job = job ]
			in: [ remoteRunner announcer ]
]

{ #category : #ui }
GtRrJobContext >> gtPropertiesFor: aView [
	<gtView>

	job ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Properties';
		priority: 50;
		object: [ job ];
		view: #gtPropertiesFor:
]

{ #category : #ui }
GtRrJobContext >> gtResultsFor: aView [
	<gtView>

	job ifNil: [ ^ aView empty ].
	^ aView list
		title: 'Results';
		priority: 15;
		items: [ self results ];
		itemText: [ :item | item result ifNil: [ item errorDetails ] ];
		updateWhen: GtRrJobAnnouncement 
			if: [ :announcement | announcement job = job ]
			in: [ remoteRunner announcer ];
		actionUpdateButton
]

{ #category : #ui }
GtRrJobContext >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  updateWhen: GtRrJobAnnouncement
		  	if: [ :announcement | announcement job = job ]
		  	in: [ remoteRunner announcer ];
		  actionUpdateButton
]

{ #category : #ui }
GtRrJobContext >> gtTasksFor: aView [
	<gtView>

	^ aView list
		title: 'Tasks';
		priority: 50;
		items: [ taskContexts ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrJobContext >> id [

	^ job id
]

{ #category : #testing }
GtRrJobContext >> isFinished [
	"Answer a boolean indicating whether the receiver's job is finished.
	The job is finished if there are no tasks left in the queue or currently being processed.
	Must be called within shared access.
	I'm assuming that performance will be OK as the most common scenario is that only one job is executing at a time, so the first entry in currentlyExecutingTasks will  cause the method to answer false.  Only when the job is in fact finished will it need to iterate over the taskQueue, which could well be empty."

	"Check the executing tasks first as that will be faster, and if the job isn't finished there's probably a task being executed"
	remoteRunner currentlyExecutingTasks 
		detect: [ :taskContext | taskContext jobContext == self ]
		ifFound: [ ^ false ]
		ifNone: [ ].

	remoteRunner taskQueue itemArray
		detect: [ :taskContext | taskContext jobContext == self ]
		ifFound: [ ^ false ]
		ifNone: [ ].

		^ true
]

{ #category : #testing }
GtRrJobContext >> isJobContext [

	^ true
]

{ #category : #testing }
GtRrJobContext >> isStarted [

	^ job isStarted
]

{ #category : #accessing }
GtRrJobContext >> job [

	^ job
]

{ #category : #accessing }
GtRrJobContext >> job: aGtRrJob [

	job := aGtRrJob
]

{ #category : #accessing }
GtRrJobContext >> jobContext [

	^ self
]

{ #category : #accessing }
GtRrJobContext >> jobId [

	^ job jobId
]

{ #category : #accessing }
GtRrJobContext >> jobTimeout [
	"Answer the job timeout.
	nil = no timeout"

	^ job jobTimeout
]

{ #category : #accessing }
GtRrJobContext >> jobTimeoutTime [
	"Answer the absolute time at which the job is considered to have timed out."
	<return: #DateAndTime>

	^ jobTimeoutTime
]

{ #category : #accessing }
GtRrJobContext >> jobTimeoutTime: anObject [

	jobTimeoutTime := anObject
]

{ #category : #'api - running' }
GtRrJobContext >> markJobCompleted [

	job markJobCompleted
]

{ #category : #'api - running' }
GtRrJobContext >> markJobStarted [

	job markJobStarted.
	jobTimeoutTime := self jobTimeout ifNotNil: [ :timeout | job startTime + timeout ].
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskCancelled: aGtRrTaskContext [

	self markTaskCompleted: aGtRrTaskContext.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskCompleted: aGtRrTaskContext [

	job addResult: aGtRrTaskContext task.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskStarted: aGtRrTaskContext [

	remoteRunner announceAndLog: (GtRrTaskStartedAnnouncement task: aGtRrTaskContext).
	job announce: (GtRrTaskStartedAnnouncement task: aGtRrTaskContext task).
]

{ #category : #printing }
GtRrJobContext >> printOn: aStream [

	job
		ifNil: [ super printOn: aStream ]
		ifNotNil: [ job printOn: aStream ]
]

{ #category : #accessing }
GtRrJobContext >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrJobContext >> remoteRunner: aGtRemoteRunner [

	remoteRunner := aGtRemoteRunner
]

{ #category : #accessing }
GtRrJobContext >> results [

	^ job results
]

{ #category : #accessing }
GtRrJobContext >> runInImage [
	| taskContext |

	self markJobStarted.
	taskContexts := OrderedCollection new.
	job tasks do: [ :task |
		taskContext := GtRrTaskContext new
			task: task;
			jobContext: self.
		taskContexts add: taskContext.
		taskContext runInImage ].
	self markJobCompleted.
]

{ #category : #accessing }
GtRrJobContext >> state [

	^ job state
]

{ #category : #private }
GtRrJobContext >> submitTasks [
	"Submit the tasks to the receiver's runner"

	self taskContexts do: [ :taskContext |
		remoteRunner addTaskContext: taskContext ].
	remoteRunner assignTasksToWorkers.
]

{ #category : #ui }
GtRrJobContext >> summaryAttributes [
	| attributes |

	attributes := job 
		ifNil: [ OrderedCollection new ]
		ifNotNil: [ job summaryAttributes ].
	attributes
		add: 'Job Context Timeout' -> self jobTimeout;
		add: 'Task Context Timeout' -> self taskTimeout.
	^ attributes
]

{ #category : #accessing }
GtRrJobContext >> taskContexts [

	^ taskContexts ifNil: [ taskContexts := (job tasksFor: remoteRunner) collect: [ :task |
			GtRrTaskContext new 
				task: task;
				jobContext: self ] ]
]

{ #category : #accessing }
GtRrJobContext >> taskContexts: anObject [

	taskContexts := anObject
]

{ #category : #accessing }
GtRrJobContext >> taskTimeout [

	^ job taskTimeout ifNil: [ remoteRunner taskTimeout ]
]

{ #category : #'api - running' }
GtRrJobContext >> terminate [
	"Terminate the receiver's job."

	remoteRunner terminateJobId: job jobId.
]

{ #category : #private }
GtRrJobContext >> terminateJob [
	"Start the process of terminating the receiver.
	This may be completed at a later time, after all the workers have terminated their tasks.
	This is normally called by the remoteRunner.  To terminate the job from the job context use #terminate."

	job isFinished ifFalse:
		[ job markJobTerminating.
		self taskContexts do: [ :taskContext |
			taskContext terminateTask ] ].
	remoteRunner checkJobCompleted: self.
]

{ #category : #private }
GtRrJobContext >> timeoutContext [
	"Terminate the receiver without timeout as the reason"

	job errorDetails: (GtRrErrorDetails new
		errorMessage: 'Job exceeded time limit';
		setTrace).
	remoteRunner terminateJobId: self jobId
]
