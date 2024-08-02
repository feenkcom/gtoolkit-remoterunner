Class {
	#name : #GtRrWorkerCountCurrentMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountCurrentMemoryModel >> calculationAttributes [

	^ { { '- Required Memory (Current Memory)'. self requiredMemory humanReadableIsqByteSize. self. }. }
]

{ #category : #initialize }
GtRrWorkerCountCurrentMemoryModel >> requiredMemory [

	^ Smalltalk vm memorySize * workerCountCalculator memorySizeMultiplier
]
