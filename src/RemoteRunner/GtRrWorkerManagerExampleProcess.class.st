"
I stand in for a worker OS process in the {{gtClass:GtRrWorkerManagerExamples}}: the worker manager only asks a process whether it is running and terminates it.
"
Class {
	#name : #GtRrWorkerManagerExampleProcess,
	#superclass : #Object,
	#instVars : [
		'id',
		'isRunning'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrWorkerManagerExampleProcess >> id [

	^ id
]

{ #category : #accessing }
GtRrWorkerManagerExampleProcess >> id: anInteger [

	id := anInteger
]

{ #category : #testing }
GtRrWorkerManagerExampleProcess >> isRunning [

	^ isRunning
]

{ #category : #accessing }
GtRrWorkerManagerExampleProcess >> isRunning: aBoolean [

	isRunning := aBoolean
]

{ #category : #'api - process' }
GtRrWorkerManagerExampleProcess >> terminate [

	isRunning := false
]
