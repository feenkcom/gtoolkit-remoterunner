"
Subclasses of GtRrWorkerCountMemoryModel determines the memory size to use during worker count calculations.
"
Class {
	#name : #GtRrWorkerCountAvailableMemoryModel,
	#superclass : #Object,
	#instVars : [
		'availableMemory'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> availableMemory [
	^ availableMemory
]

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> availableMemory: anObject [
	availableMemory := anObject
]

{ #category : #ui }
GtRrWorkerCountAvailableMemoryModel >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { '- Available Memory'. ''. self. } }
]
