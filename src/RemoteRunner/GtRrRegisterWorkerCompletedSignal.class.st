Class {
	#name : #GtRrRegisterWorkerCompletedSignal,
	#superclass : #GtRrRegisterWorkerSignal,
	#instVars : [
		'ipAddress'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrRegisterWorkerCompletedSignal >> ipAddress [
	^ ipAddress
]

{ #category : #accessing }
GtRrRegisterWorkerCompletedSignal >> ipAddress: anObject [
	ipAddress := anObject
]

{ #category : #testing }
GtRrRegisterWorkerCompletedSignal >> isEndSignalType [
	^ true
]

{ #category : #printing }
GtRrRegisterWorkerCompletedSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		<< ipAddress asString
]
