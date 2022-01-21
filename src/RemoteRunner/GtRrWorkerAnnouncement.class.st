Class {
	#name : #GtRrWorkerAnnouncement,
	#superclass : #GtRrAnnouncement,
	#instVars : [
		'worker'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerAnnouncement class >> worker: aGtRrWorkerRemote [

	^ self new worker: aGtRrWorkerRemote
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker [

	^ worker
]

{ #category : #accessing }
GtRrWorkerAnnouncement >> worker: anObject [

	worker := anObject
]
