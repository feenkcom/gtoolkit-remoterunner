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

{ #category : #initialization }
GtRrStompMqTaskCallbackSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 

	super initializeFromTimestamp: aDateAndTime andData: aCollection.
	gtMessagePrintString := aCollection third.
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
