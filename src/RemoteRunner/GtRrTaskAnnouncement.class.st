Class {
	#name : #GtRrTaskAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Announcements'
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
		at: #taskId put: self computeTaskId;
		yourself.
]

{ #category : #converting }
GtRrTaskAnnouncement >> asDictionary [

	^ super asDictionary
		at: #task put: task;
		yourself.
]

{ #category : #accessing }
GtRrTaskAnnouncement >> computeTaskId [
	^ task taskId
]

{ #category : #accessing }
GtRrTaskAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.
	
	self taskId: (aDictionary at: #taskId).
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
GtRrTaskAnnouncement >> taskId [

	^ task
		ifNil: [ self properties at: #taskId ]
		ifNotNil: [ self computeTaskId ].
]

{ #category : #accessing }
GtRrTaskAnnouncement >> taskId: anId [

	self properties at: #taskId put: anId
]
