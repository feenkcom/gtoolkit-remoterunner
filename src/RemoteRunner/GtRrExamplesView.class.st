"
GtRrTestView takes a job that consists of a mixture of SUnit tests and Gt examples and presents a coherent view of the results.
"
Class {
	#name : #GtRrExamplesView,
	#superclass : #Object,
	#instVars : [
		'job',
		'tasks'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'accessing - dynamic' }
GtRrExamplesView >> erroredExamples [

	^ self tasks flatCollect: [ :task |
			task erroredExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesView >> executedExamples [

	^ self tasks flatCollect: [ :task |
			task executedExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesView >> failedExamples [

	^ self tasks flatCollect: [ :task |
			task failedExamples ].
]

{ #category : #ui }
GtRrExamplesView >> gtErroredExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self erroredExamples
		title: 'Errored'
		priority: 14.
]

{ #category : #ui }
GtRrExamplesView >> gtExecutedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self executedExamples
		title: 'Executed'
		priority: 20.
]

{ #category : #ui }
GtRrExamplesView >> gtFailedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self failedExamples
		title: 'Failed'
		priority: 12.
]

{ #category : #ui }
GtRrExamplesView >> gtSkippedExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self skippedExamples
		title: 'Skipped'
		priority: 16.
]

{ #category : #ui }
GtRrExamplesView >> gtSuccesfulExamplesFor: aView [
	<gtView>

	^ self gtView: aView 
		forExamples: self successfulExamples
		title: 'Successful'
		priority: 11.
]

{ #category : #ui }
GtRrExamplesView >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item third ]
]

{ #category : #ui }
GtRrExamplesView >> gtView: aView forExamples: examplesCollection title: titleString priority: priorityNumber [.

	(examplesCollection isNil or: [ examplesCollection isEmpty ]) ifTrue:
		[  ^ aView empty ].

	^ aView list
		title: titleString;
		priority: priorityNumber;
		items: examplesCollection
]

{ #category : #accessing }
GtRrExamplesView >> job [

	^ job
]

{ #category : #accessing }
GtRrExamplesView >> job: anObject [

	job := anObject
]

{ #category : #accessing }
GtRrExamplesView >> results [

	^ job results
]

{ #category : #'accessing - dynamic' }
GtRrExamplesView >> skippedExamples [

	^ self tasks flatCollect: [ :task |
			task skippedExamples ].
]

{ #category : #'accessing - dynamic' }
GtRrExamplesView >> successfulExamples [

	^ self tasks flatCollect: [ :task |
			task successfulExamples ].
]

{ #category : #ui }
GtRrExamplesView >> summaryAttributes [

	^ Array streamContents: [ :stream | | executed successful failed errored skipped |
		executed := self executedExamples.
		errored := self erroredExamples.
		failed := self failedExamples.
		skipped := self skippedExamples.
		successful := self successfulExamples.
		stream 
			nextPut: { #Executed. executed size. executed. };
			nextPut: { #Successful. successful size. successful. };
			nextPut: { #Failed. failed size. failed. };
			nextPut: { #Errored. errored size. errored. };
			nextPut: { #Skipped. skipped size. skipped. } ]
]

{ #category : #accessing }
GtRrExamplesView >> tasks [

	^ tasks ifNil: [ tasks := job tasks ]
]

{ #category : #accessing }
GtRrExamplesView >> tasks: aCollection [

	tasks := aCollection
]
