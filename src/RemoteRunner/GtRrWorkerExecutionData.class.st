Class {
	#name : #GtRrWorkerExecutionData,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'endTime',
		'errorDetails',
		'additionalData',
		'resourceReport'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #lejsonv4 }
GtRrWorkerExecutionData class >> leJsonV4Name [

	^ #gtRrWorkerExecutionData
]

{ #category : #accessing }
GtRrWorkerExecutionData >> additionalData [

	^ additionalData
]

{ #category : #accessing }
GtRrWorkerExecutionData >> additionalData: anObject [

	additionalData := anObject
]

{ #category : #accessing }
GtRrWorkerExecutionData >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrWorkerExecutionData >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrWorkerExecutionData >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrWorkerExecutionData >> errorDetails: anObject [

	errorDetails := anObject
]

{ #category : #accessing }
GtRrWorkerExecutionData >> resourceReport [

	^ resourceReport
]

{ #category : #accessing }
GtRrWorkerExecutionData >> resourceReport: anObject [

	resourceReport := anObject
]

{ #category : #accessing }
GtRrWorkerExecutionData >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrWorkerExecutionData >> startTime: anObject [

	startTime := anObject
]
