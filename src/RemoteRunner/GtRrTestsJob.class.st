Class {
	#name : #GtRrTestsJob,
	#superclass : #GtRrAbstractTestsJob,
	#category : #'RemoteRunner-Tests'
}

{ #category : #private }
GtRrTestsJob >> allFailedTests [
	"Answer all tests that failed (Fail or Error)"

	results ifNil: [ ^ #() ].
	^ Array streamContents: [ :stream |
		results do: [ :task |
			task result do: [ :test |
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

{ #category : #private }
GtRrTestsJob >> defaultTaskAllocator [
	"Answer the object that will allocate job items to job tasks"

	^ GtRrOneAtATimeTestsTaskAllocator new
]

{ #category : #ui }
GtRrTestsJob >> gtTestErrorsFor: aView [
	"List all the tests that failed (as opposed to the tasks that failed)"
	<gtView>

	^ aView list
		title: 'Failed Tests';
		priority: 17;
		items: [ self allFailedTests ];
		updateWhen: GtRemoteRunnerAnnouncement in: [ self announcer ];
		actionUpdateButton
]
