Class {
	#name : #GtRrTaskFailedAnnouncement,
	#superclass : #GtRrTaskAnnouncement,
	#instVars : [
		'reason'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'as yet unclassified' }
GtRrTaskFailedAnnouncement class >> task: aGtRrTask reason: aReason [

	^ self new
		  task: aGtRrTask;
		  reason: aReason;
		  yourself
]

{ #category : #accessing }
GtRrTaskFailedAnnouncement >> reason [

	^ reason
]

{ #category : #accessing }
GtRrTaskFailedAnnouncement >> reason: anObject [

	reason := anObject
]
