Class {
	#name : #GtRrTaskFailedAnnouncement,
	#superclass : #GtRrTaskFinishedAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #'as yet unclassified' }
GtRrTaskFailedAnnouncement >> computeTaskExecutionResult [

	^ super computeTaskExecutionResult
		taskResult: task result
]

{ #category : #testing }
GtRrTaskFailedAnnouncement >> isTaskFailed [

	^ true
]

{ #category : #accessing }
GtRrTaskFailedAnnouncement >> taskResult [

	^ task
		ifNil: [ (self properties at: #taskExecutionResult) taskResult ]
		ifNotNil: [ task result ].
]
