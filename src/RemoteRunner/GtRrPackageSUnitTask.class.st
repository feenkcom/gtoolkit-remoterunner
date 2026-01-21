Class {
	#name : #GtRrPackageSUnitTask,
	#superclass : #GtRrSUnitTask,
	#instVars : [
		'sunitPackageName'
	],
	#category : 'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrPackageSUnitTask class >> leJsonV4Name [

	^ #gtRrPackageSUnitTask
]

{ #category : #'instance creation' }
GtRrPackageSUnitTask class >> sunitPackageName: aSymbol [

	^ self new sunitPackageName: aSymbol 
]

{ #category : #visiting }
GtRrPackageSUnitTask >> acceptVisitor: aVisitor [

	^ aVisitor visitPackageSUnitTask: self
]

{ #category : #printing }
GtRrPackageSUnitTask >> printSupplementalOn: aStream [

	aStream
		<< (sunitPackageName ifNil: [ '<none>' ]);
		<< ', ';
		<< self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]

{ #category : #accessing }
GtRrPackageSUnitTask >> sunitPackageName [

	^ sunitPackageName
]

{ #category : #accessing }
GtRrPackageSUnitTask >> sunitPackageName: anObject [

	sunitPackageName := anObject
]

{ #category : #accessing }
GtRrPackageSUnitTask >> testSuite [
	| suite classes |

	suite := GtRrTestSuite named: taskId.
	classes := sunitPackageName asPackage classes select: [ :cls |
		(cls inheritsFrom: TestCase) and: [ cls isAbstract not ] ].
	classes do: [ :cls |
		suite addTests: cls buildSuiteFromSelectors tests ].
	^ suite.
]
