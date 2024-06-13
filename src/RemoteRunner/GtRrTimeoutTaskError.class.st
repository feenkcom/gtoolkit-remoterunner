Class {
	#name : #GtRrTimeoutTaskError,
	#superclass : #Error,
	#instVars : [
		'processesReport'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #initialization }
GtRrTimeoutTaskError >> initializeProcessesReport [

	processesReport := GtProcessesReport recordNewReport
]

{ #category : #accessing }
GtRrTimeoutTaskError >> pharoLinkAdditionalData [
	^ processesReport
]

{ #category : #accessing }
GtRrTimeoutTaskError >> processesReport [
	^ processesReport
]
