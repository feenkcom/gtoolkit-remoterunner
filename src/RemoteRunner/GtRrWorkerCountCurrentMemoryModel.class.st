Class {
	#name : #GtRrWorkerCountCurrentMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#instVars : [
		'requiredMemory'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountCurrentMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountCurrentMemoryModel
]

{ #category : #ui }
GtRrWorkerCountCurrentMemoryModel >> calculationAttributes [

	^ { { '- Required Memory (Current Memory)'. self requiredMemory humanReadableIsqByteSize. self. }. }
]

{ #category : #initialize }
GtRrWorkerCountCurrentMemoryModel >> requiredMemory [
	<return: #Integer>

	^ requiredMemory ifNil: [ requiredMemory := 
		(Smalltalk vm memorySize * workerCountCalculator memorySizeMultiplier) rounded ]
]

{ #category : #initialization }
GtRrWorkerCountCurrentMemoryModel >> reset [
	"Reset cached run-time parameters, forcing the calculation to be updated."

	requiredMemory := nil
]
