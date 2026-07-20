Class {
	#name : #GtRrWorkerCountPhysicalMemoryModel,
	#superclass : #GtRrWorkerCountAvailableMemoryModel,
	#instVars : [
		'availableMemory'
	],
	#category : 'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountPhysicalMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountPhysicalMemoryModel
]

{ #category : #initialize }
GtRrWorkerCountPhysicalMemoryModel >> availableMemory [

	^ availableMemory ifNil: [ availableMemory := GtOsSystemInfo current physicalMemory ]
]

{ #category : #ui }
GtRrWorkerCountPhysicalMemoryModel >> calculationAttributes [

	^ { { '- Available Memory (Physical)'. self availableMemory humanReadableIsqByteSize. self. } }
]

{ #category : #initialization }
GtRrWorkerCountPhysicalMemoryModel >> reset [
	"Reset cached run-time parameters, forcing the calculation to be updated."

	availableMemory := nil
]
