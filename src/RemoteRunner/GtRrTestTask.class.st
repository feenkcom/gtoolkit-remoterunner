Class {
	#name : #GtRrTestTask,
	#superclass : #PharoLinkWorkerTask,
	#instVars : [
		'tests',
		'jobUid'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #accessing }
GtRrTestTask class >> leJsonV4Name [

	^ #gtDtsTestTask
]

{ #category : #accessing }
GtRrTestTask class >> tests: aDictionary [

	^ self new
		  tests: aDictionary;
		  yourself
]

{ #category : #accessing }
GtRrTestTask >> run [

	| suite result events |
	suite := TestSuite named: id.
	tests keysAndValuesDo: [ :className :selectors | 
		| class |
		class := className asClass.
		suite addTests: (class buildSuiteFromMethods: selectors) tests ].
	events := OrderedCollection new.
	result := PharoLinkTestResult new.
	result announcer
		when: PharoLinkTestCaseEndAnnouncement
		do: [ :e | events add: e ].
	suite run: result.
	^ events asArray
]

{ #category : #accessing }
GtRrTestTask >> tests [

	^ tests
]

{ #category : #accessing }
GtRrTestTask >> tests: aDictionary [

	tests := aDictionary
]
