Class {
	#name : #GtRrExamplesMessageRecorder,
	#superclass : #Object,
	#instVars : [
		'messages'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrExamplesMessageRecorder >> doesNotUnderstand: aMessage [

	messages add: aMessage.
]

{ #category : #accessing }
GtRrExamplesMessageRecorder >> initialize [

	super initialize.
	messages := OrderedCollection new.
]

{ #category : #accessing }
GtRrExamplesMessageRecorder >> messages [

	^ messages
]
