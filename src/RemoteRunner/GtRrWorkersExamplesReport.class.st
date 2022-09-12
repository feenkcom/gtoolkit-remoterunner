Class {
	#name : #GtRrWorkersExamplesReport,
	#superclass : #Object,
	#instVars : [
		'workers'
	],
	#category : #'RemoteRunner-Worker'
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
			aWorker tasksStartTime printToSeconds ];
		column: 'Tasks End Time' text: [ :aWorker | 
			aWorker tasksEndTime printToSeconds ];
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
GtRrWorkersExamplesReport >> tasksFirstStartTime [ 
	^ self workers 
		inject: self workers first tasksStartTime
		into: [ :startTime :aWorker |
			| workerStartTime |
			workerStartTime := aWorker tasksStartTime.
			workerStartTime < startTime 
				ifTrue: [ workerStartTime ]
				ifFalse: [ startTime ]  ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksLastEndTime [ 
	^ self workers 
		inject: self workers first tasksEndTime
		into: [ :endTime :aWorker |
			| workerEndTime |
			workerEndTime := aWorker tasksEndTime.
			workerEndTime > endTime 
				ifTrue: [ workerEndTime ]
				ifFalse: [ endTime ]  ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksLastStartTime [ 
	^ self workers 
		inject: self workers first tasksStartTime
		into: [ :startTime :aWorker |
			| workerStartTime |
			workerStartTime := aWorker tasksStartTime.
			workerStartTime > startTime 
				ifTrue: [ workerStartTime ]
				ifFalse: [ startTime ]  ]
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
GtRrWorkersExamplesReport >> workers [

	^ workers
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> workers: anObject [

	workers := anObject
]
