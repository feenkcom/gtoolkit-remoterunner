Class {
	#name : #GtRrWorkerCheckSignal,
	#superclass : #GtRrWorkerOperationSignal,
	#instVars : [
		'checkName'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrWorkerCheckSignal >> checkName [
	^ checkName
]

{ #category : #accessing }
GtRrWorkerCheckSignal >> checkName: anObject [
	checkName := anObject
]

{ #category : #accessing }
GtRrWorkerCheckSignal >> example: aGtExample [

	self checkName: aGtExample providerClass name asString, '>>', aGtExample selector
]

{ #category : #printing }
GtRrWorkerCheckSignal >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream 
		<< ' | ';
		<< checkName asString
]

{ #category : #accessing }
GtRrWorkerCheckSignal >> signalTypeLabel [

	^ 'Worker Check Execution Signal'
]

{ #category : #accessing }
GtRrWorkerCheckSignal >> testResult: aTest [

	self checkName: aTest class name asString, '>>', aTest selector
]
