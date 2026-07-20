Class {
	#name : #GtRrRpcRequestMessage,
	#superclass : #GtRrRpcMessage,
	#instVars : [
		'evaluationMessage',
		'responseQueue'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrRpcRequestMessage >> evaluationMessage [
	^ evaluationMessage
]

{ #category : #accessing }
GtRrRpcRequestMessage >> evaluationMessage: anObject [
	evaluationMessage := anObject
]

{ #category : #'as yet unclassified' }
GtRrRpcRequestMessage >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: rpcId;
		<< ', eval=';
		print: evaluationMessage;
		<< ', resp=';
		print: responseQueue;
		nextPut: $).
]

{ #category : #processing }
GtRrRpcRequestMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	[ evaluationMessage processMq: mqMessage processor: aGtRrProcessor for: anOwner ] asAsyncPromise
		then: [ :result |
			aGtRrProcessor sendGtMessage: (GtRrRpcResponseMessage new
				rpcId: rpcId;
				result: result)
					to: responseQueue ]
		otherwise: [ :ex |
			aGtRrProcessor 
				sendGtMessage: (GtRrRpcExceptionMessage 
					fromException: ex
					rpcId: rpcId)
				to: responseQueue ]
]

{ #category : #accessing }
GtRrRpcRequestMessage >> responseQueue [
	^ responseQueue
]

{ #category : #accessing }
GtRrRpcRequestMessage >> responseQueue: anObject [
	responseQueue := anObject
]
