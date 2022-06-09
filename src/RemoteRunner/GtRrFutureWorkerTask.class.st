"
A GtRrFutureWorkerTask is created each time a worker calls in to the runner indicating it is waiting for its next task.

Once the task is assigned to the worker, the semaphore is signalled and the task returned to the worker.
"
Class {
	#name : #GtRrFutureWorkerTask,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'connection',
		'taskContext'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrFutureWorkerTask >> connection [
	<return: #GtRrWorkerConnection>

	^ connection
]

{ #category : #accessing }
GtRrFutureWorkerTask >> connection: aGtRrWorkerConnection [

	connection := aGtRrWorkerConnection
]

{ #category : #accessing }
GtRrFutureWorkerTask >> details [

	^ connection details.
]

{ #category : #initialization }
GtRrFutureWorkerTask >> initialize [

	super initialize.
	semaphore := Semaphore new.

]

{ #category : #accessing }
GtRrFutureWorkerTask >> remoteAddress [

	^ connection 
		ifNil: [ ByteArray new: 4 ]
		ifNotNil: [ connection remoteAddress ]
]

{ #category : #accessing }
GtRrFutureWorkerTask >> remoteAddressString [

	^ GtRemoteRunner printIpAddress: self remoteAddress
]

{ #category : #accessing }
GtRrFutureWorkerTask >> taskContext [
	<return: #GtRrTaskContext>

	^ taskContext
]

{ #category : #accessing }
GtRrFutureWorkerTask >> taskContext: aGtRrTaskContext [

	taskContext := aGtRrTaskContext.
	semaphore signal.
]

{ #category : #'api - future' }
GtRrFutureWorkerTask >> terminateProcess [

	semaphore terminateProcess
]

{ #category : #running }
GtRrFutureWorkerTask >> terminateTaskContextId: taskContextId [

	^ connection commandTerminateTaskContextId: taskContextId
]

{ #category : #'api - future' }
GtRrFutureWorkerTask >> wait [

	semaphore wait
]

{ #category : #accessing }
GtRrFutureWorkerTask >> workerAttributes [

	^ connection details
]

{ #category : #accessing }
GtRrFutureWorkerTask >> workerPriority [

	^ connection workerPriority
]
