Class {
	#name : #GtRemoteRunnerTraceAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRemoteRunnerTraceAnnouncement >> message [

	^ message
]

{ #category : #accessing }
GtRemoteRunnerTraceAnnouncement >> message: anObject [

	message := anObject
]

{ #category : #accessing }
GtRemoteRunnerTraceAnnouncement >> printOneLineContentsOn: stream [

	stream << message asString
]
