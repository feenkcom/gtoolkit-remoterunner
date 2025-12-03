"
GtRrChecksJob expects to hold {{gtClass:GtRrAbstractExamplesTask}} subclasses as its tasks.
"
Class {
	#name : #GtRrChecksJob,
	#superclass : #GtRrTasksJob,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
GtRrChecksJob class >> exampleNames: anArray [

	^ self new tasks: { (GtRrExplicitExampleTask exampleNames: anArray) }
]

{ #category : #accessing }
GtRrChecksJob class >> leJsonV4Name [

	^ #gtRrChecksJob
]

{ #category : #'as yet unclassified' }
GtRrChecksJob class >> retryTasksInfoFrom: aCollectionOfTasks [
	"Answer a GtRrAbstractRetryTasks populated with the receiver's information.
	Only valid when the receiver is a retry tasks."

	^ GtRrChecksRetryTasks fromTasks: aCollectionOfTasks
]

{ #category : #accessing }
GtRrChecksJob class >> sunitTestNames: anArray [

	^ self new tasks: { (GtRrExplicitSUnitTask sunitTestNames: anArray) }
]

{ #category : #accessing }
GtRrChecksJob >> checkNames [

	^ self tasks flatCollect: #checkNames
]

{ #category : #testing }
GtRrChecksJob >> isChecksJob [

	^ true
]

{ #category : #accessing }
GtRrChecksJob >> numberOfChecks [

	^ self tasks
		inject: 0
		into: [ :s :v | s + v numberOfChecks ]
]

{ #category : #accessing }
GtRrChecksJob >> resultsGroupedByTestName [
	| dictionary |

	dictionary := Dictionary new.
	results do: [ :task |
		task result do: [ :testResult |
			(dictionary at: testResult testName ifAbsentPut: [ OrderedCollection new ]) add: testResult ] ].
	^ dictionary
]
