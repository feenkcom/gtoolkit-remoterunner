"
Subclasses of GtRrWorkerCountMemoryModel determines the memory size to use during worker count calculations.
"
Class {
	#name : #GtRrWorkerCountAvailableMemoryModel,
	#superclass : #Object,
	#instVars : [
		'workerCountCalculator'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountAvailableMemoryModel class >> leJsonV4AttributeMapping [
	"The workerCountCalculator will be set when deserialising the calculator"

	^ OrderedCollection new
]

{ #category : #serialization }
GtRrWorkerCountAvailableMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountAvailableMemoryModel
]

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> availableMemory [
	<return: #Integer>

	^ self subclassResponsibility
]

{ #category : #ui }
GtRrWorkerCountAvailableMemoryModel >> calculationAttributes [

	^ { { '- Available Memory'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> workerCountCalculator [
	^ workerCountCalculator
]

{ #category : #accessing }
GtRrWorkerCountAvailableMemoryModel >> workerCountCalculator: anObject [
	workerCountCalculator := anObject
]
