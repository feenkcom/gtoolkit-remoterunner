Class {
	#name : #GtRrWorkerCountImageMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#instVars : [
		'additionalOldSpace'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> additionalOldSpace [
	^ additionalOldSpace
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> additionalOldSpace: anInteger [

	additionalOldSpace := anInteger.
	requiredMemory := Smalltalk imageFile size + additionalOldSpace.
]

{ #category : #initialize }
GtRrWorkerCountImageMemoryModel >> initialize [

	super initialize.
	self additionalOldSpace: Smalltalk imageFile size.
]
