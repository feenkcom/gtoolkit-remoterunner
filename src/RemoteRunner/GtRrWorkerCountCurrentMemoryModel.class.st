Class {
	#name : #GtRrWorkerCountCurrentMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountCurrentMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountCurrentMemoryModel
]

{ #category : #ui }
GtRrWorkerCountCurrentMemoryModel >> calculationAttributes [

	^ { { '- Required Memory (Current Memory)'. self requiredMemory humanReadableIsqByteSize. self. }. }
]

{ #category : #initialize }
GtRrWorkerCountCurrentMemoryModel >> requiredMemory [
	<return: #Integer>

	^ (Smalltalk vm memorySize * workerCountCalculator memorySizeMultiplier) rounded
]
