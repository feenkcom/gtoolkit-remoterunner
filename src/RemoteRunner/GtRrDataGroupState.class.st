Class {
	#name : #GtRrDataGroupState,
	#superclass : #Object,
	#instVars : [
		'name',
		'color',
		'items',
		'itemCount'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrDataGroupState >> color [

	^ color
]

{ #category : #accessing }
GtRrDataGroupState >> color: anObject [

	color := anObject
]

{ #category : #accessing }
GtRrDataGroupState >> itemCount [

	^ itemCount
]

{ #category : #accessing }
GtRrDataGroupState >> itemCount: anObject [

	itemCount := anObject
]

{ #category : #accessing }
GtRrDataGroupState >> items [

	^ items
]

{ #category : #accessing }
GtRrDataGroupState >> items: aCollection [

	items := aCollection.
	self itemCount ifNil: [
		self itemCount: aCollection size ]
]

{ #category : #accessing }
GtRrDataGroupState >> name [

	^ name
]

{ #category : #accessing }
GtRrDataGroupState >> name: anObject [

	name := anObject
]
