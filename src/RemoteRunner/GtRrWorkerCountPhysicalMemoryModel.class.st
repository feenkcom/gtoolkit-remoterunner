Class {
	#name : #GtRrWorkerCountPhysicalMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountPhysicalMemoryModel >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { '- Available Memory (Physical)'. availableMemory humanReadableIsqByteSize. self. } }
]

{ #category : #initialize }
GtRrWorkerCountPhysicalMemoryModel >> initialize [

	super initialize.
	availableMemory := GtOsSystemInfo current physicalMemory.
]
