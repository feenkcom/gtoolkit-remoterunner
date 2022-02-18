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
		'taskCompletedCount'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrJobContext class >> fromStonDictionary: aDictionary [

	^ (super fromStonDictionary: aDictionary)
		job: (aDictionary at: #job);
		jobTimeoutTime: (aDictionary at: #jobTimeoutTime);
		taskCompletedCount: (aDictionary at: #taskCompletedCount);
		taskContexts: (aDictionary at: #taskContexts);
		yourself.
]

{ #category : #converting }
GtRrJobContext >> asDictionary [

	^ super asDictionary
		at: #job put: job;
		at: #jobTimeoutTime put: jobTimeoutTime;
		at: #taskCompletedCount put: taskCompletedCount;
		at: #taskContexts put: taskContexts;
		yourself.
]

{ #category : #accessing }
GtRrJobContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"
	<return: #DateAndTime>

	^ self jobTimeoutTime
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

	^ taskCompletedCount >= taskContexts size.
]

{ #category : #testing }
GtRrJobContext >> isJobContext [

	^ true
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
GtRrJobContext >> jobTimeout [

	^ job jobTimeout ifNil: [ remoteRunner jobTimeout ]
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
	jobTimeoutTime := job startTime + self jobTimeout.
	taskCompletedCount := 0.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskCancelled: aGtRrTaskContext [

	self markTaskCompleted: aGtRrTaskContext.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskCompleted: aGtRrTaskContext [

	job addResult: aGtRrTaskContext task.
	taskCompletedCount := taskCompletedCount + 1.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskStarted: aGtRrTaskContext [

	job announce: (GtRrTaskStartedAnnouncement task: aGtRrTaskContext task)
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

{ #category : #private }
GtRrJobContext >> submitTasks [
	"Submit the tasks to the receiver's runner"

	self taskContexts do: [ :taskContext |
		remoteRunner addTaskContext: taskContext ]
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
GtRrJobContext >> taskCompletedCount [

	^ taskCompletedCount
]

{ #category : #accessing }
GtRrJobContext >> taskCompletedCount: anObject [

	taskCompletedCount := anObject
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
GtRrJobContext >> terminateJob [
	"Start the process of terminating the receiver.
	This may be completed at a later time, after all the workers have terminated their tasks."

	job markJobTerminating.
	self taskContexts do: [ :taskContext |
		self remoteRunner terminateTaskContextId: taskContext taskContextId ].
	remoteRunner checkJobCompleted: self.
]

{ #category : #private }
GtRrJobContext >> timeoutContext [
	"Terminate the receiver without timeout as the reason"

	job errorDetails: (GtRrErrorDetails new
		errorMessage: 'Job exceeded time limit';
		setTrace).
	remoteRunner terminateJobId: self id
]
