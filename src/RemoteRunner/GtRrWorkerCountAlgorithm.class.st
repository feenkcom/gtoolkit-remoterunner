Class {
	#name : #GtRrWorkerCountAlgorithm,
	#superclass : #Object,
	#instVars : [
		'workerCountCalculator'
	],
	#category : 'RemoteRunner-WorkerCount'
}

{ #category : #serialization }
GtRrWorkerCountAlgorithm class >> leJsonV4AttributeMapping [
	"The workerCountCalculator will be set when deserialising the calculator"

	^ OrderedCollection new
]

{ #category : #serialization }
GtRrWorkerCountAlgorithm class >> leJsonV4Name [

	^ #gtRrWorkerCountAlgorithm
]

{ #category : #ui }
GtRrWorkerCountAlgorithm >> calculationAttributes [

	^ { { 'Algorithm'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	^ #()
]

{ #category : #initialization }
GtRrWorkerCountAlgorithm >> reset [
	"Reset cached run-time parameters, forcing the calculation to be updated.
	Subclasses should overwrite as required."
]

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> value [
	"Answer the calculated number of workers based solely on the receiver's algorithm.
	This will be modified by the calculator."

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> workerCountCalculator [
	^ workerCountCalculator
]

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> workerCountCalculator: anObject [
	workerCountCalculator := anObject
]
