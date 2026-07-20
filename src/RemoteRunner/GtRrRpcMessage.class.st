Class {
	#name : #GtRrRpcMessage,
	#superclass : #GtRrMessage,
	#instVars : [
		'rpcId'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #printing }
GtRrRpcMessage >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	self printShortStateOn: aStream.
	aStream nextPut: $).
]

{ #category : #printing }
GtRrRpcMessage >> printShortStateOn: aStream [ 

	aStream print: rpcId
]

{ #category : #accessing }
GtRrRpcMessage >> rpcId [
	^ rpcId
]

{ #category : #accessing }
GtRrRpcMessage >> rpcId: anObject [
	rpcId := anObject
]
