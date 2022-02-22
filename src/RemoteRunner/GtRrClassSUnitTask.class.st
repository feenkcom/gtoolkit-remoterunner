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

{ #category : #printing }
GtRrClassSUnitTask >> printSupplementalOn: aStream [

	aStream
		<< (sunitClassName ifNil: [ '<none>' ]);
		<< ', ';
		<< self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #running }
GtRrClassSUnitTask >> run [
	| class suite |

	class := self classWithName: sunitClassName.
	suite := class buildSuite.
	^ self runSuite: suite.
]

{ #category : #accessing }
GtRrClassSUnitTask >> sunitClassName [

	^ sunitClassName
]

{ #category : #accessing }
GtRrClassSUnitTask >> sunitClassName: anObject [

	sunitClassName := anObject
]
