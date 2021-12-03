"
A GtRrFutureWorkerTask is created each time a worker calls in to the runner indicating it is waiting for its next task.

Once the task is assigned to the worker, the semaphore is signalled and the task returned to the worker.
"
Class {
	#name : #GtRrFutureWorkerTask,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'task',
		'platform',
		'workerId'
	],
	#category : #'RemoteRunner-Model'
}

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
GtRrFutureWorkerTask >> task [

	^ task
]

{ #category : #accessing }
GtRrFutureWorkerTask >> task: aGtRrTask [

	task := aGtRrTask.
	semaphore signal.
]

{ #category : #'api - future' }
GtRrFutureWorkerTask >> wait [

	semaphore wait
]

{ #category : #accessing }
GtRrFutureWorkerTask >> workerId [

	^ workerId
]

{ #category : #accessing }
GtRrFutureWorkerTask >> workerId: anObject [

	workerId := anObject
]
