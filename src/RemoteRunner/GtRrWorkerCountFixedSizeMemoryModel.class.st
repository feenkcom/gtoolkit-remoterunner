Class {
	#name : #GtRrWorkerCountFixedSizeMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountFixedSizeMemoryModel >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { '- Required Memory (Fixed Size)'. requiredMemory humanReadableIsqByteSize. self. }. }
]
