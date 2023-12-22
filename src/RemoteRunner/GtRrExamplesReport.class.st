"
{{gtClass:GtRrExamplesReport}} takes a job that consists of a mixture of SUnit tests and Gt examples and presents a coherent view of the results.
"
Class {
	#name : #GtRrExamplesReport,
	#superclass : #Object,
	#instVars : [
		'jobName',
		'tasksOrResults'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #'instance creation' }
GtRrExamplesReport class >> forJob: aTaskExecutionResults [
	^ self new	  
		initializeForJob: aTaskExecutionResults
]

{ #category : #'instance creation' }
GtRrExamplesReport class >> forTaskExecutionResults: aTaskExecutionResults [
	^ self new	  
		initializeForTaskExecutionResults: aTaskExecutionResults
]

{ #category : #accessing }
GtRrExamplesReport >> allExamples [

	^ self wrapPlainExamples: (self tasks 
		flatCollect: [ :task |
			task allExamples ])
]

{ #category : #utils }
GtRrExamplesReport >> collectExecutedExamplesWithOriginFor: aBlock [

	^ self tasks 
		flatCollect: [ :aTask |
			(aBlock cull: aTask) collect: [ :aResult |
				GtRrExampleResultWithTask new 
					exampleResult:  aResult;
					task: aTask ] ]
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> erroredExampleWithRunOrigin [

	^ GtRrFailingExampleResultWithTasksGroup withAll: (
		self collectExecutedExamplesWithOriginFor: [ :aTask |
			aTask erroredExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> erroredExamples [

	^ self wrapPlainExamples: (self tasks flatCollect: [ :aTask |
		aTask erroredExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> executedExampleWithOrigin [

	^ GtRrExampleResultWithTasksGroup withAll: (
		self collectExecutedExamplesWithOriginFor: [ :aTask |
			aTask executedExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> executedExamples [

	^ self wrapPlainExamples: (self tasks flatCollect: [ :task |
			task executedExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> failedExamples [

	^ self wrapPlainExamples: (self tasks flatCollect: [ :aTask |
			aTask failedExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> failedExamplesWithOrigin [

	^ GtRrFailingExampleResultWithTasksGroup withAll: (
		self collectExecutedExamplesWithOriginFor: [ :aTask |
			aTask failedExamples ])
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
		  send: [ :item | item third value ]
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

{ #category : #initialization }
GtRrExamplesReport >> initializeForJob: aGtRrJob [
	jobName := aGtRrJob name. 
	tasksOrResults := aGtRrJob tasks.
]

{ #category : #initialization }
GtRrExamplesReport >> initializeForTaskExecutionResults: aTaskExecutionResults [ 
	tasksOrResults := aTaskExecutionResults
]

{ #category : #'accessing - job' }
GtRrExamplesReport >> name [

	^ jobName 
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> notExecutedExamples [

	^ self wrapPlainExamples: ((self tasks 
		reject: #isFinished) flatCollect: #allExamples)
]

{ #category : #'accessing - counts' }
GtRrExamplesReport >> numberOfErrors [
	^ self tasks sumNumbers: [ :task |
		task numberOfErrors ] 
]

{ #category : #'accessing - counts' }
GtRrExamplesReport >> numberOfExecutedChecks [
	^ self tasks sumNumbers: [ :aTask |
		aTask numberOfExecutedChecks ] 
]

{ #category : #'accessing - counts' }
GtRrExamplesReport >> numberOfFailures [
	^ self tasks sumNumbers: [ :task |
		task numberOfFailures ] 
]

{ #category : #'accessing - counts' }
GtRrExamplesReport >> numberOfSkips [
	^ self tasks sumNumbers: [ :task |
		task numberOfSkips ] 
]

{ #category : #'accessing - counts' }
GtRrExamplesReport >> numberOfSuccesses [
	^ self tasks sumNumbers: [ :task |
		task numberOfSuccesses ] 
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> skippedExamples [

	^self wrapPlainExamples:  (self tasks flatCollect: [ :aTask |
			aTask skippedExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> skippedExamplesWithOrigin [

	^ GtRrExampleResultWithTasksGroup withAll:( 
		self collectExecutedExamplesWithOriginFor: [ :aTask |
			aTask skippedExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> successfulExamples [

	^ self wrapPlainExamples: (self tasks flatCollect: [ :task |
			task successfulExamples ])
]

{ #category : #'accessing - dynamic' }
GtRrExamplesReport >> successfulExamplesWithOrigin [

	^ GtRrExampleResultWithTasksGroup withAll: (
		self collectExecutedExamplesWithOriginFor: [ :aTask |
			aTask successfulExamples ])
]

{ #category : #ui }
GtRrExamplesReport >> summaryAttributes [

	^ Array streamContents: [ :stream | 
		| notExecuted |
		notExecuted := self notExecutedExamples.
		
		stream 
			"nextPut: { 
				#All. 
				self totalCount. 
				[ self allExamples ] };"
			nextPut: { 
				#Executed. 
				self numberOfExecutedChecks. 
				[ self executedExampleWithOrigin ]. };
			nextPut: { 
				#Successful. 
				self numberOfSuccesses. 
				[ self successfulExamplesWithOrigin ] };
			nextPut: { 
				#Failed. 
				self numberOfFailures. 
				[ self failedExamplesWithOrigin ] };
			nextPut: { 
				#Errored. 
				self numberOfErrors. 
				[ self erroredExampleWithRunOrigin ] };
			nextPut: { 
				#Skipped.
				self numberOfSkips. 
				[ self skippedExamplesWithOrigin ] }
				
			"nextPut: { #NotExecuted. notExecuted size. notExecuted. }" ]
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

	^ tasksOrResults
]

{ #category : #'accessing - counts' }
GtRrExamplesReport >> totalCount [
	^ self tasks sumNumbers: [ :task |
		task totalCount ] 
]

{ #category : #utils }
GtRrExamplesReport >> wrapPlainExamples: aCollection [
	^ aCollection
]
