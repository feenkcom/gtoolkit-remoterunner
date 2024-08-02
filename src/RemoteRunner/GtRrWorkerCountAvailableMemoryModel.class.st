"
Subclasses of GtRrWorkerCountMemoryModel determines the memory size to use during worker count calculations.
"
Class {
	#name : #GtRrWorkerCountAvailableMemoryModel,
	#superclass : #Object,
	#instVars : [
		'workerCountCalculator'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> availableMemory [
	^ self subclassResponsibility
]

{ #category : #ui }
GtRrWorkerCountAvailableMemoryModel >> calculationAttributes [

	^ { { '- Available Memory'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> workerCountCalculator [
	^ workerCountCalculator
]

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> workerCountCalculator: anObject [
	workerCountCalculator := anObject
]
