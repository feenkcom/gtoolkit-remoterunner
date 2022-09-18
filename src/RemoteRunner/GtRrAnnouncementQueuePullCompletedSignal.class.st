Class {
	#name : #GtRrAnnouncementQueuePullCompletedSignal,
	#superclass : #GtRrAnnouncementQueuePullSignal,
	#instVars : [
		'retrivedAnnouncementCount'
	],
	#category : #'RemoteRunner-Logging-Signals'
}

{ #category : #testing }
GtRrAnnouncementQueuePullCompletedSignal class >> isEndSignalType [
	^ true
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedSignal >> announcementsCount [
	^ self retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedSignal >> printOneLineContentsOn: stream [

	stream 
		<< 'count: '
		print: retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedSignal >> retrivedAnnouncementCount [
	^ retrivedAnnouncementCount
]

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedSignal >> retrivedAnnouncementCount: anInteger [
	retrivedAnnouncementCount := anInteger
]
