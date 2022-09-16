"
{{gtClass:GtRrExamplesReport}} takes a job that consists of a mixture of SUnit tests and Gt examples and presents a coherent view of the results.
"
Class {
	#name : #GtRrExamplesReport,
	#superclass : #Object,
	#instVars : [
		'job',
		'tasks'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
GtRrExamplesReport >> allExamples [

	^ self tasks flatCollect: [ :task |
			task allExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> erroredExampleResultsWithTask [

	^ self tasks flatCollect: [ :task |
			task erroredExamples collect: [ :aResult |
				GtRrExampleResultWithTask new 
					exampleResult:  aResult;
					task: task ] ]
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> erroredExamples [

	^ self tasks flatCollect: [ :task |
			task erroredExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> executedExamples [

	^ self tasks flatCollect: [ :task |
			task executedExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> failedExamples [

	^ self tasks flatCollect: [ :task |
			task failedExamples ].
]

{ #category : #ui }
GtRrExamplesReport >> gtErroredExamplesByErrorFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'Errors (by message)';
		priority: 14.2;
		items: [ (self erroredExamples 
			groupedBy: [ :each | each exceptionMessageText ]) associations 
				sort: [ :a :b | a value size > b value size ] ];
		column: 'Error Message' text: [ :assoc | assoc key ];
		column: 'Errors Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]

{ #category : #ui }
GtRrExamplesReport >> gtErroredExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self erroredExamples
		title: 'Errored'
		priority: 14.
]

{ #category : #ui }
GtRrExamplesReport >> gtExecutedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self executedExamples
		title: 'Executed'
		priority: 20.
]

{ #category : #ui }
GtRrExamplesReport >> gtFailedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self failedExamples
		title: 'Failed'
		priority: 12.
]

{ #category : #ui }
GtRrExamplesReport >> gtNotExecutedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self notExecutedExamples
		title: 'Not Executed'
		priority: 17.
]

{ #category : #ui }
GtRrExamplesReport >> gtSkippedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self skippedExamples
		title: 'Skipped'
		priority: 16.
]

{ #category : #ui }
GtRrExamplesReport >> gtSuccesfulExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self successfulExamples
		title: 'Successful'
		priority: 11.
]

{ #category : #ui }
GtRrExamplesReport >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | GtExampleGroup  withAll: item third ]
]

{ #category : #ui }
GtRrExamplesReport >> gtView: aView forExamples: examplesCollection title: titleString priority: priorityNumber [.

	(examplesCollection isNil or: [ examplesCollection isEmpty ]) ifTrue:
		[  ^ aView empty ].

	^ aView list
		title: titleString;
		priority: priorityNumber;
		items: examplesCollection
]

{ #category : #accessing }
GtRrExamplesReport >> job [
	<return: #GtRrJob>

	^ job
]

{ #category : #accessing }
GtRrExamplesReport >> job: aGtRrJob [

	job := aGtRrJob
]

{ #category : #'accessing - job' }
GtRrExamplesReport >> name [

	^ job name
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> notExecutedExamples [

	^ (self tasks reject: #isFinished) flatCollect: #examples
]

{ #category : #copying }
GtRrExamplesReport >> postCopy [

	job := job copy.
	tasks := nil.
]

{ #category : #accessing }
GtRrExamplesReport >> results [

	^ job results
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> skippedExamples [

	^ self tasks flatCollect: [ :task |
			task skippedExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> successfulExamples [

	^ self tasks flatCollect: [ :task |
			task successfulExamples ].
]

{ #category : #ui }
GtRrExamplesReport >> summaryAttributes [

	^ Array streamContents: [ :stream | 
		| all executed successful failed errored skipped notExecuted |
		all := self allExamples.
		executed := self executedExamples.
		errored := self erroredExamples.
		failed := self failedExamples.
		skipped := self skippedExamples.
		successful := self successfulExamples.
		notExecuted := self notExecutedExamples.
		stream 
			nextPut: { #All. all size. all. };
			nextPut: { #Executed. executed size. executed. };
			nextPut: { #Successful. successful size. successful. };
			nextPut: { #Failed. failed size. failed. };
			nextPut: { #Errored. errored size. errored. };
			nextPut: { #Skipped. skipped size. skipped. };
			nextPut: { #NotExecuted. notExecuted size. notExecuted. } ]
]

{ #category : #accessing }
GtRrExamplesReport >> summaryString [
	"Answer a textual summary of the receiver"
	| examples |

	^ String streamContents: [ :stream |
		stream << 'Summary'; cr; cr.
		self summaryAttributes do: [ :attr |
			stream
				<< attr first;
				tab; tab;
				print: attr second; cr ].
		stream cr.
		examples := self failedExamples.
		examples ifNotEmpty:
			[ stream << 'Failed Examples'; cr; cr.
			examples do: [ :example |
				stream print: example method; cr ].
			stream cr; cr ].
		examples := self erroredExamples.
		examples ifNotEmpty:
			[ stream << 'Errored Examples'; cr; cr.
			examples do: [ :example |
				stream print: example method; cr ].
			stream cr; cr ].
		examples := self skippedExamples.
		examples ifNotEmpty:
			[ stream << 'Skipped Examples'; cr; cr.
			examples do: [ :example |
				stream print: example method; cr ].
			stream cr; cr ].
	]
]

{ #category : #accessing }
GtRrExamplesReport >> tasks [

	^ tasks ifNil: [ tasks := job tasks ]
]

{ #category : #accessing }
GtRrExamplesReport >> tasks: aCollection [

	tasks := aCollection
]
