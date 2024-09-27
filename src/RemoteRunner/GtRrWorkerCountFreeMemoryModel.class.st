Class {
	#name : #GtRrWorkerCountFreeMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountFreeMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountFreeMemoryModel
]

{ #category : #initialize }
GtRrWorkerCountFreeMemoryModel >> availableMemory [

	^ GtOsSystemInfo current freeMemory
]

{ #category : #ui }
GtRrWorkerCountFreeMemoryModel >> calculationAttributes [

	^ { { '- Available Memory (Free)'. self availableMemory humanReadableIsqByteSize. self. } }
]
