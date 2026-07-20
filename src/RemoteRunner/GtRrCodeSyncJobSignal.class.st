Class {
	#name : #GtRrCodeSyncJobSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'job'
	],
	#category : 'RemoteRunner-Runner-CodeSync'
}

{ #category : #accessing }
GtRrCodeSyncJobSignal >> job [
	^ job
]

{ #category : #accessing }
GtRrCodeSyncJobSignal >> job: anObject [
	job := anObject
]
