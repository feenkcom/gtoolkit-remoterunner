Class {
	#name : #GtRrTasksGroup,
	#superclass : #Object,
	#traits : 'TGtGroup',
	#classTraits : 'TGtGroup classTrait',
	#instVars : [
		'items'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #'instance creation' }
GtRrTasksGroup class >> withAll: aCollection [
	^ self new
		initializeWith: aCollection
]

{ #category : #initialization }
GtRrTasksGroup >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : #initialization }
GtRrTasksGroup >> initializeWith: aCollection [
	items := aCollection
]

{ #category : #accessing }
GtRrTasksGroup >> items [
	^ items
]
