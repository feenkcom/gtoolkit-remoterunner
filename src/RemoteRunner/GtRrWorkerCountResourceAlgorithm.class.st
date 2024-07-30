Class {
	#name : #GtRrWorkerCountResourceAlgorithm,
	#superclass : #GtRrWorkerCountAlgorithm,
	#instVars : [
		'availableMemoryModel',
		'requiredMemoryModel',
		'coreCount'
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
GtRrWorkerCountResourceAlgorithm >> coreCount [

	^ coreCount ifNil: [ coreCount := GtOsSystemInfo current numberOfCores ]
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> coreCount: anObject [
	coreCount := anObject
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> initialize [

	super initialize.
	availableMemoryModel := GtRrWorkerCountFreeMemoryModel new.
	requiredMemoryModel := GtRrWorkerCountCurrentMemoryModel new.
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	| computedRequiredMemory |
	computedRequiredMemory := self requiredMemoryModel requiredMemory.
	^
	{'Algorithm Available VM Memory'
		-> self availableMemoryModel availableMemory humanReadableSISizeString.
	'Algorithm Required VM Memory' -> computedRequiredMemory asInteger humanReadableSISizeString.
	'Algorithm VM Multiplied Memory'
		-> (computedRequiredMemory * aGtRrWorkerCountCalculator  memorySizeMultiplier)
				asInteger humanReadableSISizeString}
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
	| memoryCount |

	memoryCount := (availableMemoryModel availableMemory / (requiredMemoryModel requiredMemory * aGtRrWorkerCountCalculator memorySizeMultiplier)) truncated.
	^ self coreCount min: memoryCount
]
