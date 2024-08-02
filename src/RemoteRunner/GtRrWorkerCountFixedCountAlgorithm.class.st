Class {
	#name : #GtRrWorkerCountFixedCountAlgorithm,
	#superclass : #GtRrWorkerCountAlgorithm,
	#instVars : [
		'workerCount'
	],
	#category : #'RemoteRunner-WorkerCount'
}

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
