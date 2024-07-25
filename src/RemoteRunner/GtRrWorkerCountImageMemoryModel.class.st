Class {
	#name : #GtRrWorkerCountImageMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #initialize }
GtRrWorkerCountImageMemoryModel >> initialize [

	super initialize.
	requiredMemory := Smalltalk imageFile size.
]
