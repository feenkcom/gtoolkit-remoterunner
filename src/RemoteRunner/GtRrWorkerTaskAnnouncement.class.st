Class {
	#name : #GtRrWorkerTaskAnnouncement,
	#superclass : #GtRrWorkerOperationAnnouncement,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #printing }
GtRrWorkerTaskAnnouncement >> printOneLineContentsOn: stream [

	stream print: task
]

{ #category : #accessing }
GtRrWorkerTaskAnnouncement >> task [

	^ task
]

{ #category : #accessing }
GtRrWorkerTaskAnnouncement >> task: anObject [

	task := anObject
]
