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
