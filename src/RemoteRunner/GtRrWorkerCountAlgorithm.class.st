Class {
	#name : #GtRrWorkerCountAlgorithm,
	#superclass : #Object,
	#instVars : [
		'workerCountCalculator'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountAlgorithm >> calculationAttributes [

	^ { { 'Algorithm'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	^ #()
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
