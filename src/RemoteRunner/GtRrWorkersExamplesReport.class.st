Class {
	#name : #GtRrWorkersExamplesReport,
	#superclass : #Object,
	#traits : 'TGtRrWorkersExamplesReportViews',
	#classTraits : 'TGtRrWorkersExamplesReportViews classTrait',
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

{ #category : #accessing }
GtRrWorkersExamplesReport >> cummulativeTasksDurationOnRunner [
	^ self workers  
		inject: 0 seconds 
		into: [ :totalDuration :aWorker |
			totalDuration + aWorker tasksDurationOnRunner ]
]

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> fullGcTime [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker fullGcTime ]
]

{ #category : #'gt - extensions' }
GtRrWorkersExamplesReport >> gtViewWorkersFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Workers Stats';
		items: [ self workers ];
		priority: 10;
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
		column: 'Task Gap' text: [ :aWorker | aWorker taskGapsDuration ];
		column: 'GC Duration' text: [ :aWorker | 
			aWorker totalGCTime 
				ifNil: [ '-' ] 
				ifNotNil: [ :aGCTime | Duration milliSeconds: aGCTime ]]
]

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> incrGcTime [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker incrGcTime ]
]

{ #category : #'accessing - resource report' }
GtRrWorkersExamplesReport >> machineMaximumAvailableMemory [
	^ self workers gtMinWithNilValues: [ :aWorker | aWorker machineMaximumAvailableMemory ]
]

{ #category : #'accessing - resource report' }
GtRrWorkersExamplesReport >> machineMinimumAvailableMemory [
	^ self workers gtMinWithNilValues: [ :aWorker | aWorker machineMinimumAvailableMemory ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> machineTotalMemory [
	^ self workers 
		detect: [ :aWorker | aWorker machineTotalMemory notNil ]
		ifFound: [ :aWorker | aWorker machineTotalMemory ] 
		ifNone: [ nil ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> numberOfExamples [
	^ self workers sumNumbers: [ :aWorker | aWorker numberOfExamples ]
]

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> numberOfFullGCs [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker numberOfFullGCs ]
]

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> numberOfIncrementalGCs [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker numberOfIncrementalGCs ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> numberOfTasks [
	^ self workers sumNumbers: [ :aWorker | aWorker numberOfTasks ]
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

{ #category : #'math functions' }
GtRrWorkersExamplesReport >> sumWorkerNumbers: aBlock [
	^ self workers sumNumbers: aBlock
]

{ #category : #'math functions' }
GtRrWorkersExamplesReport >> sumWorkerValueWithNil: aBlock [
	^ self workers gtSumWithNilValues: aBlock
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> taskGapsDuration [
	^ self workers 
		inject: 0 seconds 
		into: [ :total  :aWorker | 
			total + aWorker taskGapsDuration ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksCompletionDelay [
	| tasksEndTime|
	
	tasksEndTime := self workers 
		collect: [  :aWorker | aWorker tasksLastResultReceivedTime ].
	^ tasksEndTime max - tasksEndTime min
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksExecutionInterval [
	^ self tasksLastEndTime - self tasksFirstStartTime
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> tasksExecutionIntervalOnRunner [
	^ self tasksLastResultReceivedTime - self tasksFirstHandoveTime
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

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> tasksFullGcTime [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker tasksFullGcTime ]
]

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> tasksIncrGcTime [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker tasksIncrGcTime ]
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

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> tasksTotalGCTime [
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker tasksTotalGCTime ]
]

{ #category : #'accessing - gc details' }
GtRrWorkersExamplesReport >> totalGCTime [ 
	^ self sumWorkerValueWithNil: [ :aWorker | aWorker totalGCTime ]
]

{ #category : #'accessing - resource report' }
GtRrWorkersExamplesReport >> vmAverageMemorySize [
	^ ((self workers 
		gtSumWithNilValues: [ :aWorker | aWorker vmMaximumMemorySize]) / self workers size ) asInteger
]

{ #category : #'accessing - resource report' }
GtRrWorkersExamplesReport >> vmMaximumMemorySize [
	^ self workers gtMaxWithNilValues: [ :aWorker | aWorker vmMaximumMemorySize ]
]

{ #category : #'accessing - resource report' }
GtRrWorkersExamplesReport >> vmMinimumMemorySize [
	^ self workers gtMinWithNilValues: [ :aWorker | aWorker vmMinimumMemorySize ]
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

{ #category : #'accessing - chart data' }
GtRrWorkersExamplesReport >> workersTasksMachineAvailableMemoryChartItems [
	^ (self workers flatCollect: [ :aWorker | 
		aWorker tasksMachineAvailableMemoryChartItems ]) sorted: [ :each | each timestamp ] ascending
]

{ #category : #'accessing - chart data' }
GtRrWorkersExamplesReport >> workersTasksMachineFreeMemoryChartItems [
	^ self workers flatCollect: [ :aWorker | 
		aWorker tasksMachineFreeMemoryChartItems ]
]
