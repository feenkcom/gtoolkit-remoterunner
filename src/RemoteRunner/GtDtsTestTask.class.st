Class {
	#name : #GtDtsTestTask,
	#superclass : #PharoLinkWorkerTask,
	#instVars : [
		'tests'
	],
	#category : #'RemoteRunner-DistributedTesting'
}

{ #category : #accessing }
GtDtsTestTask class >> leJsonV4Name [

	^ #gtDtsTestTask
]

{ #category : #accessing }
GtDtsTestTask class >> tests: aDictionary [

	^ self new
		  tests: aDictionary;
		  yourself
]

{ #category : #accessing }
GtDtsTestTask >> run [

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
GtDtsTestTask >> tests [

	^ tests
]

{ #category : #accessing }
GtDtsTestTask >> tests: aDictionary [

	tests := aDictionary
]
