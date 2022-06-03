Class {
	#name : #GtRrSUnitTask,
	#superclass : #GtRrAbstractExamplesTask,
	#category : #'RemoteRunner-Tests'
}

{ #category : #visiting }
GtRrSUnitTask >> acceptVisitor: aVisitor [

	^ aVisitor visitSUnitTask: self
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> erroredExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 
			pharoLinkTestCaseAnnouncement shortName = #error or:
			[ pharoLinkTestCaseAnnouncement shortName = #warning ] ]

]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> executedExamples [

	result ifNil: [ ^ #() ].
	^ result
]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> failedExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 	pharoLinkTestCaseAnnouncement shortName = #failure ]

]

{ #category : #running }
GtRrSUnitTask >> run [

	^ self runSuite: self testSuite
]

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

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> skippedExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 	pharoLinkTestCaseAnnouncement shortName = #skip ]

]

{ #category : #'accessing - dynamic' }
GtRrSUnitTask >> successfulExamples [

	result ifNil: [ ^ #() ].
	^ result 
		select: [ :pharoLinkTestCaseAnnouncement | 
			#(#pass #skip) includes: pharoLinkTestCaseAnnouncement shortName ]

]

{ #category : #accessing }
GtRrSUnitTask >> testSuite [
	"Answer the test suite defined by the receiver."

	^ self subclassResponsibility
]

{ #category : #accessing }
GtRrSUnitTask >> totalCount [

	^ self testSuite tests
		ifNil: [ 0 ]
		ifNotNil: [ :tests | tests size ]
]
