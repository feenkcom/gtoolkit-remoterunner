Class {
	#name : #GtRrStompMqTaskCallbackSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'gtMessagePrintString'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrStompMqTaskCallbackSignal >> gtMessagePrintString [
	^ gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqTaskCallbackSignal >> gtMessagePrintString: anObject [
	gtMessagePrintString := anObject
]

{ #category : #printing }
GtRrStompMqTaskCallbackSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		print: gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqTaskCallbackSignal >> signalTypeLabel [

	^ 'GtRrStompMqCallbackSignal'
]
