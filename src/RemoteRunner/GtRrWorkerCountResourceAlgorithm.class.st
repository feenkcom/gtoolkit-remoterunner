Class {
	#name : #GtRrWorkerCountResourceAlgorithm,
	#superclass : #GtRrWorkerCountAlgorithm,
	#instVars : [
		'availableMemoryModel',
		'requiredMemoryModel'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> availableMemoryModel [
	^ availableMemoryModel
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> availableMemoryModel: anObject [
	availableMemoryModel := anObject
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> initialize [

	super initialize.
	availableMemoryModel := GtRrWorkerCountFreeMemoryModel new.
	requiredMemoryModel := GtRrWorkerCountCurrentMemoryModel new.
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> requiredMemoryModel [
	^ requiredMemoryModel
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> requiredMemoryModel: anObject [
	requiredMemoryModel := anObject
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> value: aGtRrWorkerCountCalculator [
	| coreCount memoryCount |

	coreCount := GtOsSystemInfo current numberOfCores.
	memoryCount := (availableMemoryModel availableMemory / (requiredMemoryModel requiredMemory * aGtRrWorkerCountCalculator memorySizeMultiplier)) truncated.
	^ coreCount min: memoryCount
]
