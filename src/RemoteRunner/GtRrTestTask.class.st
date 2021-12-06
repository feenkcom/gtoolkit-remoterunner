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

	^ self new
		  tests: aDictionary;
		  yourself
]

{ #category : #printing }
GtRrTestTask >> printOn: aStream [
	| grouped |

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: self testCount;
		<< ' tests, '.
	result ifNotNil:
		[ grouped := result groupedBy: #shortName.
		grouped associations do: [ :assoc |
			aStream
				print: assoc value size;
				<< ' ';
				<< assoc key ]
		separatedBy:
			[ aStream << ', ' ] ].
	aStream nextPut: $)
]

{ #category : #accessing }
GtRrTestTask >> run [

	| suite result events |
	suite := TestSuite named: taskId.
	tests keysAndValuesDo: [ :className :selectors | 
		| class |
		class := className asClass.
		suite addTests: (class buildSuiteFromMethods: (selectors collect: #asSymbol)) tests ].
	events := OrderedCollection new.
	result := PharoLinkTestResult new.
	result announcer
		when: PharoLinkTestCaseEndAnnouncement
		do: [ :e | events add: e ].
	suite run: result.
	^ events asArray
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

	tests := aDictionary
]
