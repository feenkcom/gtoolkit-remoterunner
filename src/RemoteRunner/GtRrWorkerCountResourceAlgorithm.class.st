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

{ #category : #seralization }
GtRrWorkerCountResourceAlgorithm class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		add: #availableMemoryModel -> #availableMemoryModel;
		add: #requiredMemoryModel -> #requiredMemoryModel;
		add: #coreCount -> #coreCount;
		yourself
]

{ #category : #seralization }
GtRrWorkerCountResourceAlgorithm class >> leJsonV4Name [

	^ #gtRrWorkerCountResourceAlgorithm
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> availableMemoryModel [
	^ availableMemoryModel
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> availableMemoryModel: aGtRrWorkerCountAvailableMemoryModel [

	availableMemoryModel := aGtRrWorkerCountAvailableMemoryModel.
	availableMemoryModel workerCountCalculator: workerCountCalculator.
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> calculationAttributes [

	^ Array streamContents: [ :stream |
		stream 
			nextPut: { 'Algorithm'. 'Resource Based'. self. };
			nextPut: { '- Description'. '(Available / Required) min: Cores'. self. };
			nextPutAll: (self availableMemoryModel calculationAttributes);
			nextPutAll: (self requiredMemoryModel calculationAttributes);
			nextPut: { '- Number of Cores'. self coreCount. self. };
			nextPut: { '- Algorithm Count'. self value. self. } ]
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> coreCount [

	^ coreCount ifNil: [ GtOsSystemInfo current numberOfCores ]
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

{ #category : #copying }
GtRrWorkerCountResourceAlgorithm >> postCopy [

	super postCopy.
	availableMemoryModel := availableMemoryModel copy.
	requiredMemoryModel := requiredMemoryModel copy.
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> requiredMemoryModel [
	^ requiredMemoryModel
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> requiredMemoryModel: aGtRrWorkerCountRequiredMemoryModel [

	requiredMemoryModel := aGtRrWorkerCountRequiredMemoryModel.
	requiredMemoryModel workerCountCalculator: workerCountCalculator.
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> value [
	| memoryCount |

	memoryCount := (availableMemoryModel availableMemory / requiredMemoryModel requiredMemory) truncated.
	^ self coreCount min: memoryCount
]

{ #category : #accessing }
GtRrWorkerCountResourceAlgorithm >> workerCountCalculator: aGtRrWorkerCountCalculator [

	super workerCountCalculator: aGtRrWorkerCountCalculator.
	availableMemoryModel ifNotNil: [ availableMemoryModel workerCountCalculator: aGtRrWorkerCountCalculator ].
	requiredMemoryModel ifNotNil: [ requiredMemoryModel workerCountCalculator: aGtRrWorkerCountCalculator ].
]
