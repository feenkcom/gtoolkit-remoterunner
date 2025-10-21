Class {
	#name : #GtRrSummaryTreeNode,
	#superclass : #Object,
	#instVars : [
		'node',
		'children'
	],
	#category : 'RemoteRunner-UI'
}

{ #category : #'instance creation' }
GtRrSummaryTreeNode class >> node: anObject children: aCollection [

	^ self new
		node: anObject;
		children: aCollection
]

{ #category : #accessing }
GtRrSummaryTreeNode >> children [
	^ children
]

{ #category : #accessing }
GtRrSummaryTreeNode >> children: anObject [
	children := anObject
]

{ #category : #printing }
GtRrSummaryTreeNode >> gtDisplayOn: aStream [

	^ node
		ifNil: [ super gtDisplayOn: aStream ]
		ifNotNil: [ node gtDisplayOn: aStream ]
]

{ #category : #accessing }
GtRrSummaryTreeNode >> initialize [

	super initialize.
	children := #().
]

{ #category : #accessing }
GtRrSummaryTreeNode >> node [
	^ node
]

{ #category : #accessing }
GtRrSummaryTreeNode >> node: anObject [
	node := anObject
]

{ #category : #printing }
GtRrSummaryTreeNode >> printOn: aStream [

	aStream << 'Node: '.
	self gtDisplayOn: aStream.
]
