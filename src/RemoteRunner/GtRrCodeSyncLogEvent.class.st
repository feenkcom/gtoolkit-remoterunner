Class {
	#name : #GtRrCodeSyncLogEvent,
	#superclass : #GtRemoteRunnerExecutionLogEvent,
	#category : 'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrCodeSyncLogEvent >> ombuEntryReferenceName [
	^self eventStartedSignal ombuEntryReferenceName
]
