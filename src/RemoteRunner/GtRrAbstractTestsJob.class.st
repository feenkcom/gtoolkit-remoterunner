Class {
	#name : #GtRrAbstractTestsJob,
	#superclass : #GtRrAllocatedItemsJob,
	#instVars : [
		'packageNames',
		'classNames',
		'testNames'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #jsonV3 }
GtRrAbstractTestsJob class >> leJsonV4AttributeMapping [ 

	^ super leJsonV4AttributeMapping 
		add: #packageNames -> #packageNames;
		add: #classNames -> #classNames;
		add: #testNames -> #testNames;
		yourself.
]

{ #category : #accessing }
GtRrAbstractTestsJob >> classNames [
	<return: #Array of: #Symbol>

	^ classNames
]

{ #category : #accessing }
GtRrAbstractTestsJob >> classNames: anObject [

	classNames := anObject
]

{ #category : #ui }
GtRrAbstractTestsJob >> gtRrTestsFor: aView [
	<gtView>

	^ aView list
		title: 'Test Results';
		priority: 12;
		items: [ self testResults];
		updateWhen: GtRrJobAnnouncement in: [ self announcer ].
]

{ #category : #initialization }
GtRrAbstractTestsJob >> initialize [

	super initialize.
	packageNames := #().
	classNames := #().
	testNames := #().

]

{ #category : #accessing }
GtRrAbstractTestsJob >> packageNames [
	<return: #Array of: #String>

	^ packageNames
]

{ #category : #accessing }
GtRrAbstractTestsJob >> packageNames: anObject [

	packageNames := anObject
]

{ #category : #accessing }
GtRrAbstractTestsJob >> testNames [
	"Answer the collection of test names.
	Each test name is #ClassName -> #testSelector"
	<return: #Array of: #Association>
	
	^ testNames
]

{ #category : #accessing }
GtRrAbstractTestsJob >> testNames: anObject [

	testNames := anObject
]

{ #category : #accessing }
GtRrAbstractTestsJob >> testResults [
	"Collect all the results from the receiver's tests in to a single collection"

	^ results
		ifNil: [ #() ]
		ifNotNil: [ Array streamContents: [ :stream |
			results do: [ :each | each result do:
				[ :result | stream nextPut: result ] ] ] ] 
]
