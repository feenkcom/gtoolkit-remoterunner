Class {
	#name : #GtRrWorkerTaskStartedAnnouncement,
	#superclass : #GtRrWorkerTaskAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #printing }
GtRrWorkerTaskStartedAnnouncement >> printOneLineContentsOn: stream [

	task ifNil: [ ^ self ].
	stream print: task
]
