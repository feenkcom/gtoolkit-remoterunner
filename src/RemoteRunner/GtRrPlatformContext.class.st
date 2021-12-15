Class {
	#name : #GtRrPlatformContext,
	#superclass : #GtRrContext,
	#instVars : [
		'jobContext',
		'platform',
		'pendingTasks',
		'currentTasks',
		'completedTasks'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrPlatformContext >> completedTasks [
	<return: #Array of: #GtRrTaskContext>

	^ completedTasks
]

{ #category : #accessing }
GtRrPlatformContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"
	<return: #DateAndTime>

	^ self shouldNotImplement
]

{ #category : #accessing }
GtRrPlatformContext >> currentTasks [

	^ currentTasks
]

{ #category : #initialization }
GtRrPlatformContext >> initialize [

	super initialize.
	pendingTasks := SharedQueue new.
	currentTasks := Set new.
	completedTasks := OrderedCollection new.
]

{ #category : #testing }
GtRrPlatformContext >> isFinished [
	"Answer a boolean indicating whether the receiver has finished or not"

	^ pendingTasks isEmpty and: [ currentTasks isEmpty and: [ completedTasks isNotEmpty ]]
]

{ #category : #testing }
GtRrPlatformContext >> isPlatformContext [

	^ true
]

{ #category : #accessing }
GtRrPlatformContext >> jobContext [

	^ jobContext
]

{ #category : #accessing }
GtRrPlatformContext >> jobContext: anObject [

	jobContext := anObject
]

{ #category : #accessing }
GtRrPlatformContext >> jobTimeout [

	^ jobContext jobTimeout
]

{ #category : #'api - running' }
GtRrPlatformContext >> markTaskCancelled: aGtRrTaskContext [

	completedTasks add: aGtRrTaskContext.
	jobContext markTaskCancelled: aGtRrTaskContext.

]

{ #category : #'api - running' }
GtRrPlatformContext >> markTaskCompleted: aGtRrTaskContext [

	completedTasks add: aGtRrTaskContext.
	jobContext markTaskCompleted: aGtRrTaskContext.
	currentTasks remove: aGtRrTaskContext.
]

{ #category : #'api - running' }
GtRrPlatformContext >> markTaskStarted: aGtRrTaskContext [

	jobContext markTaskStarted: aGtRrTaskContext.

]

{ #category : #accessing }
GtRrPlatformContext >> nextTaskOrNil [
	"Answer the next task to be executed, moving it from the pendingTasks to currentTasks.
	Or nil if there are no more pending tasks."
	<return: #GtRrTaskContext>
	| taskContext |

	taskContext := pendingTasks nextOrNil.
	taskContext ifNil: [ ^ nil ].
	currentTasks add: taskContext.
	self remoteRunner addCurrentlyExecutingTask: taskContext.
	^ taskContext
]

{ #category : #accessing }
GtRrPlatformContext >> pendingTasks [

	^ pendingTasks
]

{ #category : #accessing }
GtRrPlatformContext >> pendingTasks: anObject [

	pendingTasks := anObject
]

{ #category : #accessing }
GtRrPlatformContext >> platform [

	^ platform
]

{ #category : #accessing }
GtRrPlatformContext >> platform: anObject [

	platform := anObject
]

{ #category : #accessing }
GtRrPlatformContext >> remoteRunner [

	^ jobContext remoteRunner
]

{ #category : #accessing }
GtRrPlatformContext >> results [
	<return: #Array of: #GtRrTask>

	^ completedTasks collect: #task
]

{ #category : #accessing }
GtRrPlatformContext >> taskTimeout [

	^ jobContext taskTimeout
]

{ #category : #'api - running' }
GtRrPlatformContext >> terminateJob [
	"Start the process of terminating the receiver.
	This may be completed at a later time, after all the workers have terminated their tasks.
	Must be called within sharedAccess."
	| pendingTask |

	[ pendingTask := pendingTasks nextOrNil ] whileNotNil:
		[ pendingTask markTaskCancelled.
		completedTasks add: pendingTask ].
	currentTasks do: [ :taskContext |
		self remoteRunner terminateTaskContextId: taskContext taskContextId ]
]

{ #category : #private }
GtRrPlatformContext >> timeoutContext [
	"Terminate the receiver without timeout as the reason"

	self shouldNotImplement .
]
