Class {
	#name : #GtRrRpcResponseMessage,
	#superclass : #GtRrRpcMessage,
	#instVars : [
		'result'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #printing }
GtRrRpcResponseMessage >> printShortStateOn: aStream [ 

	super printShortStateOn: aStream.
	aStream 
		<< ', result=';
		print: result.
]

{ #category : #processing }
GtRrRpcResponseMessage >> processMq: mqMessage processor: aGtRrProcessor for: anObject [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	(aGtRrProcessor removePromiseAt: rpcId) result: result
]

{ #category : #accessing }
GtRrRpcResponseMessage >> result [
	^ result
]

{ #category : #accessing }
GtRrRpcResponseMessage >> result: anObject [
	result := anObject
]
