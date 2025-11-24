Class {
	#name : #GtRrWorkerCountFixedSizeRequiredMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#instVars : [
		'requiredMemory'
	],
	#category : 'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountFixedSizeRequiredMemoryModel class >> deSerializeAllImplementorsInstances [
	"Answer a collection of instances to be tested for serialisation / deserialisation"

	^ { self new requiredMemory: 0 }
]

{ #category : #serialization }
GtRrWorkerCountFixedSizeRequiredMemoryModel class >> leJsonV4AttributeMapping [
	"The workerCountCalculator will be set when deserialising the calculator"

	^ super leJsonV4AttributeMapping
		add: #requiredMemory -> #requiredMemory;
		yourself.
]

{ #category : #serialization }
GtRrWorkerCountFixedSizeRequiredMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountFixedSizeRequiredMemoryModel
]

{ #category : #ui }
GtRrWorkerCountFixedSizeRequiredMemoryModel >> calculationAttributes [

	^ { { '- Required Memory (Fixed Size)'. self requiredMemory humanReadableIsqByteSize. self. }. }
]

{ #category : #accessing }
GtRrWorkerCountFixedSizeRequiredMemoryModel >> requiredMemory [

	requiredMemory isNumber ifFalse: [ self error: 'requiredMemory not yet set' ].
	^ requiredMemory
]

{ #category : #accessing }
GtRrWorkerCountFixedSizeRequiredMemoryModel >> requiredMemory: anObject [
	requiredMemory := anObject
]
