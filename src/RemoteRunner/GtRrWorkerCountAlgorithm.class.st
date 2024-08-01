Class {
	#name : #GtRrWorkerCountAlgorithm,
	#superclass : #Object,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountAlgorithm >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { 'Algorithm'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	^ #()
]

{ #category : #evaluating }
GtRrWorkerCountAlgorithm >> value: aGtRrWorkerCountCalculator [

	^ self subclassResponsibility
]
