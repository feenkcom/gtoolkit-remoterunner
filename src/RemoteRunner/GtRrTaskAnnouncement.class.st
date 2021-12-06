Class {
	#name : #GtRrTaskAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrTaskAnnouncement class >> task: aGtRrTask [

	^ self new task: aGtRrTask 
]

{ #category : #accessing }
GtRrTaskAnnouncement >> task [

	^ task
]

{ #category : #accessing }
GtRrTaskAnnouncement >> task: anObject [

	task := anObject
]
