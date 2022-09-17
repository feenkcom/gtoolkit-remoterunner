Class {
	#name : #GtRrWorkersExamplesReport,
	#superclass : #Object,
	#instVars : [
		'workers'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #'instance - creation' }
GtRrWorkersExamplesReport class >> forJob: aJob [
	^ self forTasks: aJob tasks
]

{ #category : #'instance - creation' }
GtRrWorkersExamplesReport class >> forTasks: aCollectionOfTasks [
	| workers |
	workers := (aCollectionOfTasks groupedBy: [ :aTask |
		aTask workerId ])  associations collect: [ :assoc |
			GtRrWorkerExamplesReport new
				tasks: assoc value ;
				workerAttributes:  assoc value first workerAttributes;
				yourself ].
	^ self new 
		workers: workers
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> cummulativeTasksDuration [
	^ self workers  
		inject: 0 seconds 
		into: [ :totalDuration :aWorker |
			totalDuration + aWorker tasksDuration ]
]

{ #category : #'gt - extensions' }
GtRrWorkersExamplesReport >> gtViewWorkersFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Workers Stats';
		items: [ self workers ];
		column: 'Id' text: [ :aWorker | aWorker workerId ];
		column: 'Tasks' text: [ :aWorker | aWorker numberOfTasks ];
		column: 'Checks' text: [ :aWorker | aWorker numberOfExamples ];
		column: 'Tasks Duration' text: [ :aWorker | aWorker tasksDuration ]
]

{ #category : #'gt - extensions' }
GtRrWorkersExamplesReport >> gtViewWorkersTimingFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Workers Timing';
		priority: 20;
		items: [ self workers ];
		column: 'Id' text: [ :aWorker | aWorker workerId ];
		column: 'Tasks Start Time' text: [ :aWorker | 
			aWorker tasksStartTime 
				ifNil: [ '-'] 
				ifNotNil: [ :aTimestamp | aTimestamp printToSeconds ] ];
		column: 'Tasks End Time' text: [ :aWorker | 
			aWorker tasksEndTime 
				ifNil: [ '-'] 
				ifNotNil: [ :aTimestamp | aTimestamp printToSeconds ]  ];
		column: 'Tasks Duration' text: [ :aWorker | aWorker tasksDuration ];
		column: 'Task Gap' text: [ :aWorker | aWorker taskGapsDuration ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> numberOfExamples [
	^ self workers sumNumbers: [ :aWorker | aWorker numberOfExamples ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> numberOfWorkers [
	^ self workers size
]

{ #category : #printing }
GtRrWorkersExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [
		aStream 
			print: self workers size;
			<< ' workers' ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksFirstHandoveTime [ 
	^ self tasksFirstTimeFor: [ :aWorker | aWorker tasksFirstHandoveTime ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksFirstStartTime [ 
	^ self tasksFirstTimeFor: [ :aWorker |  aWorker tasksStartTime ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksFirstTimeFor: aBlock [ 
	^ self workers 
		inject: (aBlock value: self workers first)
		into: [ :startTime :aWorker |
			| workerStartTime |
			workerStartTime := aBlock value: aWorker.
			workerStartTime 
				ifNil: [ startTime ]
				ifNotNil: [
					startTime 
						ifNil: [ workerStartTime ]
						ifNotNil: [
							workerStartTime < startTime 
								ifTrue: [ workerStartTime ]
								ifFalse: [ startTime ] ] ] ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksLastEndTime [ 
	^ self tasksLastTimeFor: [ :aWorker | aWorker tasksEndTime ] 
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksLastResultReceivedTime [ 
	^ self tasksLastTimeFor: [ :aWorker | aWorker tasksLastResultReceivedTime ] 
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksLastStartTime [ 
	^ self tasksLastTimeFor: [ :aWorker | aWorker tasksStartTime ] 
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksLastTimeFor: aBlock [ 
	^ self workers 
		inject: (aBlock value: self workers first)
		into: [ :startTime :aWorker |
			| workerStartTime |
			workerStartTime := aBlock value: aWorker.
			workerStartTime 
				ifNil: [ startTime ]
				ifNotNil: [
					startTime 
						ifNil: [ workerStartTime ]
						ifNotNil: [
							workerStartTime > startTime 
								ifTrue: [ workerStartTime ]
								ifFalse: [ startTime ] ] ] ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksStartInterval [
	^ self tasksLastStartTime - self tasksFirstStartTime
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksStartTime [ 
	^ self tasksFirstStartTime
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> workerWithId: aWorkerId [
	^ self workers 
		detect: [ :aWorker |
			aWorker workerId = aWorkerId ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> workers [

	^ workers
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> workers: anObject [

	workers := anObject
]

{ #category : #'accessing - chart data' }
GtRrWorkersExamplesReport >> workersExecutionChartItems [
	^ self workers
		collect: [ :aWorker |
			GtRrExecutionChartDataItem fromWorker: aWorker ] 
		as: Array
]

{ #category : #'accessing - chart data' }
GtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroupWithScheduling [
	^ self workers
		collect: [ :aWorker |
			aWorker tasksExecutionChartItemsGroupWithScheduling ] 
		as: Array
]
