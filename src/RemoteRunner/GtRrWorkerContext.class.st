Class {
	#name : #GtRrWorkerContext,
	#superclass : #GtRrContext,
	#instVars : [
		'workerConnection',
		'startTime',
		'isFinished'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #'instance creation' }
GtRrWorkerContext class >> workerConnection: aGtRrWorkerConnection [

	^ self new workerConnection: aGtRrWorkerConnection
]

{ #category : #accessing }
GtRrWorkerContext >> contextTimeoutTime [
	"Answer the absolute time this context will time out"
	<return: #DateAndTime>

	^ startTime + self remoteRunner workerTimeout.
]

{ #category : #initialization }
GtRrWorkerContext >> initialize [

	super initialize.
	startTime := DateAndTime now.
	isFinished := false.
]

{ #category : #testing }
GtRrWorkerContext >> isFinished [

	^ isFinished
]

{ #category : #accessing }
GtRrWorkerContext >> isFinished: aBoolean [

	isFinished := aBoolean
]

{ #category : #accessing }
GtRrWorkerContext >> remoteRunner [

	^ workerConnection remoteRunner
]

{ #category : #private }
GtRrWorkerContext >> timeoutContext [
	"Terminate the receiver without timeout as the reason"

	self remoteRunner announceAndLog: (GtRrWorkerTimeoutAnnouncement worker: workerConnection).
	workerConnection stopWithReason: 'Worker Context Timed Out'.
]

{ #category : #accessing }
GtRrWorkerContext >> workerConnection [

	^ workerConnection
]

{ #category : #accessing }
GtRrWorkerContext >> workerConnection: anObject [

	workerConnection := anObject
]
