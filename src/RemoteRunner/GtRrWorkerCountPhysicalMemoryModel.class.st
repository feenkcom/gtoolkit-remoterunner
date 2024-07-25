Class {
	#name : #GtRrWorkerCountPhysicalMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #initialize }
GtRrWorkerCountPhysicalMemoryModel >> initialize [

	super initialize.
	availableMemory := GtOsSystemInfo current physicalMemory.
]
