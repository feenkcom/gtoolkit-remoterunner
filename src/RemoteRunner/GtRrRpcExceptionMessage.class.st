Class {
	#name : #GtRrRpcExceptionMessage,
	#superclass : #GtRrRpcMessage,
	#instVars : [
		'messageText',
		'stackString',
		'exceptionClassName'
	],
	#category : 'RemoteRunner-Model'
}

{ #category : #'instance creation' }
GtRrRpcExceptionMessage class >> fromException: anException rpcId: aString [

	^ self new
		rpcId: aString;
		exceptionClassName: anException class name;
		messageText: anException messageText;
		stackString: anException stackString.
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> exceptionClassName [
	^exceptionClassName
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> exceptionClassName: anObject [
	exceptionClassName := anObject
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> messageText [
	^messageText
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> messageText: anObject [
	messageText := anObject
]

{ #category : #'as yet unclassified' }
GtRrRpcExceptionMessage >> processMq: mqMessage processor: aGtRrProcessor for: anObject [
	"Process the supplied message for anObject.
	anObject (outside of testing) will either be a GtRrWorker or GtRemoteRunner."

	(aGtRrProcessor removePromiseAt: rpcId)
		exceptionClassName: exceptionClassName;
		messageText: messageText; 
		stackString: stackString;
		processException
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> stackString [
	^ stackString
]

{ #category : #accessing }
GtRrRpcExceptionMessage >> stackString: anObject [
	stackString := anObject
]
