Class {
	#name : #GtRrStompMqCallbackSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'gtMessagePrintString'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrStompMqCallbackSignal >> gtMessagePrintString [
	^ gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqCallbackSignal >> gtMessagePrintString: anObject [
	gtMessagePrintString := anObject
]

{ #category : #printing }
GtRrStompMqCallbackSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		print: gtMessagePrintString
]

{ #category : #'as yet unclassified' }
GtRrStompMqCallbackSignal >> signalTypeLabel [

	^ 'GtRrStompMqCallbackSignal'
]
