Class {
	#name : #GtRrWorkerCountFixedCountAlgorithm,
	#superclass : #GtRrWorkerCountAlgorithm,
	#instVars : [
		'workerCount'
	],
	#category : 'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountFixedCountAlgorithm class >> deSerializeAllImplementorsInstances [
	"Answer a collection of instances to be tested for serialisation / deserialisation"

	^ { self new workerCount: 0 }
]

{ #category : #serialization }
GtRrWorkerCountFixedCountAlgorithm class >> leJsonV4AttributeMapping [
	"The workerCountCalculator will be set when deserialising the calculator"

	^ super leJsonV4AttributeMapping
		add: #workerCount -> #workerCount;
		yourself
]

{ #category : #serialization }
GtRrWorkerCountFixedCountAlgorithm class >> leJsonV4Name [

	^ #gtRrWorkerCountFixedCountAlgorithm
]

{ #category : #ui }
GtRrWorkerCountFixedCountAlgorithm >> calculationAttributes [

	^ { { 'Algorithm'. 'Fixed Count'. self. }.
		{ '- Algorithm Count'. self workerCount. self } }
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	^{	
		'Algorithm Fixed Workers Count' -> self workerCount }
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> value [

	^ self workerCount
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> workerCount [

	workerCount isNumber ifFalse: [ self error: 'workerCount not yet set' ].
	^ workerCount
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> workerCount: anInteger [

	workerCount := anInteger
]
