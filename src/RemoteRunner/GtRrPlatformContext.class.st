Class {
	#name : #GtRrPlatformContext,
	#superclass : #Object,
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

{ #category : #accessing }
GtRrPlatformContext >> jobContext [

	^ jobContext
]

{ #category : #accessing }
GtRrPlatformContext >> jobContext: anObject [

	jobContext := anObject
]

{ #category : #'api - running' }
GtRrPlatformContext >> markTaskCompleted: aGtRrTaskContext [

	completedTasks add: aGtRrTaskContext.
	jobContext markTaskCompleted: aGtRrTaskContext.
	currentTasks remove: aGtRrTaskContext.
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
