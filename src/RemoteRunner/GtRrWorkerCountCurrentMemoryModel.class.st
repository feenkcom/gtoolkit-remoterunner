Class {
	#name : #GtRrWorkerCountCurrentMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #initialize }
GtRrWorkerCountCurrentMemoryModel >> initialize [

	super initialize.
	requiredMemory := Smalltalk vm memorySize.
]
