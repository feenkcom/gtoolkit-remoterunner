Class {
	#name : #LwGtRrClassTestTask,
	#superclass : #GtRrSUnitTask,
	#instVars : [
		'sunitClassName'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
LwGtRrClassTestTask class >> leJsonV4Name [

	^ #gtRrClassSUnitTask
]

{ #category : #'instance creation' }
LwGtRrClassTestTask class >> sunitClassName: aSymbol [

	^ self new sunitClassName: aSymbol 
]

{ #category : #visiting }
LwGtRrClassTestTask >> acceptVisitor: aVisitor [

	^ aVisitor visitClassSUnitTask: self
]

{ #category : #printing }
LwGtRrClassTestTask >> printSupplementalOn: aStream [

	aStream
		<< (sunitClassName ifNil: [ '<none>' ]);
		<< ', ';
		<< self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #running }
LwGtRrClassTestTask >> run [
	| class suite |

	class := self classWithName: sunitClassName.
	suite := class buildSuite.
	^ self runSuite: suite.
]

{ #category : #accessing }
LwGtRrClassTestTask >> sunitClassName [

	^ sunitClassName
]

{ #category : #accessing }
LwGtRrClassTestTask >> sunitClassName: anObject [

	sunitClassName := anObject
]
