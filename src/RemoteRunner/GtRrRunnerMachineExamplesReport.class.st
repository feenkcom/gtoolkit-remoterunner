Class {
	#name : #GtRrRunnerMachineExamplesReport,
	#superclass : #Object,
	#traits : 'TGtRrRunnerMachineExamplesReportViews',
	#classTraits : 'TGtRrRunnerMachineExamplesReportViews classTrait',
	#instVars : [
		'ipAddress',
		'workersReport',
		'machineId',
		'machineType'
	],
	#category : #'RemoteRunner-Reports'
}

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
GtRrRunnerMachineExamplesReport >> fullGcTime [
	^ self workersReport fullGcTime
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed execution timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed tasks timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Execution timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewExecutionTimelineListFor: 
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewMachineAvailableMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine available memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineAvailableMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewMachineFreeMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine free memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineFreeMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewTasksExecutionTimelineListFor:
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
GtRrRunnerMachineExamplesReport >> gtViewWorkersTimingFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers timing';
		priority: 20;
		object: [ self workersReport ];
		view: #gtViewWorkersTimingFor:
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
GtRrRunnerMachineExamplesReport >> numberOfTasks [
	^ self workersReport numberOfTasks
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> numberOfWorkers [
	^ self workersReport workers size
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
GtRrRunnerMachineExamplesReport >> totalGCTime [
	^ self workersReport totalGCTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport [

	^ workersReport
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport: anObject [

	workersReport := anObject
]
