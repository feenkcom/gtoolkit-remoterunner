Class {
	#name : #GtRrPackageExampleTask,
	#superclass : #GtRrExamplesTask,
	#instVars : [
		'examplePackageName'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #'instance creation' }
GtRrPackageExampleTask class >> examplePackageName: aString [

	^ self new examplePackageName: aString
]

{ #category : #accessing }
GtRrPackageExampleTask class >> leJsonV4Name [

	^ #gtRrPackageExampleTask
]

{ #category : #visiting }
GtRrPackageExampleTask >> acceptVisitor: aVisitor [

	^ aVisitor visitPackageExampleTask: self
]

{ #category : #accessing }
GtRrPackageExampleTask >> examplePackageName [

	^ examplePackageName
]

{ #category : #accessing }
GtRrPackageExampleTask >> examplePackageName: anObject [

	examplePackageName := anObject
]

{ #category : #'private - running' }
GtRrPackageExampleTask >> group [
	| exampleClasses allExamples |

	exampleClasses := examplePackageName asPackage definedClasses reject: [ :aClass | 
			aClass isAbstract or: [ aClass isTrait ] ].
	allExamples := exampleClasses flatCollect: [ :cls |
		GtExampleFactory new
			sourceClass: cls;
			gtExamplesAllContained ].
	^ GtPackageExampleGroup new examples: allExamples.
]

{ #category : #printing }
GtRrPackageExampleTask >> printSupplementalOn: aStream [

	aStream
		<< (examplePackageName ifNil: [ '<none>' ]);
		<< ', ';
		<< self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].

]
