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

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> fullGcTime [
	^ self vmStatisticsDiffReport ifNotNil: [ :aReport | aReport fullGcTimeDiff ]
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
				withDescriptionAsLabel;
				executions: self tasks ]
]

{ #category : #'gt - extensions' }
GtRrWorkerExamplesReport >> gtViewMemoryStatisticsDiffFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Memory Statistics Diff';
		priority: 50;
		object: [ self vmStatisticsDiffReport ];
		view: #gtViewTextualDiffFor: 
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
		column: 'Skipped' text: [ :aTask | aTask numberOfSkips ];
		column: 'Failures' text: [ :aTask | aTask numberOfFailures ];
		column: 'Errors' text: [ :aTask | aTask numberOfErrors ];
		column: 'Duration (runner)' text: [ :aTask | 
			aTask durationOnRunner ifNil: [ '-' ] ];
		column: 'Duration (worker)' text: [ :aTask | 
			aTask duration ifNil: [ '-' ] ] "width: 150"
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> incrGcTime [
	^ self vmStatisticsDiffReport ifNotNil: [ :aReport | aReport incrGcTimeDiff ]
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> isTaskCorrectlyScheduledAtIndex: taskIndex inGroup: aTasksGroup [ 
	| targetTask targetDuration|
	targetTask := aTasksGroup at: taskIndex.
	targetDuration := targetTask durationOnRunner.
	aTasksGroup from: 1 to: taskIndex - 1 do: [ :aTask |
		(targetDuration - aTask durationOnRunner > 5 seconds) ifTrue: [ ^ false ] ].
	^ true
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> machineMaximumAvailableMemory [
	^ self tasks gtMaxWithNilValues: [ :aTask | aTask machineAvailableMemory ]
]

{ #category : #'accessing - resource report' }
GtRrWorkerExamplesReport >> machineMinimumAvailableMemory [
	^ self tasks gtMinWithNilValues: [ :aTask | aTask machineAvailableMemory ]
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> machineTotalMemory [
	^ self tasks firstTaskWithResourceReport ifNotNil: [ :aTask |
		aTask executionData resourceReport machineTotalMemory ]
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> numberOfExamples [ 
	^ tasks sumNumbers: #totalCount
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> numberOfFullGCs [
	^ self vmStatisticsDiffReport ifNotNil: [ :aReport | aReport fullGCsDiff ]
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> numberOfIncrementalGCs [
	^ self vmStatisticsDiffReport ifNotNil: [ :aReport | aReport incrGCsDiff ]
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
GtRrWorkerExamplesReport >> tasksDurationOnRunner [
	^ self tasks durationOnRunner
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksEndTime [ 
	^ self tasks endTime
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksExecutionChartItems [
	^ self tasksExecutionChartItemsGroup
		collect: [ :anItem | anItem ] 
		as: Array
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksExecutionChartItemsGroup [
	^ (GtRrExecutionChartDataItemsGroup withAll: ((self tasks 
		select: #hasCompleted)
			collect: [ :aTask |
				(GtRrExecutionChartDataItem fromTask: aTask) ]))
		label: self workerId
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksExecutionChartItemsGroupWithScheduling [
	| completedTasks |
	completedTasks := self tasks select: #hasCompleted.
	^ (GtRrExecutionChartDataItemsGroup withAll: (completedTasks items
			collectWithIndex: [ :aTask :anIndex |
				| dataItem | 
				dataItem := GtRrExecutionChartDataItem fromTask: aTask.
				dataItem 
					propertyAt: #correctScheduling 
					put: (self 
						isTaskCorrectlyScheduledAtIndex: anIndex
						inGroup: completedTasks).
				dataItem ]))
		identifier: self workerId;
		label: self workerId
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksFirstHandoveTime [ 
	^ self tasks firstHandoverTime
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> tasksFullGcTime [
	^ self tasks fullGcTime
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> tasksIncrGcTime [
	^ self tasks incrGcTime
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksLastResultReceivedTime [ 
	^ self tasks lastResultReceivedTime
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksMachineAvailableMemoryChartItems [
	^ (self tasks 	
		inject: OrderedCollection new
		into: [ :memoryValues :aTask |
			aTask 
				resourceReportIfPresent: [ :aReport |
					memoryValues add: (GtRrTimestampedChartDataItem new
						timestamp: aReport targetReport timestamp;
						data: aReport machineAvailableMemory) ] 
				ifAbsent: [].
			memoryValues ]) asArray
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksMachineFreeMemoryChartItems [
	^ (self tasks 	
		inject: OrderedCollection new
		into: [ :memoryValues :aTask |
			aTask 
				resourceReportIfPresent: [ :aReport |
					memoryValues add: (GtRrTimestampedChartDataItem new
						timestamp: aReport targetReport timestamp;
						data: aReport machineFreeMemory) ] 
				ifAbsent: [].
			memoryValues ]) asArray
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksMachineMemoryChartItems [
	^ (self tasks 	
		inject: OrderedCollection new
		into: [ :memoryValues :aTask |
			aTask 
				resourceReportIfPresent: [ :aReport |
					memoryValues add: (GtRrTimestampedChartDataItem new
						timestamp: aReport targetReport timestamp;
						data: { 
							aReport machineAvailableMemory.
							aReport machineFreeMemory }) ] 
				ifAbsent: [].
			memoryValues ]) asArray
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> tasksStartTime [ 
	^ self tasks startTime
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> tasksTotalGCTime [ 
	^ self tasks totalGCTime
]

{ #category : #'accessing - chart data' }
GtRrWorkerExamplesReport >> tasksVmMemoryChartItems [
	^ (self tasks 	
		inject: OrderedCollection new
		into: [ :memoryValues :aTask |
			aTask 
				resourceReportIfPresent: [ :aReport |
					memoryValues add: (GtRrTimestampedChartDataItem new
						timestamp: aReport targetReport timestamp;
						data: {
							aReport vmMemorySizeAtEnd.
							aReport vmFreeMemoryAtEnd}) ] 
				ifAbsent: [].
			memoryValues ]) asArray
]

{ #category : #accessing }
GtRrWorkerExamplesReport >> taskWithId: aTaskId [
	^ self tasks 
		detect: [ :aTask |
			aTask taskId = aTaskId ]
]

{ #category : #'accessing - gc details' }
GtRrWorkerExamplesReport >> totalGCTime [ 
	^ self vmStatisticsDiffReport ifNotNil: [ :aReport | aReport totalGcTimeDiff ]
]

{ #category : #'accessing - resource report' }
GtRrWorkerExamplesReport >> vmMaximumMemorySize [
	^ self tasks vmMaximumMemorySize
]

{ #category : #'accessing - resource report' }
GtRrWorkerExamplesReport >> vmMinimumMemorySize [
	^ self tasks vmMinimumMemorySize
]

{ #category : #'accessing - resource report' }
GtRrWorkerExamplesReport >> vmStatisticsAtCompletion [
	^ self tasks vmStatisticsAtCompletion
]

{ #category : #'accessing - resource report' }
GtRrWorkerExamplesReport >> vmStatisticsAtStart [
	^ self tasks vmStatisticsAtStart
]

{ #category : #'accessing - resource report' }
GtRrWorkerExamplesReport >> vmStatisticsDiffReport [ 
	| sourceReport  targetReport |
	sourceReport := self vmStatisticsAtStart.
	targetReport := self vmStatisticsAtCompletion.
	(sourceReport isNil or: [ targetReport isNil ])
		ifTrue: [ ^ nil ].
		
	^ GtVmRuntimeStatisticsDiffReport new
		sourceReport: sourceReport;
		targetReport: targetReport;
		yourself
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
