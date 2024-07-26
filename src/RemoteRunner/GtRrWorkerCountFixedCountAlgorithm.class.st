Class {
	#name : #GtRrWorkerCountFixedCountAlgorithm,
	#superclass : #GtRrWorkerCountAlgorithm,
	#instVars : [
		'workerCount'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #initialialize }
GtRrWorkerCountFixedCountAlgorithm >> initialize [

	super initialize.
	workerCount := 2.
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
