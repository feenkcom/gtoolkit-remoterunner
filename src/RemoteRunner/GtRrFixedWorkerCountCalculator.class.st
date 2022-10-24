"
GtFixedWorkerCountCalculator answers a fixed number of workers to start.
"
Class {
	#name : #GtRrFixedWorkerCountCalculator,
	#superclass : #GtRrWorkerCountCalculator,
	#instVars : [
		'workerCount'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #'instance creation' }
GtRrFixedWorkerCountCalculator class >> workerCount: anInteger [

	^ self new workerCount: anInteger
]

{ #category : #initialization }
GtRrFixedWorkerCountCalculator >> initialize [

	super initialize.
	workerCount := 2.
]

{ #category : #accessing }
GtRrFixedWorkerCountCalculator >> workerCount [

	^ workerCount
]

{ #category : #accessing }
GtRrFixedWorkerCountCalculator >> workerCount: anObject [

	workerCount := anObject
]
