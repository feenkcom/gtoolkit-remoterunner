Class {
	#name : #GtRrWorkerCountFixedAvailableMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#instVars : [
		'availableMemory'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountFixedAvailableMemoryModel >> availableMemory [

	availableMemory isNumber ifFalse: [ self error: 'availableMemory not yet set' ].
	^ availableMemory
]

{ #category : #accessing }
GtRrWorkerCountFixedAvailableMemoryModel >> availableMemory: anObject [
	availableMemory := anObject
]

{ #category : #accessing }
GtRrWorkerCountFixedAvailableMemoryModel >> calculationAttributes [

	^ { { '- Available Memory (Fixed)'. self availableMemory humanReadableIsqByteSize. self. } }
]
