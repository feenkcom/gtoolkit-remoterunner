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

	task ifNil: [ ^ super printOneLineContentsOn: stream ].
	stream print: task taskId
]

{ #category : #accessing }
GtRrWorkerTaskAnnouncement >> task [

	^ task
]

{ #category : #accessing }
GtRrWorkerTaskAnnouncement >> task: anObject [

	task := anObject
]
