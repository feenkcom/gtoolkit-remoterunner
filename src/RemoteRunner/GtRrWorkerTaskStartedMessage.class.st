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
	"Process the receiver.
	If the task is no longer considered executing or the registered worker can't be found the worker has probably died, don't start the task."
	| remoteRunner |

	remoteRunner := anOwner remoteRunner.
	remoteRunner markTaskStarted: taskContextId.
	remoteRunner critical:
		[ remoteRunner currentlyExecutingTasks at: taskContextId ifPresent: [ :taskContext | 
			remoteRunner registeredWorkers at: workerId ifPresent: [ :worker |
				remoteRunner timeoutManager addContext: taskContext.
				taskContext workerConnection: worker ] ] ]
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskContextId [
	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskContextId: anObject [
	taskContextId := anObject
]
