"
GtRrChecksJob expects to hold {{gtClass:GtRrAbstractExamplesTask}} subclasses as its tasks.
"
Class {
	#name : #GtRrChecksJob,
	#superclass : #GtRrTasksJob,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
GtRrChecksJob >> schedulingInformation [
	"Answer an Array of:
		{ ClassName. selector. PharoLinkTestCaseEndAnnouncement }
	for all successful results"
	| groupedResults defaultTaskMilliseconds |

	defaultTaskMilliseconds := LwRrPersistentTimeTaskGrouper defaultTaskMilliseconds.
	"Collect the test times.
	A 0 time is suspicious, replace it with the default group time"
	groupedResults := Dictionary new.
	results do: [ :task |
		task result ifNotNil: [ :result |
			result do: [ :testResult |
				(groupedResults at: testResult testCaseClassName ifAbsentPut: [ Dictionary new ])
				at: testResult testCaseSelector put: 
					(testResult duration = Duration zero 
						ifTrue: [ defaultTaskMilliseconds ]
						ifFalse: [ testResult duration asMilliSeconds max: 1 ]) ] ] ].

	^ results flatCollect: [ :task |
		task testNames collect: [ :testName |
					{ testName key. 
					testName value.
					groupedResults
						at: testName key
						ifPresent: [ :dict | dict 
							at: testName value 
							ifPresent: [ :ms | ms = 0
								ifTrue: [ defaultTaskMilliseconds ]
								ifFalse: [ ms ] ]
							ifAbsent: [ defaultTaskMilliseconds ] ]
						ifAbsent: [ defaultTaskMilliseconds ] } ] ].
]

{ #category : #accessing }
GtRrChecksJob >> testResultTimes [

]
