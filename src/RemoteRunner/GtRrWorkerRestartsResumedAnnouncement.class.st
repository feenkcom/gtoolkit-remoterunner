"
I am announced by a {{gtClass:GtRrWorkerManager}} when {{gtMethod:GtRrWorkerManager>>retryWorkerStartup}} forgets the worker failures and starts workers again after a {{gtClass:GtRrWorkerRestartsStoppedAnnouncement}}.
"
Class {
	#name : #GtRrWorkerRestartsResumedAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #printing }
GtRrWorkerRestartsResumedAnnouncement >> printOneLineContentsOn: aStream [

	aStream << 'worker restarts resumed'
]
