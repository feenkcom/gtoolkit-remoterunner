Class {
	#name : #GtRrWorkerCountRequiredMemoryModel,
	#superclass : #Object,
	#instVars : [
		'workerCountCalculator'
	],
	#category : 'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountRequiredMemoryModel class >> leJsonV4AttributeMapping [
	"The workerCountCalculator will be set when deserialising the calculator"

	^ OrderedCollection new
]

{ #category : #serialization }
GtRrWorkerCountRequiredMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountRequiredMemoryModel
]

{ #category : #ui }
GtRrWorkerCountRequiredMemoryModel >> calculationAttributes [

	^ { { '- Required Memory'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> requiredMemory [
	<return: #Integer>

	^ self subclassResponsibility
]

{ #category : #initialization }
GtRrWorkerCountRequiredMemoryModel >> reset [
	"Reset cached run-time parameters, forcing the calculation to be updated.
	Subclasses should overwrite as required."
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> workerCountCalculator [
	^ workerCountCalculator
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> workerCountCalculator: anObject [
	workerCountCalculator := anObject
]
