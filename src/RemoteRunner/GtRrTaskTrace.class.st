Class {
	#name : #GtRrTaskTrace,
	#superclass : #GtRrTrace,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Beacon'
}

{ #category : #accessing }
GtRrTaskTrace >> task [

	^ task
]

{ #category : #accessing }
GtRrTaskTrace >> task: anObject [

	task := anObject
]
