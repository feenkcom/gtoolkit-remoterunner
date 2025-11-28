Class {
	#name : #GtRrWorkerRegisterMessage,
	#superclass : #GtRrWorkerMessage,
	#instVars : [
		'attributes'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrWorkerRegisterMessage >> attributes [
	^ attributes
]

{ #category : #accessing }
GtRrWorkerRegisterMessage >> attributes: anObject [
	attributes := anObject
]

{ #category : #'as yet unclassified' }
GtRrWorkerRegisterMessage >> processMq: mqMessage processor: aGtRrProcessor for: aGtRrMqServer [

	^ aGtRrMqServer remoteRunner registerWorkerWithDetails: attributes controlChannelAvailable: true.
]
