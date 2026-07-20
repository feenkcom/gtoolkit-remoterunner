Class {
	#name : #GtRemoteRunnerExecutionLogEvent,
	#superclass : #GtBeaconLogEvent,
	#category : 'RemoteRunner-Logging-Events'
}

{ #category : #printing }
GtRemoteRunnerExecutionLogEvent >> descriptionOn: aStream [

	aStream << self eventLabel asString.
]
