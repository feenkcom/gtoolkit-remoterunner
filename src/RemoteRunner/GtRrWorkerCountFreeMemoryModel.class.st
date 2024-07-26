Class {
	#name : #GtRrWorkerCountFreeMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #initialize }
GtRrWorkerCountFreeMemoryModel >> initialize [

	super initialize.
	availableMemory := GtOsSystemInfo current freeMemory.
]
