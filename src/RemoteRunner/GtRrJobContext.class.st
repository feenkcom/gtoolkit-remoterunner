"
GtRrJobContext holds the current state of a job during execution.
"
Class {
	#name : #GtRrJobContext,
	#superclass : #GtRrContext,
	#instVars : [
		'job',
		'tasks',
		'remoteRunner',
		'platformContexts',
		'jobTimeoutTime'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrJobContext >> atPlatform: aPlatform [
	"Answer the platform specific context for the named platform"

	^ platformContexts at: aPlatform
]

{ #category : #accessing }
GtRrJobContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"
	<return: #DateAndTime>

	^ self jobTimeoutTime
]

{ #category : #private }
GtRrJobContext >> createMultiplePlatformContexts [
	| platformContext |

	self platforms do: [ :platform |
		platformContext := GtRrPlatformContext new
			jobContext: self;
			platform: platform.
		platformContext pendingTasks items: (tasks collect: [ :task | 
			GtRrTaskContext new
				task: task copy;
				platformContext: platformContext ]).
		platformContexts at: platform put: platformContext ].
]

{ #category : #'api - startup' }
GtRrJobContext >> createPlatformContexts [
	"Create the platform contexts for the receiver.
	If the receiver has only one platform, the tasks can be directly allocated, otherwise copies of each task must be created for each platform."

	self platforms size = 1 ifTrue: 
		[ self createSinglePlatformContext ]
	ifFalse: 
		[ self createMultiplePlatformContexts ]
]

{ #category : #private }
GtRrJobContext >> createSinglePlatformContext [
	| platform platformContext |

	platform := self platforms first.
	platformContext := GtRrPlatformContext new
			jobContext: self;
			platform: platform.
	platformContext pendingTasks items: (tasks collect: [ :task |
		GtRrTaskContext new
			task: task;
			platformContext: platformContext ]).
	platformContexts at: platform put: platformContext.
]

{ #category : #private }
GtRrJobContext >> getTasks [

	tasks := job tasks
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
		items: [ tasks ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrJobContext >> id [

	^ job id
]

{ #category : #initialization }
GtRrJobContext >> initialize [ 

	super initialize.
	platformContexts := Dictionary new.
]

{ #category : #testing }
GtRrJobContext >> isFinished [

	^ platformContexts allSatisfy: #isFinished
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

{ #category : #'api - running' }
GtRrJobContext >> markJobCompleted [

	job markJobCompleted
]

{ #category : #'api - running' }
GtRrJobContext >> markJobStarted [

	job markJobStarted.
	jobTimeoutTime := job startTime + self jobTimeout.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskCancelled: aGtRrTaskContext [

	job addResult: aGtRrTaskContext task.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskCompleted: aGtRrTaskContext [

	job addResult: aGtRrTaskContext task.
]

{ #category : #'api - running' }
GtRrJobContext >> markTaskStarted: aGtRrTaskContext [

	job announce: (GtRrTaskStartedAnnouncement task: aGtRrTaskContext task)
]

{ #category : #private }
GtRrJobContext >> platformContexts [
	"Private: only for testing internal state"

	^ platformContexts
]

{ #category : #accessing }
GtRrJobContext >> platforms [

	^ job platforms
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
GtRrJobContext >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #accessing }
GtRrJobContext >> results [

	^ platformContexts values flatCollect: #results
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
GtRrJobContext >> taskTimeout [

	^ job taskTimeout ifNil: [ remoteRunner taskTimeout ]
]

{ #category : #accessing }
GtRrJobContext >> tasks [

	^ tasks
]

{ #category : #'api - running' }
GtRrJobContext >> terminateJob [
	"Start the process of terminating the receiver.
	This may be completed at a later time, after all the workers have terminated their tasks.
	Must be called within sharedAccess."

	job markJobTerminating.
	platformContexts do: #terminateJob.
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
