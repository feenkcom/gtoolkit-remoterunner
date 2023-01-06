Class {
	#name : #GtRrTaskCompletedAnnouncement,
	#superclass : #GtRrTaskAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> computeTaskExecutionResult [

	^ super computeTaskExecutionResult
		taskResult: task result
]

{ #category : #testing }
GtRrTaskCompletedAnnouncement >> isTaskCompleted [

	^ true
]

{ #category : #accessing }
GtRrTaskCompletedAnnouncement >> taskResult [

	^ task
		ifNil: [ (self properties at: #taskExecutionResult) taskResult ]
		ifNotNil: [ task result ].
]
