Class {
	#name : #GtRrWorkerTaskStartedMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'taskContextId'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtRrWorkerTaskStartedMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	| remoteRunner |
	remoteRunner := anOwner remoteRunner.
	remoteRunner markTaskStarted: taskContextId.
	remoteRunner critical:
		[ remoteRunner currentlyExecutingTasks at: taskContextId
			ifPresent: [ :taskContext | 
				remoteRunner timeoutManager addContext: taskContext.
				taskContext workerConnection: (remoteRunner registeredWorkers at: workerId) ] ]
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskContextId [
	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskContextId: anObject [
	taskContextId := anObject
]
