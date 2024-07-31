Class {
	#name : #GtRrWorkerCountRequiredMemoryModel,
	#superclass : #Object,
	#instVars : [
		'requiredMemory'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountRequiredMemoryModel >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { '- Required Memory'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> requiredMemory [
	^ requiredMemory
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> requiredMemory: anObject [
	requiredMemory := anObject
]
