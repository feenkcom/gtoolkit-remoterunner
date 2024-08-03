Class {
	#name : #GtRrWorkerCountRequiredMemoryModel,
	#superclass : #Object,
	#instVars : [
		'workerCountCalculator'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountRequiredMemoryModel >> calculationAttributes [

	^ { { '- Required Memory'. ''. self. } }
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> requiredMemory [
	<return: #Integer>

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> workerCountCalculator [
	^ workerCountCalculator
]

{ #category : #accessing }
GtRrWorkerCountRequiredMemoryModel >> workerCountCalculator: anObject [
	workerCountCalculator := anObject
]
