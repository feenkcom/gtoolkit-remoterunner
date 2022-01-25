Class {
	#name : #GtRrTestsJob,
	#superclass : #GtRrJob,
	#instVars : [
		'testNames',
		'classNames',
		'packageNames'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #private }
GtRrTestsJob >> allFailedTests [
	"Answer all tests that failed (Fail or Error)"

	results ifNil: [ ^ #() ].
	^ Array streamContents: [ :stream |
		results do: [ :task |
			(task result ifNil: [ #() ]) do: [ :test |
				test shortName = #pass ifFalse:
					[ stream nextPut: test ] ] ] ]
]

{ #category : #accessing }
GtRrTestsJob >> allItems [
	| allTests |

	allTests := OrderedCollection new.
	allTests addAll: testNames.
	classNames do: [ :className |
		className asClass testSelectors do: [ :selector |
			allTests add: className -> selector ] ].
	packageNames do: [ :packageName |
		packageName asPackage classes 
			select: [ :cls | cls isTestCase and: [ cls isAbstract not ] ]
			thenDo: [ :cls | cls testSelectors do: [ :selector |
				allTests add: cls name -> selector ] ] ].

	^ allTests
]

{ #category : #accessing }
GtRrTestsJob >> classNames [
	<return: #Array of: #Symbol>

	^ classNames
]

{ #category : #accessing }
GtRrTestsJob >> classNames: anObject [

	classNames := anObject
]

{ #category : #accessing }
GtRrTestsJob >> failedTestCount [
	"Answer a count of the tests that failed (Fail or Error)"
	| count |

	count := 0.
	results ifNil: [ ^ count ].
	results do: [ :task | 
		(task result ifNil: [ #(  ) ]) do: [ :test | 
			test shortName = #pass ifFalse: [ count := count + 1 ] ] ].
	^ count
]

{ #category : #ui }
GtRrTestsJob >> gtTestErrorsFor: aView [
	"List all the tests that failed (as opposed to the tasks that failed)"
	<gtView>

	^ aView list
		title: 'Failed Tests';
		priority: 17;
		items: [ self allFailedTests ];
		updateWhen: GtRrAnnouncement in: [ self announcer ];
		actionUpdateButton
]

{ #category : #initialization }
GtRrTestsJob >> initialize [

	super initialize.
	packageNames := #().
	classNames := #().
	testNames := #().

]

{ #category : #accessing }
GtRrTestsJob >> packageNames [
	<return: #Array of: #String>

	^ packageNames
]

{ #category : #accessing }
GtRrTestsJob >> packageNames: anObject [

	packageNames := anObject
]

{ #category : #ui }
GtRrTestsJob >> summaryAttributes [
	"Answer a collection of key/value attributes that can simply be listed as a summary of the receiver"

	^ super summaryAttributes
		add: 'Test Count:' -> self testCount;
		add: 'Failed Test Count:' -> self failedTestCount;
		yourself.
]

{ #category : #accessing }
GtRrTestsJob >> tasks [

	^ tasks ifNil: [ 
		  | tests |
		  tests := OrderedCollection new.
		  tests addAll: testNames.
		  classNames do: [ :className | 
			  className asClass testSelectors do: [ :selector | 
				  tests add: className -> selector ] ].
		  packageNames do: [ :packageName | 
			  packageName asPackage classes
				  select: [ :cls | cls isTestCase and: [ cls isAbstract not ] ]
				  thenDo: [ :cls | 
					  cls testSelectors do: [ :selector | 
						  tests add: cls name -> selector ] ] ].
		  tasks := tests collect: [ :test | 
			           GtRrTestTask tests:
				           { (test key -> { test value }) } asDictionary ] ]
]

{ #category : #accessing }
GtRrTestsJob >> testCount [
	"Answer number of tests in the receiver"

	^ self tasks inject: 0 into: [ :sum :task | sum + task testCount ]
]

{ #category : #accessing }
GtRrTestsJob >> testNames [
	"Answer the collection of test names.
	Each test name is #ClassName -> #testSelector"
	<return: #Array of: #Association>
	
	^ testNames
]

{ #category : #accessing }
GtRrTestsJob >> testNames: anObject [

	testNames := anObject
]
