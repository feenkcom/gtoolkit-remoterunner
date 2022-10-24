Class {
	#name : #GtRrAnnouncementQueuePullCompletedSignal,
	#superclass : #GtRrAnnouncementQueuePullSignal,
	#instVars : [
		'retrivedAnnouncementCount'
	],
	#category : #'RemoteRunner-Logging-Signals'
}

{ #category : #accessing }
GtRrAnnouncementQueuePullCompletedSignal >> announcementsCount [
	^ self retrivedAnnouncementCount
]

{ #category : #testing }
GtRrAnnouncementQueuePullCompletedSignal >> isEndSignalType [
	^ true
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
