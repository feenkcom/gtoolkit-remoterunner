Class {
	#name : #GtRrWorkerChangesLogEvent,
	#superclass : #GtRrWorkerOperationLogEvent,
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #'as yet unclassified' }
GtRrWorkerChangesLogEvent >> descriptionOn: aStream [

	super descriptionOn: aStream.
	
	"aStream 
		<< ' | ';
		<< self remoteAddressString asString;
		<< ' | ';
		<< self workerId asString"
]

{ #category : #accessing }
GtRrWorkerChangesLogEvent >> remoteAddressString [
	^self eventStartedSignal remoteAddressString
]

{ #category : #accessing }
GtRrWorkerChangesLogEvent >> workerId [
	^self eventStartedSignal workerId
]
