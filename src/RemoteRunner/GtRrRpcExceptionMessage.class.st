Class {
	#name : #GtRrRpcExceptionMessage,
	#superclass : #GtRrRpcMessage,
	#instVars : [
		'exception',
		'stackString'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrRpcExceptionMessage >> exception [
	^ exception
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> exception: anObject [
	exception := anObject
]

{ #category : #'as yet unclassified' }
GtRrRpcExceptionMessage >> processMq: mqMessage processor: aGtRrProcessor for: anObject [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	(aGtRrProcessor removePromiseAt: rpcId) 
		stackString: stackString;
		exception: exception
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> stackString [
	^ stackString
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> stackString: anObject [
	stackString := anObject
]
