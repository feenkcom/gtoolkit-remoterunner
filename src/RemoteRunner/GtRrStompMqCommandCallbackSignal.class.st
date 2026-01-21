Class {
	#name : #GtRrStompMqCommandCallbackSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'gtMessagePrintString'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrStompMqCommandCallbackSignal >> gtMessagePrintString [
	^ gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqCommandCallbackSignal >> gtMessagePrintString: anObject [
	gtMessagePrintString := anObject
]

{ #category : #printing }
GtRrStompMqCommandCallbackSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		print: gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqCommandCallbackSignal >> signalTypeLabel [

	^ 'GtRrStompMqCallbackSignal'
]
