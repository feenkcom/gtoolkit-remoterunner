"
{{gtClass:GtRrTasksJob}} is a simple job that is given a list of tasks to execute.
"
Class {
	#name : #GtRrTasksJob,
	#superclass : #GtRrJob,
	#instVars : [
		'tasks'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #jsonV4 }
GtRrTasksJob class >> leJsonV4AttributeMapping [
	"Answer the Array of attribute to store keys.
	Subclasses should override this with their attributes."

	^ super leJsonV4AttributeMapping
		add: #tasks -> #tasks;
		yourself.
]

{ #category : #jsonV4 }
GtRrTasksJob class >> leJsonV4Name [

	^ #gtRrTasksJob
]

{ #category : #'instance creation' }
GtRrTasksJob class >> tasks: aCollection [

	^ self new tasks: aCollection
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> allExamples [
	^ tasks flatCollect: #examples
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> erroredExamples [
	^ tasks flatCollect: [:aTask | aTask erroredExamples ]
]

{ #category : #'accessing - reports' }
GtRrTasksJob >> examplesReport [
	^ GtRrExamplesReport new
		job: self 
]

{ #category : #accessing }
GtRrTasksJob >> executionTimelineChartItems [
	| firstTaskHandoverTime lastResultReceivedTime |
	firstTaskHandoverTime := self firstTaskHandoverTime.
	lastResultReceivedTime := self lastTaskResultReceivedTime.
	
	^ {
		GtRrExecutionChartDataItem new 
			startTime: self  creationTime;
			endTime: self startTime;
			label: 'Send to remote runner';
			appendDurationToLabel.
			
		GtRrExecutionChartDataItem new 
			startTime: self  startTime;
			endTime: firstTaskHandoverTime;
			label:  'Waiting for workers';
			appendDurationToLabel.
			
		GtRrExecutionChartDataItem new 
			startTime: firstTaskHandoverTime;
			endTime: lastResultReceivedTime;
			label:  'Tasks Execution';
			appendDurationToLabel.
			
		GtRrExecutionChartDataItem new 
			startTime: lastResultReceivedTime;
			endTime: self endTime;
			label:  'Finishing execution';
			appendDurationToLabel } collect: #asDictionary
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> failedExamples [
	^ tasks flatCollect: [:aTask | aTask failedExamples ]
]

{ #category : #accessing }
GtRrTasksJob >> firstTaskHandoverTime [
	| handoverTime|
	
	handoverTime := self tasks first handoverTime.
	self tasks do: [ :aTask | 
		(aTask handoverTime notNil and: [ aTask handoverTime < handoverTime ])
			ifTrue: [
				handoverTime := aTask handoverTime ] ]. 
	
	^ handoverTime
]

{ #category : #'gt - extensions' }
GtRrTasksJob >> gtViewTestsActionFor: anAction [
	<gtAction>

	self hasTests ifFalse: [ ^ anAction noAction ].

	^ anAction button
		tooltip: 'View Test Results';
		icon: BrGlamorousVectorIcons eg;
		action: [ :button | 
			button phlow spawnObject:
				(GtRrExamplesReport new 
					job: self) ].
]

{ #category : #'gt - extensions' }
GtRrTasksJob >> gtViewWorkersReportActionFor: anAction [
	<gtAction>

	^ anAction button
		tooltip: 'View Workers Report';
		icon: BrGlamorousVectorIcons changes;
		action: [ :button | button phlow spawnObject:
			self workersReport ].
]

{ #category : #testing }
GtRrTasksJob >> hasTests [
	"Answer a boolean indicating if the receiver has one or more tasks that are considered test tasks"

	^ self tasks anySatisfy: [ :task | task isKindOf: GtRrAbstractExamplesTask ]
]

{ #category : #accessing }
GtRrTasksJob >> lastTaskResultReceivedTime [
	| resultReceivedTime |
	
	resultReceivedTime := self tasks first resultReceivedTime.
	self tasks do: [ :aTask | 
		(aTask resultReceivedTime notNil and: [ aTask resultReceivedTime > resultReceivedTime ])
			ifTrue: [
				resultReceivedTime := aTask resultReceivedTime ] ].
				
	^ resultReceivedTime
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> notExecutedExamples [
	^  (tasks reject: #isFinished) flatCollect: #examples
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> numberOfErroredExamples [ 
	^ tasks sumNumbers: [ :aTask | aTask numberOfErrors ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> numberOfFailedExamples [ 
	^ tasks sumNumbers: [ :aTask | aTask numberOfFailures ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> numberOfSkippedExamples [ 
	^ tasks sumNumbers: [ :aTask | aTask numberOfSkipps ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> numberOfSuccessfulExamples [ 
	^ tasks sumNumbers: [ :aTask | aTask numberOfSuccesses ]
]

{ #category : #copying }
GtRrTasksJob >> postCopy [

	super postCopy.
	tasks := tasks collect: #copy.
]

{ #category : #printing }
GtRrTasksJob >> printOn: aStream [

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title;
		nextPut: $(;
		print: self tasks size;
		<< ' tasks, ';
		print: self state.
	self hasErrors ifTrue:
		[ aStream << ' with errors' ].
	aStream
		nextPut: $).
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> skippedExamples [
	^ tasks flatCollect: [ :aTask | aTask skippedExamples ]
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> successfulExamples [
	^ tasks flatCollect: [ :aTask | aTask successfulExamples ]
]

{ #category : #accessing }
GtRrTasksJob >> tasks [

	^ tasks
]

{ #category : #accessing }
GtRrTasksJob >> tasks: anObject [

	tasks := anObject
]

{ #category : #'accessing - examples' }
GtRrTasksJob >> totalExamplesCount [ 
	^ tasks sumNumbers: #totalCount
]

{ #category : #'accessing - reports' }
GtRrTasksJob >> workersReport [
	^ GtRrWorkersExamplesReport forJob: self 
]
