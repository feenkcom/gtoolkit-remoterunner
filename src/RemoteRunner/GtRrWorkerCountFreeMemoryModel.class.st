Class {
	#name : #GtRrWorkerCountFreeMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountFreeMemoryModel >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { '- Available Memory (Free)'. availableMemory humanReadableIsqByteSize. self. } }
]

{ #category : #initialize }
GtRrWorkerCountFreeMemoryModel >> initialize [

	super initialize.
	availableMemory := GtOsSystemInfo current freeMemory.
]
