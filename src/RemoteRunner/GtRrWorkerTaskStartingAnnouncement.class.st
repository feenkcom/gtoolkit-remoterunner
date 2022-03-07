Class {
	#name : #GtRrWorkerTaskStartingAnnouncement,
	#superclass : #GtRrWorkerTaskAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #printing }
GtRrWorkerTaskStartingAnnouncement >> printOneLineContentsOn: stream [

	task ifNil: [ ^ self ].
	stream print: task
]
