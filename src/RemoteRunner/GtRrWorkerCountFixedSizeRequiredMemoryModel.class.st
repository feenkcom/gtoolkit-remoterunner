Class {
	#name : #GtRrWorkerCountFixedSizeRequiredMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#instVars : [
		'requiredMemory'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #ui }
GtRrWorkerCountFixedSizeRequiredMemoryModel >> calculationAttributes [

	^ { { '- Required Memory (Fixed Size)'. self requiredMemory humanReadableIsqByteSize. self. }. }
]

{ #category : #accessing }
GtRrWorkerCountFixedSizeRequiredMemoryModel >> requiredMemory [

	requiredMemory isNumber ifFalse: [ self error: 'requiredMemory not yet set' ].
	^ requiredMemory
]

{ #category : #accessing }
GtRrWorkerCountFixedSizeRequiredMemoryModel >> requiredMemory: anObject [
	requiredMemory := anObject
]
