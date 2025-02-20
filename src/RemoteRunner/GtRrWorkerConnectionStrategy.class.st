Class {
	#name : #GtRrWorkerConnectionStrategy,
	#superclass : #Object,
	#instVars : [
		'worker'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #private }
GtRrWorkerConnectionStrategy >> executionDataFromTaskContext: aTaskContext [
	^ GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		additionalData: aTaskContext executionData additionalData
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
