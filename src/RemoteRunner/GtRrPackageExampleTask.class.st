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

	^ GtPackageExampleGroup new examplePackage: examplePackageName asPackage.
]
