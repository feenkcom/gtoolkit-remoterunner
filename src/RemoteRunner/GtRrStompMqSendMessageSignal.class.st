Class {
	#name : #GtRrStompMqSendMessageSignal,
	#superclass : #GtRemoteRunnerSignal,
	#instVars : [
		'gtMessagePrintString'
	],
	#category : #'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRrStompMqSendMessageSignal >> gtMessagePrintString [
	^gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqSendMessageSignal >> gtMessagePrintString: anObject [
	gtMessagePrintString := anObject
]

{ #category : #printing }
GtRrStompMqSendMessageSignal >> printOneLineContentsOn: aStream [

	super printOneLineContentsOn: aStream.
	aStream
		<< ' | ';
		print: gtMessagePrintString
]

{ #category : #accessing }
GtRrStompMqSendMessageSignal >> signalTypeLabel [

	^ 'GtRrStompMqSendMessageSignal'
]
