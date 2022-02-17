Class {
	#name : #GtRrTestTask,
	#superclass : #GtRrTask,
	#instVars : [
		'tests'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrTestTask class >> leJsonV4Name [

	^ #gtRrTestTask
]

{ #category : #accessing }
GtRrTestTask class >> tests: aDictionary [
	"Answer a task with the supplied tests. The dictionary is:
		key: #TesteClassName
		value: Array of #selector"
	^ self new
		  tests: aDictionary;
		  yourself
]

{ #category : #'accessing - dynamic' }
GtRrTestTask >> erroredExamples [

	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 
			pharoLinkTestCaseAnnouncement shortName = #error or:
			[ pharoLinkTestCaseAnnouncement shortName = #warning ] ]

]

{ #category : #'accessing - dynamic' }
GtRrTestTask >> executedExamples [

	^ result
]

{ #category : #'accessing - dynamic' }
GtRrTestTask >> failedExamples [

	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 	pharoLinkTestCaseAnnouncement shortName = #failure ]

]

{ #category : #'gt-extensions' }
GtRrTestTask >> gtResultFor: aView [
	<gtView>

	^ aView list
		  title: 'Tests';
		  priority: 20;
		 	items: [ result ifNil: [ { errorDetails ifNil: [ '<No Result>' ] } ] ];
		  actionUpdateButton
]

{ #category : #printing }
GtRrTestTask >> printOn: aStream [
	| grouped |

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: self testCount;
		<< ' tests'.
	result ifNotNil:
		[ aStream << ', '.
		grouped := result groupedBy: #shortName.
		grouped associations do: [ :assoc |
			aStream
				print: assoc value size;
				<< ' ';
				<< assoc key ]
		separatedBy:
			[ aStream << ', ' ] ].
	aStream nextPut: $)
]

{ #category : #running }
GtRrTestTask >> run [
	| suite testResult events |

	suite := TestSuite named: taskId.
	tests keysAndValuesDo: [ :className :selectors | 
		| class |
		class := className asClass.
		suite addTests: (class buildSuiteFromMethods: (selectors collect: #asSymbol)) tests ].
	events := OrderedCollection new.
	testResult := PharoLinkTestResult new.
	testResult announcer
		when: PharoLinkTestCaseEndAnnouncement
		do: [ :e | events add: e ].
	suite run: testResult.
	^ events asArray
]

{ #category : #'accessing - dynamic' }
GtRrTestTask >> skippedExamples [

	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 	pharoLinkTestCaseAnnouncement shortName = #skip ]

]

{ #category : #'accessing - dynamic' }
GtRrTestTask >> successfulExamples [

	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 
			#(#pass #skip) includes: pharoLinkTestCaseAnnouncement shortName ]

]

{ #category : #ui }
GtRrTestTask >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ super summaryAttributes
		add: 'Test Count:' -> self testCount;
		yourself.
]

{ #category : #accessing }
GtRrTestTask >> testCount [
	"Answer the number of tests"

	tests ifNil: [ ^ 0 ].
	^ tests inject: 0 into: [ :sum :selectors | sum + selectors size ]

]

{ #category : #accessing }
GtRrTestTask >> tests [

	^ tests
]

{ #category : #accessing }
GtRrTestTask >> tests: aDictionary [
	"The dictionary is:
		key: #TesteClassName
		value: Array of #selector"

	self assert: [ aDictionary keys allSatisfy: #isString ].
	self assert: [ aDictionary values allSatisfy: [ :each | each isSequenceable and:
			[ each allSatisfy: #isString ] ] ].
	tests := aDictionary
]
