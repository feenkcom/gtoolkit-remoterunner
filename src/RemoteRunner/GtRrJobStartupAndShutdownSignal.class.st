Class {
	#name : #GtRrJobStartupAndShutdownSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'jobId',
		'eventType'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #logging }
GtRrJobStartupAndShutdownSignal class >> emitEndForJobContext: aJobContext [
	^ (self forJobContext:  aJobContext) 
		markAsEndSignal;
		emit
]

{ #category : #logging }
GtRrJobStartupAndShutdownSignal class >> emitStartForJobContext: aJobContext [
	^ (self forJobContext:  aJobContext) 
		markAsStartSignal;
		emit
]

{ #category : #'instance creation' }
GtRrJobStartupAndShutdownSignal class >> forJobContext: aJobContext [ 
	^ self new 
		jobId: aJobContext id
]

{ #category : #testing }
GtRrJobStartupAndShutdownSignal >> isEndSignalType [
	^ eventType = #endSignal
]

{ #category : #testing }
GtRrJobStartupAndShutdownSignal >> isStartSignalType [
	^ eventType = #startSignal
]

{ #category : #accessing }
GtRrJobStartupAndShutdownSignal >> jobId [
	^ jobId
]

{ #category : #accessing }
GtRrJobStartupAndShutdownSignal >> jobId: anId [
	jobId := anId
]

{ #category : #configuring }
GtRrJobStartupAndShutdownSignal >> markAsEndSignal [
	eventType := #endSignal
]

{ #category : #configuring }
GtRrJobStartupAndShutdownSignal >> markAsStartSignal [
	eventType := #startSignal
]

{ #category : #accessing }
GtRrJobStartupAndShutdownSignal >> printOneLineContentsOn: aStream [
	aStream 
		nextPut: $|; space;
		nextPutAll: 'RemoteRunnerSignal';
		space; nextPut: $|; space;
		nextPutAll: eventType;
		space; nextPut: $|; space;
		nextPutAll: self jobId;
		space; nextPut: $|; space;
		nextPutAll: self processId
]
