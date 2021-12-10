"
A GtRrFutureWorkerTask is created each time a worker calls in to the runner indicating it is waiting for its next task.

Once the task is assigned to the worker, the semaphore is signalled and the task returned to the worker.
"
Class {
	#name : #GtRrFutureWorkerTask,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'platform',
		'connection',
		'taskContext'
	],
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
GtRrFutureWorkerTask >> connection [
	<return: #PharoLinkServerConnection>

	^ connection
]

{ #category : #accessing }
GtRrFutureWorkerTask >> connection: aPharoLinkServerConnection [

	connection := aPharoLinkServerConnection
]

{ #category : #initialization }
GtRrFutureWorkerTask >> initialize [

	super initialize.
	semaphore := Semaphore new.

]

{ #category : #accessing }
GtRrFutureWorkerTask >> platform [

	^ platform
]

{ #category : #accessing }
GtRrFutureWorkerTask >> platform: anObject [

	platform := anObject
]

{ #category : #accessing }
GtRrFutureWorkerTask >> remoteAddress [

	^ connection 
		ifNil: [ ByteArray new: 4 ]
		ifNotNil: [ connection remoteAddress ]
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

{ #category : #'api - future' }
GtRrFutureWorkerTask >> wait [

	semaphore wait
]
