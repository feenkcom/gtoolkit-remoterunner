Class {
	#name : #GtRrSUnitTask,
	#superclass : #GtRrTask,
	#category : #'RemoteRunner-Tests'
}

{ #category : #running }
GtRrSUnitTask >> runSuite: suite [
	| events testResult |

	events := OrderedCollection new.
	testResult := PharoLinkTestResult new.
	testResult announcer
		when: PharoLinkTestCaseEndAnnouncement
		do: [ :e | events add: e ].
	suite run: testResult.
	^ events asArray
]
