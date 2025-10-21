Class {
	#name : #GtRrRegisterWorkerRejectedSignal,
	#superclass : #GtRrRegisterWorkerSignal,
	#instVars : [
		'ipAddress'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrRegisterWorkerRejectedSignal >> ipAddress [
	^ ipAddress
]

{ #category : #accessing }
GtRrRegisterWorkerRejectedSignal >> ipAddress: anObject [
	ipAddress := anObject
]

{ #category : #testing }
GtRrRegisterWorkerRejectedSignal >> isEndSignalType [
	^ true
]

{ #category : #printing }
GtRrRegisterWorkerRejectedSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< ipAddress asString
]
