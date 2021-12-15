Class {
	#name : #GtRrObjectTrace,
	#superclass : #GtRrTrace,
	#instVars : [
		'object'
	],
	#category : #'RemoteRunner-Beacon'
}

{ #category : #accessing }
GtRrObjectTrace >> object [

	^ object
]

{ #category : #accessing }
GtRrObjectTrace >> object: anObject [

	object := anObject
]
