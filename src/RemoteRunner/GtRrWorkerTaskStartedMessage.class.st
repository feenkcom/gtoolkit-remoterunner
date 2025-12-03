Class {
	#name : #GtRrWorkerTaskStartedMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'taskContextId',
		'taskId'
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
		[ remoteRunner currentlyExecutingTasks at: taskContextId 
			ifPresent: [ :taskContext | 
				remoteRunner registeredWorkers at: workerId 
					ifPresent: [ :worker |
						remoteRunner timeoutManager addContext: taskContext.
						taskContext workerConnection: worker ]
					ifAbsent: [ ] ]
			ifAbsent: 
				[ "Ignore if the task has already finished"
				(remoteRunner critical:
					[ (remoteRunner currentlyExecutingJobs anySatisfy:
						[ :job | job results anySatisfy:
							[ :task | task taskId = taskId ] ]) ]) ifFalse:
								[ GtRrMqTaskMissingSignal new
									taskContextId: taskContextId;
									taskId: taskId;
									emit ] ] ].
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskContextId [
	^ taskContextId
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskContextId: anObject [
	taskContextId := anObject
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskId [
	^taskId
]

{ #category : #accessing }
GtRrWorkerTaskStartedMessage >> taskId: anObject [
	taskId := anObject
]
