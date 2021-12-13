"
GtRrJobContext holds the current state of a job during execution.
"
Class {
	#name : #GtRrJobContext,
	#superclass : #Object,
	#instVars : [
		'job',
		'tasks',
		'remoteRunner',
		'platformContexts'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrJobContext >> atPlatform: aPlatform [
	"Answer the platform specific context for the named platform"

	^ platformContexts at: aPlatform
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

{ #category : #'api - running' }
GtRrJobContext >> markJobCompleted [

	job markJobCompleted
]

{ #category : #'api - running' }
GtRrJobContext >> markJobStarted [

	job markJobStarted
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
	remoteRunner checkJobFinished: self.
]
