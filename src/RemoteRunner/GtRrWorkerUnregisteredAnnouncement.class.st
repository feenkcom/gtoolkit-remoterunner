Class {
	#name : #GtRrWorkerUnregisteredAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'reason',
		'workerCount'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> reason [

	^ reason
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> reason: anObject [

	reason := anObject
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> workerCount [
	^ workerCount
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> workerCount: anObject [
	workerCount := anObject
]

{ #category : #accessing }
GtRrWorkerUnregisteredAnnouncement >> workerDetailsForLog [
	^ {self reason asString. workerCount asString. }
]
