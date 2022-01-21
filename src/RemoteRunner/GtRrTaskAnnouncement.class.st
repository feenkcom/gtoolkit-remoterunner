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

	^ self new
		  task: aGtRrTask;
		  yourself
]

{ #category : #accessing }
GtRrTaskAnnouncement >> id [

	^ task id 
]

{ #category : #accessing }
GtRrTaskAnnouncement >> task [

	^ task
]

{ #category : #accessing }
GtRrTaskAnnouncement >> task: anObject [

	task := anObject
]
