Class {
	#name : #GtRrWorkerExamplesReport,
	#superclass : #Object,
	#instVars : [
		'workerAttributes',
		'tasks'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
GtRrWorkerExamplesReport >> description [
	^ self workerId 
]

{ #category : #'gt - extensions' }
GtRrWorkerExamplesReport >> gtViewDurationExecutionChartListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Duration Chart';
		priority: 11;
		object: [ self tasks ];
		view: #gtViewTimelineV4For:
]

{ #category : #'gt - extensions' }
GtRrWorkerExamplesReport >> gtViewDurationSortedChartListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Duration Chart (sorted)';
		priority: 10;
		object: [ self tasks ];
		view: #gtViewTimelineV3For: 
]

{ #category : #'gt - extensions' }
GtRrWorkerExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self tasks ]
]

{ #category : #'gt - extensions' }
GtRrWorkerExamplesReport >> gtViewTasksListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks list';
		priority: 30;
		object: [ self tasks ];
		view: #gtViewTasksFor: 
]

{ #category : #'gt - extensions' }
GtRrWorkerExamplesReport >> gtViewTasksOverviewFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Tasks Results';
		priority: 5; 
		items: [ self tasks  ];
		column: 'Checks' text: [ :aTask | aTask totalCount ];
		column: 'Success' text: [ :aTask | aTask numberOfSuccesses ];
		column: 'Skipped' text: [ :aTask | aTask numberOfSkipps ];
		column: 'Failures' text: [ :aTask | aTask numberOfFailures ];
		column: 'Errors' text: [ :aTask | aTask numberOfErrors ];
		column: 'Duration (runner)' text: [ :aTask | 
			aTask durationOnRunner ifNil: [ '-' ] ];
		column: 'Duration (worker)' text: [ :aTask | 
			aTask duration ifNil: [ '-' ] ] "width: 150"
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> numberOfExamples [ 
	^ tasks sumNumbers: #totalCount
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> numberOfTasks [ 
	^ tasks size
]

{ #category : #printing }
GtRrWorkerExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [
		aStream 
			print: self tasks size;
			<< ' tasks';
			<< ', ';
			print: self numberOfExamples;
			<< ' checks'  ]
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> taskGapsDuration [
	| gapDuration|
	gapDuration := 0 seconds.
	self tasks  pairsDo: [ :aTask :anotherTask |
		(anotherTask startTime notNil and: [aTask endTime notNil])
			ifTrue: [ gapDuration := gapDuration + (anotherTask startTime - aTask endTime) ].
		gapDuration ].
	^ gapDuration
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasks [
	^ tasks
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasks: aCollection [
	tasks := GtRrTasksGroup withAll: aCollection
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksDuration [
	^ self tasks  duration
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksEndTime [ 
	^ self tasks endTime
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksExecutionChartItemsData [
	^ self tasksExecutionChartItemsGroup 
		collect: [ :anItem | anItem asDictionary ] 
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksExecutionChartItemsGroup [
	^ (GtRrExecutionChartDataItemsGroup withAll: ((self tasks 
		select: #hasCompleted)
			collect: [ :aTask |
				(GtRrExecutionChartDataItem fromTask: aTask) ]))
		label: self workerId
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksFirstHandoveTime [ 
	^ self tasks firstHandoverTime
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksLastResultReceivedTime [ 
	^ self tasks lastResultReceivedTime
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksStartTime [ 
	^ self tasks startTime
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> workerAttributes [

	^ workerAttributes
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> workerAttributes: aDictionary [

	workerAttributes := aDictionary
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> workerId [
	^ self workerAttributes at: 'id'
]
