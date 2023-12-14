Class {
	#name : #GtRrSummaryLeafNode,
	#superclass : #Object,
	#instVars : [
		'label',
		'value',
		'send'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance creation' }
GtRrSummaryLeafNode class >> label: aString value: valueObject send: sendObject [

	^ self new
		label: aString;
		value: valueObject;
		send: sendObject
]

{ #category : #accessing }
GtRrSummaryLeafNode >> children [

	^ #()
]

{ #category : #accessing }
GtRrSummaryLeafNode >> gtDisplayOn: aStream [

	aStream
		<< (label ifNil: [ '<no label>' ]);
		<< ':  ';
		print: value
]

{ #category : #'as yet unclassified' }
GtRrSummaryLeafNode >> label [
	^ label
]

{ #category : #'as yet unclassified' }
GtRrSummaryLeafNode >> label: anObject [
	label := anObject
]

{ #category : #accessing }
GtRrSummaryLeafNode >> printOn: aStream [

	aStream << 'Leaf: '.
	self gtDisplayOn: aStream
]

{ #category : #'as yet unclassified' }
GtRrSummaryLeafNode >> send [
	^ send
]

{ #category : #'as yet unclassified' }
GtRrSummaryLeafNode >> send: anObject [
	send := anObject
]

{ #category : #accessing }
GtRrSummaryLeafNode >> value [
	^ value
]

{ #category : #'as yet unclassified' }
GtRrSummaryLeafNode >> value: anObject [
	value := anObject
]
