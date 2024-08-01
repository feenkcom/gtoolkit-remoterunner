Class {
	#name : #GtRrWorkerCountFixedCountAlgorithm,
	#superclass : #GtRrWorkerCountAlgorithm,
	#instVars : [
		'workerCount'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountFixedCountAlgorithm >> calculationAttributesWith: aGtRrWorkerCountCalculator [

	^ { { 'Algorithm'. 'Fixed Count'. self. }.
		{ '- Algorithm Count'. self workerCount. self } }
]

{ #category : #initialialize }
GtRrWorkerCountFixedCountAlgorithm >> initialize [

	super initialize.
	workerCount := 2.
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> parameterDetailsWithCalculator: aGtRrWorkerCountCalculator [
	^{	
		'Algorithm Fixed Workers Count' -> self workerCount }
]

{ #category : #evaluating }
GtRrWorkerCountFixedCountAlgorithm >> value: aGtRrWorkerCountCalcaulator [
	"Answer the number of workers to start.
	Note that the calculator will override this value with min or max workers."

	^ workerCount
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> workerCount [
	^ workerCount
]

{ #category : #accessing }
GtRrWorkerCountFixedCountAlgorithm >> workerCount: anInteger [

	workerCount := anInteger
]
