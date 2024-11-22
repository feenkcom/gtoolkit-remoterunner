Class {
	#name : #GtRrWorkerCountFreeMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#instVars : [
		'availableMemory'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountFreeMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountFreeMemoryModel
]

{ #category : #initialize }
GtRrWorkerCountFreeMemoryModel >> availableMemory [

	^ availableMemory ifNil: [ availableMemory := GtOsSystemInfo current freeMemory ]
]

{ #category : #ui }
GtRrWorkerCountFreeMemoryModel >> calculationAttributes [

	^ { { '- Available Memory (Free)'. self availableMemory humanReadableIsqByteSize. self. } }
]

{ #category : #initialization }
GtRrWorkerCountFreeMemoryModel >> reset [
	"Reset cached run-time parameters, forcing the calculation to be updated."

	availableMemory := nil
]
