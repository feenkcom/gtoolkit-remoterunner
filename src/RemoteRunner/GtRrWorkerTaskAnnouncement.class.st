Class {
	#name : #GtRrWorkerTaskAnnouncement,
	#superclass : #GtRrWorkerOperationAnnouncement,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerTaskAnnouncement >> task [

	^ task
]

{ #category : #accessing }
GtRrWorkerTaskAnnouncement >> task: anObject [

	task := anObject
]
