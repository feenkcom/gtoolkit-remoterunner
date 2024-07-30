Class {
	#name : #GtRrWorkerCountAlgorithm,
	#superclass : #Object,
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	^ #()
]

{ #category : #evaluating }
GtRrWorkerCountAlgorithm >> value: aGtRrWorkerCountCalculator [

	^ self subclassResponsibility
]
