Class {
	#name : #GtRrDataGroupState,
	#superclass : #Object,
	#instVars : [
		'name',
		'color',
		'items',
		'itemCount',
		'progressNotification'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrDataGroupState class >> forNotification: aNotification [
	^ self new
		progressNotification:  aNotification
]

{ #category : #callbacks }
GtRrDataGroupState >> actOnClickFrom: anElement [
	progressNotification 
		ifNil: [ self defaultActOnClickFrom: anElement ]
		ifNotNil: [ :aNotification |
			aNotification spawnState:  self fromSource: anElement ]
]

{ #category : #accessing }
GtRrDataGroupState >> color [

	^ color
]

{ #category : #accessing }
GtRrDataGroupState >> color: anObject [

	color := anObject
]

{ #category : #callbacks }
GtRrDataGroupState >> defaultActOnClickFrom: anElement [ 
	GtInspectorTool
		openWrappedOn: self  items
		title: self name
		from: anElement
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

{ #category : #accessing }
GtRrDataGroupState >> progressNotification: aNotifications [
	progressNotification := aNotifications
]
