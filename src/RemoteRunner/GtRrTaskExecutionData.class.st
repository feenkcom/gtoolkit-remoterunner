"
GtRrTaskExecutionData holds on to all the information generated when running a task.
"
Class {
	#name : #GtRrTaskExecutionData,
	#superclass : #Object,
	#instVars : [
		'state',
		'handoverTime',
		'resultReceivedTime',
		'startTime',
		'endTime',
		'workerAttributes',
		'errorDetails',
		'additionalData',
		'resourceReport'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #lejsonv4 }
GtRrTaskExecutionData class >> leJsonV4Name [

	^ #gtRrTaskExecutionData
]

{ #category : #accessing }
GtRrTaskExecutionData >> additionalData [

	^ additionalData ifNil: [ additionalData := Dictionary new ]
]

{ #category : #accessing }
GtRrTaskExecutionData >> additionalData: anObject [

	additionalData := anObject
]

{ #category : #accessing }
GtRrTaskExecutionData >> additionalDataAt: key [

	^ additionalData at: key
]

{ #category : #accessing }
GtRrTaskExecutionData >> additionalDataAt: key ifAbsent: absentBlock [

	^ additionalData at: key ifAbsent: absentBlock
]

{ #category : #accessing }
GtRrTaskExecutionData >> additionalDataAt: key put: value [

	^ self additionalData at: key put: value.
]

{ #category : #accessing }
GtRrTaskExecutionData >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrTaskExecutionData >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrTaskExecutionData >> errorDetails [

	^ errorDetails
]

{ #category : #accessing }
GtRrTaskExecutionData >> errorDetails: aGtErrorDetails [
	"Set the error details of the receiver.
	Asynchronous events may cause multiple attempts at setting the details, use the first one"

	errorDetails ifNotNil: [ ^ self ].
	errorDetails := aGtErrorDetails
]

{ #category : #accessing }
GtRrTaskExecutionData >> handoverTime [

	^ handoverTime
]

{ #category : #accessing }
GtRrTaskExecutionData >> handoverTime: anObject [

	handoverTime := anObject
]

{ #category : #initialization }
GtRrTaskExecutionData >> initialize [

	super initialize.
	state := #notStarted.
]

{ #category : #accessing }
GtRrTaskExecutionData >> resourceReport [

	^ resourceReport
]

{ #category : #accessing }
GtRrTaskExecutionData >> resourceReport: anObject [

	resourceReport := anObject
]

{ #category : #accessing }
GtRrTaskExecutionData >> resultReceivedTime [

	^ resultReceivedTime
]

{ #category : #accessing }
GtRrTaskExecutionData >> resultReceivedTime: anObject [

	resultReceivedTime := anObject
]

{ #category : #accessing }
GtRrTaskExecutionData >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrTaskExecutionData >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
GtRrTaskExecutionData >> state [
	"Answer a Symbol indicating the inferred state of the receiver.
	One of: #notStarted, #started, #cancelled, #terminating, #terminated, #completed.
	The errorDetails are used to determine if the task completed successfully, why and where it was terminated, etc."

	^ state
]

{ #category : #accessing }
GtRrTaskExecutionData >> state: anObject [

	state := anObject
]

{ #category : #accessing }
GtRrTaskExecutionData >> updateFromWorker: aGtRrWorkerExecutionData [
	"Update the receiver based on the supplied data"

	startTime := aGtRrWorkerExecutionData startTime.
	endTime := aGtRrWorkerExecutionData endTime.
	self errorDetails: aGtRrWorkerExecutionData errorDetails.
	resourceReport := aGtRrWorkerExecutionData resourceReport.
	aGtRrWorkerExecutionData additionalData ifNotNil: [ :data |
		self additionalData addAll: data ].
]

{ #category : #accessing }
GtRrTaskExecutionData >> workerAttributes [

	^ workerAttributes
]

{ #category : #accessing }
GtRrTaskExecutionData >> workerAttributes: anObject [

	workerAttributes := anObject
]
