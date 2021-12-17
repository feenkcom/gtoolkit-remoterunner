Class {
	#name : #GtRrJobTrace,
	#superclass : #GtRrTrace,
	#instVars : [
		'job'
	],
	#category : #'RemoteRunner-Beacon'
}

{ #category : #accessing }
GtRrJobTrace >> job [

	^ job
]

{ #category : #accessing }
GtRrJobTrace >> job: anObject [

	job := anObject
]
