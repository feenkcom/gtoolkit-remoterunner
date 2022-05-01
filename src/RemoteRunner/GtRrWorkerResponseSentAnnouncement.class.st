Class {
	#name : #GtRrWorkerResponseSentAnnouncement,
	#superclass : #GtRrWorkerTaskAnnouncement,
	#instVars : [
		'result'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerResponseSentAnnouncement >> result [

	^ result
]

{ #category : #accessing }
GtRrWorkerResponseSentAnnouncement >> result: anObject [

	result := anObject
]
