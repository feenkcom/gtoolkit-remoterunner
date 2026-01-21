Class {
	#name : #GtRrTaskAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'task'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrTaskAnnouncement class >> fromStonDictionary: aDictionary [

	^ (super fromStonDictionary: aDictionary)
		task: (aDictionary at: #task);
		yourself

]

{ #category : #'instance creation' }
GtRrTaskAnnouncement class >> task: aGtRrTask [

	^ self new task: aGtRrTask 
]

{ #category : #converting }
GtRrTaskAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #taskExecutionResult put: self taskExecutionResult;
		yourself.
]

{ #category : #converting }
GtRrTaskAnnouncement >> asDictionary [

	^ super asDictionary
		at: #task put: task;
		yourself.
]

{ #category : #accessing }
GtRrTaskAnnouncement >> computeTaskExecutionResult [

	^ GtRrTaskExecutionResult new
		taskId: task taskId;
		executionData: task executionData.
]

{ #category : #accessing }
GtRrTaskAnnouncement >> executionData [

	^ task
		ifNil: [ (self properties at: #taskExecutionResult) executionData ]
		ifNotNil: [ task executionData ].
]

{ #category : #accessing }
GtRrTaskAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.

	self properties at: #taskExecutionResult put: (aDictionary at: #taskExecutionResult).
]

{ #category : #testing }
GtRrTaskAnnouncement >> isTaskCompleted [

	^ false
]

{ #category : #testing }
GtRrTaskAnnouncement >> isTaskFailed [

	^ false
]

{ #category : #testing }
GtRrTaskAnnouncement >> isTaskStarted [

	^ false
]

{ #category : #printing }
GtRrTaskAnnouncement >> printOneLineContentsOn: stream [

	task ifNil: [ ^ self ].
	stream print: task.

]

{ #category : #accessing }
GtRrTaskAnnouncement >> task [

	^ task
]

{ #category : #accessing }
GtRrTaskAnnouncement >> task: anObject [

	task := anObject
]

{ #category : #accessing }
GtRrTaskAnnouncement >> taskExecutionResult [

	^ task
		ifNil: [ self properties at: #taskExecutionResult ]
		ifNotNil: [ self computeTaskExecutionResult ]
]

{ #category : #accessing }
GtRrTaskAnnouncement >> taskId [

	^ task
		ifNil: [ (self properties at: #taskExecutionResult) taskId ]
		ifNotNil: [ task taskId ].
]
