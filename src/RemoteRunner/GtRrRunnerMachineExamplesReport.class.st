Class {
	#name : #GtRrRunnerMachineExamplesReport,
	#superclass : #Object,
	#traits : 'TGtRrRunnerMachineExamplesReportViews',
	#classTraits : 'TGtRrRunnerMachineExamplesReportViews classTrait',
	#instVars : [
		'ipAddress',
		'workersReport',
		'machineId',
		'machineType',
		'machineCores',
		'machineRegion',
		'awsWeightedCapacity'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> avegareFullGcDuration [
	| numberOfFullGCs |
	numberOfFullGCs := self numberOfFullGCs.
	(numberOfFullGCs isNil or: [
		numberOfFullGCs = 0]) ifTrue: [ ^ nil].
		
	^ self fullGcDuration / numberOfFullGCs
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> avegareIncrementalGcDuration [
	^ self incrGcDuration / self numberOfIncrementalGCs
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> awsWeightedCapacity [
	^ awsWeightedCapacity
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> awsWeightedCapacity: anObject [
	awsWeightedCapacity := anObject
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> cummulativeGapBetweenEndTimeAndReceivingResults [
	^ self workersReport cummulativeGapBetweenEndTimeAndReceivingResults
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> cummulativeGapBetweenHandoverAndStartTime [
	^ self workersReport cummulativeGapBetweenHandoverAndStartTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> cummulativeTasksDuration [
	^ self workersReport cummulativeTasksDuration
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> cummulativeTasksDurationOnRunner [
	^ self workersReport cummulativeTasksDurationOnRunner
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> description [
	^ self ipAddress
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> fullGcDuration [
	^ self fullGcTime ifNotNil: [ :aTimeInMilliseconds |
		aTimeInMilliseconds milliSeconds ]
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> fullGcTime [
	^ self workersReport fullGcTime
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewOverviewFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Overview';
		priority: 60;
		items: [ self overviewData ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewWorkersFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers stats';
		priority: 10;
		object: [ self workersReport ];
		view: #gtViewWorkersFor:
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewWorkersGCStatsFor:   aView [
	<gtView>
	
	^ aView forward
		title: 'Workers GC';
		priority: 47;
		object: [ self workersReport];
		view: #gtViewWorkersGCStatsFor: 
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewWorkersTimingFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers timing';
		priority: 20;
		object: [ self workersReport ];
		view: #gtViewWorkersTimingFor:
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> incrGcDuration [
	^ self incrGcTime ifNotNil: [ :aTimeInMilliseconds |
		aTimeInMilliseconds milliSeconds ]
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> incrGcTime [
	^ self workersReport incrGcTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> ipAddress [

	^ ipAddress
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> ipAddress: anIpAddressString [

	ipAddress := anIpAddressString
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineCores [
	^ machineCores
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineCores: anObject [
	machineCores := anObject
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineDefinedVsAvailableMemoryDescription [
	| definedMemory availableMemory |
	definedMemory  := self machineTotalDefinedMemory.
	availableMemory := self machineTotalMemory .
	(definedMemory isNil or: [availableMemory isNil]) ifTrue: [ ^ '-' ].
	^ String streamContents: [ :aStream |
		| memoryDifference|
		memoryDifference := definedMemory- availableMemory.
		aStream nextPutAll: memoryDifference humanReadableIsqByteSize.
		aStream nextPutAll: ' ('.
		aStream nextPutAll: ((Percentage 
			with: memoryDifference/definedMemory) displayStringFormat: '#0.0').
		aStream nextPutAll: ')']
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineId [
	^ machineId
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineId: anObject [
	machineId := anObject
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> machineMaximumAvailableMemory [
	^ self workersReport machineMaximumAvailableMemory
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> machineMinimumAvailableMemory [
	^ self workersReport machineMinimumAvailableMemory
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineRegion [
	^ machineRegion
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineRegion: aRegionName [
	machineRegion := aRegionName
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> machineTotalConsumedMemory [
	| totalMemory minimumAvailableMemory|
	totalMemory := self machineTotalMemory.
	minimumAvailableMemory := self machineMinimumAvailableMemory.
	(totalMemory isNil or: [minimumAvailableMemory isNil]) ifTrue: [ ^ nil ].
	
	^ totalMemory - minimumAvailableMemory
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> machineTotalConsumedMemoryPerWorker [
	| totalMemory minimumAvailableMemory|
	totalMemory := self machineTotalMemory.
	minimumAvailableMemory := self machineMinimumAvailableMemory.
	(totalMemory isNil or: [minimumAvailableMemory isNil]) ifTrue: [ ^ nil ].
	
	^ ((totalMemory - minimumAvailableMemory) / self numberOfWorkers) asInteger
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> machineTotalDefinedMemory [
	^ (GtAwsAmazonWebServices default ec2 instanceTypes 
			at: (self machineType )
			ifPresent: [ :anInstanceType | 
				anInstanceType totalMemory]
			ifAbsent: [ nil ])
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> machineTotalMemory [
	^ self workersReport machineTotalMemory
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineType [
	^ machineType
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> machineType: anObject [
	machineType := anObject
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> numberOfExamples [
	^ self workersReport numberOfExamples
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> numberOfFullGCs [
	^ self workersReport numberOfFullGCs
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> numberOfIncrementalGCs [
	^ self workersReport numberOfIncrementalGCs
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> numberOfTaskRetries [
	^ self workersReport numberOfTaskRetries
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> numberOfTasks [
	^ self workersReport numberOfTasks
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> numberOfWorkers [
	^ self workersReport workers size
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> overviewData [
	^ {
		'Number of workers' -> self numberOfWorkers.
		'Weighted Capacity' -> (self awsWeightedCapacity ifNil: [ '-' ]).
		'Number of tasks' -> self numberOfTasks.
		'Number of test runs' -> self numberOfExamples .
		'Number of task retries' -> self numberOfTaskRetries.
		'Cummulative Tasks Duration (on workers)' -> self cummulativeTasksDuration.
		'Cummulative Tasks Duration (on runner)' -> self cummulativeTasksDurationOnRunner.
		'Tasks Duration Runner - Worker Difference' -> (self cummulativeTasksDurationOnRunner - self cummulativeTasksDuration).
		'Cummulative Task Gaps Between Consecutive Tasks' -> self taskGapsDuration.
		'Average Task Gap Between Consecutive Tasks' -> (self taskGapsDuration / self numberOfTasks).
		'Cummulative Task Gaps Between Handover and Start Time' -> self cummulativeGapBetweenHandoverAndStartTime.
		'Cummulative Task Gaps Results Retrieved and End Time' -> self cummulativeGapBetweenEndTimeAndReceivingResults.
		
		'Number of Full GCs' -> self numberOfFullGCs.
		'Number of Incremental GCs' -> self numberOfIncrementalGCs.
		'Average Full GC Duration' -> self avegareFullGcDuration. 
		'Average Incremental GC Duration' -> self avegareIncrementalGcDuration.
		'Total GC Time (workers)' -> self totalGCDuration.
		'Full GC Time (workers)' -> self fullGcDuration. 
		'Incremental GC Time (workers)' -> self incrGcDuration.
		'Total GC Time (tasks)' -> self tasksTotalGCTime milliSeconds.
		'Full GC Time (tasks)' -> self tasksFullGcTime milliSeconds.
		'Incremental GC Time (tasks)' -> self tasksIncrGcTime milliSeconds.
		'Maximum VM Memory Size' -> self vmMaximumMemorySize humanReadableIsqByteSize.
		'Minimum VM Memory Size' -> self vmMinimumMemorySize humanReadableIsqByteSize.
		'Average VM Memory Size' -> self vmAverageMemorySize humanReadableIsqByteSize . 
		'Maximum VM Memory Size Increase' -> (self vmMaximumMemorySize- self vmMinimumMemorySize) humanReadableIsqByteSize.
		'Maximum Worker Tasks Start Delay' -> self workersTasksStartMaximumDelay.
		'Workers Tasks Competion Delay' -> self workersTasksCompletionDelay.
		'Machine Region' -> self machineRegion.
		'Machine Type' -> self machineType.
		'Machine Memory Info' -> self machineTotalMemory humanReadableIsqByteSize.
		'Machine Memory Defined' -> self machineTotalDefinedMemory humanReadableIsqByteSize.
		'Memory Difference: Available - Defined' -> self machineDefinedVsAvailableMemoryDescription .
		'Machine Cores' -> self machineCores}
]

{ #category : #printing }
GtRrRunnerMachineExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [ 
		aStream 
			print: self ipAddress;
			<< ', ';
			print: self numberOfWorkers;
			<< ' workers'].
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> taskGapsDuration [
	^ self workersReport taskGapsDuration
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksEndTime [
	^ self tasksLastEndTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksExecutionInterval [
	^ self workersReport tasksExecutionInterval
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksExecutionIntervalOnRunner [
	^ self workersReport tasksExecutionIntervalOnRunner
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksFirstHandoveTime [
	^ self workersReport tasksFirstHandoveTime
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> tasksFullGcTime [
	^ self workersReport tasksFullGcTime
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> tasksIncrGcTime [
	^ self workersReport tasksIncrGcTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksLastEndTime [
	^ self workersReport tasksLastEndTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksLastResultReceivedTime [
	^ self workersReport tasksLastResultReceivedTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksLastStartTime [
	^ self workersReport tasksLastStartTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksStartInterval [
	^ self workersReport tasksStartInterval
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksStartTime [
	^ self workersReport tasksStartTime
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> tasksTotalGCTime [
	^ self workersReport tasksTotalGCTime
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> totalGCDuration [
	^ self totalGCTime ifNotNil: [ :aTimeInMilliseconds |
		aTimeInMilliseconds milliSeconds ]
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> totalGCPercentage [
	^ self workersReport totalGCPercentage
]

{ #category : #'accessing - gc details' }
GtRrRunnerMachineExamplesReport >> totalGCTime [
	^ self workersReport totalGCTime
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> vmAverageMemorySize [
	^ self workersReport vmAverageMemorySize
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> vmMaximumMemorySize [
	^ self workersReport vmMaximumMemorySize
]

{ #category : #'accessing - resource report' }
GtRrRunnerMachineExamplesReport >> vmMinimumMemorySize [
	^ self workersReport vmMinimumMemorySize
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport [

	^ workersReport
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport: anObject [

	workersReport := anObject
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersTasksCompletionDelay [
	^ self workersReport  tasksCompletionDelay
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersTasksStartMaximumDelay [
	^ self workersReport tasksStartInterval
]
