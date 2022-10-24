Class {
	#name : #GtRrClassSUnitTask,
	#superclass : #GtRrSUnitTask,
	#instVars : [
		'sunitClassName'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrClassSUnitTask class >> leJsonV4Name [

	^ #gtRrClassSUnitTask
]

{ #category : #'instance creation' }
GtRrClassSUnitTask class >> sunitClassName: aSymbol [

	^ self new sunitClassName: aSymbol 
]

{ #category : #visiting }
GtRrClassSUnitTask >> acceptVisitor: aVisitor [

	^ aVisitor visitClassSUnitTask: self
]

{ #category : #printing }
GtRrClassSUnitTask >> printSupplementalOn: aStream [

	aStream
		<< (sunitClassName ifNil: [ '<none>' ]);
		<< ', ';
		<< self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #accessing }
GtRrClassSUnitTask >> sunitClassName [

	^ sunitClassName
]

{ #category : #accessing }
GtRrClassSUnitTask >> sunitClassName: anObject [

	sunitClassName := anObject
]

{ #category : #accessing }
GtRrClassSUnitTask >> testSuite [

	^ (self classWithName: sunitClassName) buildSuite.

]
