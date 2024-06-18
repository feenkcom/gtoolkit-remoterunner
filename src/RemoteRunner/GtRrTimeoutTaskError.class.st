Class {
	#name : #GtRrTimeoutTaskError,
	#superclass : #Error,
	#instVars : [
		'processesReport',
		'additionalData'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrTimeoutTaskError >> initialize [

	super initialize.
	additionalData := PharoLinkAdditionalData new.
]

{ #category : #initialization }
GtRrTimeoutTaskError >> initializeProcessesReport [

	additionalData at: #processesReport put: GtProcessesReport recordNewReport
]

{ #category : #accessing }
GtRrTimeoutTaskError >> pharoLinkAdditionalData [
	^ additionalData
]

{ #category : #accessing }
GtRrTimeoutTaskError >> processesReport [
	^ processesReport
]
