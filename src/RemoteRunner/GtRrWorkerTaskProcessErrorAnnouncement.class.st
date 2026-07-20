Class {
	#name : #GtRrWorkerTaskProcessErrorAnnouncement,
	#superclass : #GtRrWorkerOperationAnnouncement,
	#instVars : [
		'taskContext',
		'exception'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerTaskProcessErrorAnnouncement >> exception [

	^ exception
]

{ #category : #accessing }
GtRrWorkerTaskProcessErrorAnnouncement >> exception: anObject [

	exception := anObject
]

{ #category : #accessing }
GtRrWorkerTaskProcessErrorAnnouncement >> printOneLineContentsOn: stream [

	exception printOn: stream.
]

{ #category : #accessing }
GtRrWorkerTaskProcessErrorAnnouncement >> taskContext [

	^ taskContext
]

{ #category : #accessing }
GtRrWorkerTaskProcessErrorAnnouncement >> taskContext: anObject [

	taskContext := anObject
]
