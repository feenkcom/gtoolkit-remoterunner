Class {
	#name : #GtRrMqPromiseTimeout,
	#superclass : #Object,
	#instVars : [
		'timeout'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrMqPromiseTimeout >> timeout [
	^ timeout
]

{ #category : #accessing }
GtRrMqPromiseTimeout >> timeout: anObject [
	timeout := anObject
]
