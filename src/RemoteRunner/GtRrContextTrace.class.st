Class {
	#name : #GtRrContextTrace,
	#superclass : #GtRrTrace,
	#instVars : [
		'context'
	],
	#category : #'RemoteRunner-Beacon'
}

{ #category : #accessing }
GtRrContextTrace >> context [

	^ context
]

{ #category : #accessing }
GtRrContextTrace >> context: anObject [

	context := anObject
]
