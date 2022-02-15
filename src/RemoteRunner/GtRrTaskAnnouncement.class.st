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
GtRrTaskAnnouncement >> asDictionary [

	^ super asDictionary
		at: #task put: task;
		yourself.
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

	^ task taskId
]
