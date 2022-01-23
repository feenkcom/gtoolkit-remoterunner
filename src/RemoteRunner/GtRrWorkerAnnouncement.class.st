Class {
	#name : #GtRrWorkerAnnouncement,
	#superclass : #GtRrAnnouncement,
	#instVars : [
		'executor'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerAnnouncement class >> executor: anExecutor [

	^ self new
		  executor: anExecutor;
		  yourself
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> executor [

	^ executor
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> executor: anObject [

	executor := anObject
]
