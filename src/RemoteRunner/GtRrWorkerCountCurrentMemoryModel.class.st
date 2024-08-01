Class {
	#name : #GtRrWorkerCountCurrentMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountCurrentMemoryModel >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { '- Required Memory (Current Memory)'. requiredMemory humanReadableIsqByteSize. self. }. }
]

{ #category : #initialize }
GtRrWorkerCountCurrentMemoryModel >> initialize [

	super initialize.
	requiredMemory := Smalltalk vm memorySize.
]
