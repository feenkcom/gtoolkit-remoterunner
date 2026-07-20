Class {
	#name : #GtRrWorkerConnectionStrategy,
	#superclass : #Object,
	#instVars : [
		'worker'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #actions }
GtRrWorkerConnectionStrategy >> evaluateOnRunner: aBlock arguments: args [
	"Pass the supplied message to the RemoteRunner for evaluation.
	The RemoteRunner and arguments are passed in to the block as an argument.
	This is intended for fatal error notification, so no response is expected."

	self subclassResponsibility
]

{ #category : #private }
GtRrWorkerConnectionStrategy >> executionDataFromTaskContext: aTaskContext [
	^ GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		additionalData: aTaskContext executionData additionalData
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> localAddressString [
	"Answer the address of the local socket"

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> socketAddress: aString [

	self subclassResponsibility
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> worker [
	^ worker
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> worker: anObject [
	worker := anObject
]
