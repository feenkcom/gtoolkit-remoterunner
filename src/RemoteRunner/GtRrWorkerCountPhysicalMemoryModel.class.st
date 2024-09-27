Class {
	#name : #GtRrWorkerCountPhysicalMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountPhysicalMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountPhysicalMemoryModel
]

{ #category : #initialize }
GtRrWorkerCountPhysicalMemoryModel >> availableMemory [

	^ GtOsSystemInfo current physicalMemory
]

{ #category : #ui }
GtRrWorkerCountPhysicalMemoryModel >> calculationAttributes [

	^ { { '- Available Memory (Physical)'. self availableMemory humanReadableIsqByteSize. self. } }
]
