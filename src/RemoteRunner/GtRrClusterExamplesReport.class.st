Class {
	#name : #GtRrClusterExamplesReport,
	#superclass : #Object,
	#traits : 'TGtRrClusterExamplesReportViews',
	#classTraits : 'TGtRrClusterExamplesReportViews classTrait',
	#instVars : [
		'machineReports',
		'jobProperties'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #'instance creation' }
GtRrClusterExamplesReport class >> forJob: aJob [
	| runnerMachineReports |
	runnerMachineReports := (aJob tasks groupedBy: [ :aTask |
		aTask workerMachineId ]) associations collect: [ :assoc |
			GtRrRunnerMachineExamplesReport new
				machineId: assoc key ;
				machineType: assoc value first workerMachineType;
				"machineCores: assoc value first halt;"
				ipAddress: assoc value first workerIpAddress;
				workersReport: (GtRrWorkersExamplesReport 
					forTasks: assoc value);
				yourself ].
	^ self new 
		machineReports: runnerMachineReports;
		jobProperties: aJob properties
]

{ #category : #adding }
GtRrClusterExamplesReport >> addRunnerMachineReport: aReport [
	self machineReports add: aReport
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> avegareFullGcDuration [
	| numberOfFullGCs |
	numberOfFullGCs := self numberOfFullGCs.
	(numberOfFullGCs isNil or: [
		numberOfFullGCs = 0]) ifTrue: [ ^ nil].
		
	^ self fullGcDuration / numberOfFullGCs
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> avegareIncrementalGcDuration [
	^ self incrGcDuration / self numberOfIncrementalGCs
]

{ #category : #accessing }
GtRrClusterExamplesReport >> cummulativeGapBetweenEndTimeAndReceivingResults [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :total  :aMachineReport | 
			total + aMachineReport cummulativeGapBetweenEndTimeAndReceivingResults ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> cummulativeGapBetweenHandoverAndStartTime [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :total  :aMachineReport | 
			total + aMachineReport cummulativeGapBetweenHandoverAndStartTime ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> cummulativeTasksDuration [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :total  :aMachineReport | 
			total + aMachineReport cummulativeTasksDuration ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> cummulativeTasksDurationOnRunner [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :total  :aMachineReport | 
			total + aMachineReport cummulativeTasksDurationOnRunner ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> fullGcDuration [
	^ self fullGcTime ifNotNil: [ :aTimeInMilliseconds |
		aTimeInMilliseconds milliSeconds ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> fullGcTime [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine fullGcTime ]
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewMachineMemoryStatsFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Machines memory';
		priority: 25;
		items: [ self machineReports ];
		column: 'Machine Type' text: [ :aMachineReport |
			aMachineReport machineType ifNil: [ '-' ] ];
		column: 'Ip Address' text: [ :aMachineReport |
			aMachineReport ipAddress ];
		column: 'Workers Count' text: [ :aMachineReport |
			aMachineReport numberOfWorkers ];
		column: 'Total Memory' text: [ :aMachineReport |
			aMachineReport machineTotalMemory 
				ifNotNil: [ :aValue | aValue humanReadableIsqByteSize ] ];
		column: 'Minimum Available Memory' text: [ :aMachineReport |
			aMachineReport machineMinimumAvailableMemory 
				ifNotNil: [ :aValue | aValue humanReadableIsqByteSize ] ];
		column: 'Maximum (initial) Available Memory' text: [ :aMachineReport |
			aMachineReport machineMaximumAvailableMemory 
				ifNotNil: [ :aValue | aValue humanReadableIsqByteSize ] ];
		column: 'Total Consumed Memory' text: [ :aMachineReport |
			aMachineReport machineTotalConsumedMemory
				ifNotNil: [ :aValue | aValue humanReadableIsqByteSize ] ];
		column: 'Avegare Consumed Memory per Worker' text: [ :aMachineReport |
			aMachineReport machineTotalConsumedMemoryPerWorker 
				ifNotNil: [ :aValue | aValue humanReadableIsqByteSize ] ]
			
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewMachinesFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Machines stats';
		priority: 10;
		items: [ self machineReports ];
		column: 'Machine Id' text: [ :aMachineReport |
			aMachineReport machineId ifNil: [ '-' ] ];
		column: 'Machine Type' text: [ :aMachineReport |
			aMachineReport machineType ifNil: [ '-' ] ];
		column: 'Ip Address' text: [ :aMachineReport |
			aMachineReport ipAddress ];
		column: 'Workers Count' text: [ :aMachineReport |
			aMachineReport numberOfWorkers ];
		column: 'Checks Count' text: [ :aMachineReport |
			aMachineReport numberOfExamples ];
		column: 'Cummulative Duration' text: [ :aMachineReport |
			aMachineReport cummulativeTasksDuration ];
		 column: 'Cummulative Task Gaps' text: [ :aMachineReport | aMachineReport taskGapsDuration ];
		 column: 'GC Duration' text: [ :aMachineReport | 
			aMachineReport totalGCTime 
				ifNil: [ '-' ] 
				ifNotNil: [ :aGCTime | Duration milliSeconds: aGCTime ]]
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewMachinesFullDetailsFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Machines full details';
		priority: 50;
		items: [ self machineReports ];
		column: 'Id' text: [ :aMachineReport |
			aMachineReport machineId ];
		column: 'Type' text: [ :aMachineReport |
			aMachineReport machineType ];
		column: 'Ip Address' text: [ :aMachineReport |
			aMachineReport ipAddress ] width: 100;
		column: 'Workers Count' text: [ :aMachineReport |
			aMachineReport numberOfWorkers ] width: 100;
		column: 'Tasks Count' text: [ :aMachineReport |
			aMachineReport numberOfTasks ] width: 100;
		column: 'Checks Count' text: [ :aMachineReport |
			aMachineReport numberOfExamples ] width: 100;
		column: 'Tasks First Start Time' text: [ :aMachineReport |
			aMachineReport tasksStartTime printToSeconds ];
		column: 'Tasks Execution Interval (runner)' text: [ :aMachineReport |
			aMachineReport tasksExecutionIntervalOnRunner ];
		column: 'Workers Start Interval' text: [ :aMachineReport |
			aMachineReport tasksStartInterval ];
		column: 'Cummulative Duration (worker)' text: [ :aMachineReport |
			aMachineReport cummulativeTasksDuration ];
		column: 'Cummulative Duration (runner)' text: [ :aMachineReport |
			aMachineReport cummulativeTasksDurationOnRunner ];
		column: 'Cummulative Task Gaps' text: [ :aMachineReport | aMachineReport taskGapsDuration ];
		column: 'GC Duration' text: [ :aMachineReport | 
			aMachineReport totalGCTime 
				ifNil: [ '-' ] 
				ifNotNil: [ :aGCTime | Duration milliSeconds: aGCTime ]]
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewMachinesTimingFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Machines timing';
		priority: 20;
		items: [ self machineReports ];
		column: 'Machine Type' text: [ :aMachineReport |
			aMachineReport machineType ifNil: [ '-' ] ];
		column: 'Ip Address' text: [ :aMachineReport |
			aMachineReport ipAddress ];
		column: 'Workers Count' text: [ :aMachineReport |
			aMachineReport numberOfWorkers ];
		column: 'Tasks First Start Time' text: [ :aMachineReport |
			aMachineReport tasksStartTime printToSeconds ];
		column: 'Tasks Last End Time' text: [ :aMachineReport |
			aMachineReport tasksEndTime printToSeconds ];
		column: 'Workers Start Interval' text: [ :aMachineReport |
			aMachineReport tasksStartInterval ];
		column: 'GC Duration' text: [ :aMachineReport | 
			aMachineReport totalGCTime 
				ifNil: [ '-' ] 
				ifNotNil: [ :aGCTime | Duration milliSeconds: aGCTime ]]
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewOverviewFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Overview';
		priority: 60;
		items: [ self overviewData ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewWorkersStatusFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers stats';
		priority: 65;
		object: [ self workersReport ];
		view: #gtViewWorkersFor:
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewWorkersVsCoresFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'Workers vs Cores';
		priority: 50;
		items: [ self workersVsCoresData ];
		column: 'Machine Type' text: [ :aDictionary |
			aDictionary at: #machineType ];
		column: 'Workers Count' text: [ :aDictionary |
			aDictionary at: #workersCount ];
		column: 'Corrected Cores Count' text: [ :aDictionary |
			aDictionary at: #correctedCoreCount ];
		column: 'Cores Count' text: [ :aDictionary |
			aDictionary at: #coreCount ];
		column: 'Diff' text: [ :aDictionary |
			aDictionary at: #diff ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> incrGcDuration [
	^ self incrGcTime ifNotNil: [ :aTimeInMilliseconds |
		aTimeInMilliseconds milliSeconds ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> incrGcTime [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine incrGcTime ]
]

{ #category : #initialization }
GtRrClusterExamplesReport >> initialize [ 
	super initialize.
	
	machineReports := OrderedCollection new.
]

{ #category : #accessing }
GtRrClusterExamplesReport >> jobProperties [
	^ jobProperties
]

{ #category : #accessing }
GtRrClusterExamplesReport >> jobProperties: anObject [
	jobProperties := anObject
]

{ #category : #accessing }
GtRrClusterExamplesReport >> machineReports [

	^ machineReports
]

{ #category : #accessing }
GtRrClusterExamplesReport >> machineReports: aCollectionOfReports [

	machineReports := aCollectionOfReports
]

{ #category : #accessing }
GtRrClusterExamplesReport >> machineWithIpAddress: anIpAddress [
	^ self machineReports 
		detect: [ :aMachine |
			aMachine ipAddress = anIpAddress ]
]

{ #category : #'accessing - chart data' }
GtRrClusterExamplesReport >> machinesExecutionChartItems [
	^ self machineReports
		collect: [ :aMachineReport |
			GtRrExecutionChartDataItem fromMachine: aMachineReport ] 
		as: Array
]

{ #category : #accessing }
GtRrClusterExamplesReport >> maximumWorkersTasksStartIntervalPerMachine [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :maximumStartInterval  :aMachineReport | 
			| currentStartInterval |
			currentStartInterval := aMachineReport tasksStartInterval.
			currentStartInterval > maximumStartInterval 
				ifTrue: [ currentStartInterval ]
				ifFalse: [ maximumStartInterval  ] ] 
]

{ #category : #accessing }
GtRrClusterExamplesReport >> numberOfExamples [
	^ self machineReports
		sumNumbers: [ :aWorkerReport | aWorkerReport numberOfExamples ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> numberOfFullGCs [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine numberOfFullGCs ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> numberOfIdAddresses [
	^ self machineReports size
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> numberOfIncrementalGCs [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine numberOfIncrementalGCs ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> numberOfTasks [
	^ self machineReports
		sumNumbers: [ :aWorkerReport | aWorkerReport numberOfTasks ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> numberOfWorkers [
	^ self machineReports sumNumbers: [ :aWorkerReport | aWorkerReport numberOfWorkers ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> overviewData [
	^ {
		'Number of IP addresses' -> self numberOfIdAddresses.
		'Number of workers' -> self numberOfWorkers.
		'Number of tasks' -> self numberOfTasks.
		'Number of tests' -> self numberOfExamples .
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
		'Maximum Workers Tasks Start Delay per Machine' -> self maximumWorkersTasksStartIntervalPerMachine.
		'Workers Tasks Competion Delay' -> self workersTasksCompletionDelay}
]

{ #category : #printing }
GtRrClusterExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [ 
		aStream 
			print: self machineReports size;
			<< ' runner machines'].
]

{ #category : #accessing }
GtRrClusterExamplesReport >> sumMachineValueWithNil: aBlock [
	^ self machineReports gtSumWithNilValues: aBlock
]

{ #category : #accessing }
GtRrClusterExamplesReport >> taskGapsDuration [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :total  :aMachineReport | 
			total + aMachineReport taskGapsDuration ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> tasksFullGcTime [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine tasksFullGcTime ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> tasksIncrGcTime [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine tasksIncrGcTime ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> tasksTotalGCTime [
	^ self sumMachineValueWithNil: [ :aMachine | aMachine tasksTotalGCTime ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> totalGCDuration [
	^ self totalGCTime ifNotNil: [ :aTimeInMilliseconds |
		aTimeInMilliseconds milliSeconds ]
]

{ #category : #'accessing - gc details' }
GtRrClusterExamplesReport >> totalGCTime [ 
	^ self sumMachineValueWithNil: [ :aMachine | aMachine totalGCTime ]
]

{ #category : #'accessing - resource report' }
GtRrClusterExamplesReport >> vmAverageMemorySize [
	^ self workersReport vmAverageMemorySize
]

{ #category : #'accessing - resource report' }
GtRrClusterExamplesReport >> vmMaximumMemorySize [
	^ self workersReport vmMaximumMemorySize
]

{ #category : #'accessing - resource report' }
GtRrClusterExamplesReport >> vmMinimumMemorySize [
	^ self workersReport vmMinimumMemorySize
]

{ #category : #accessing }
GtRrClusterExamplesReport >> workersReport [
	^ GtRrWorkersExamplesReport new 
		workers: (self machineReports flatCollect: [ :aMachineReport |
			aMachineReport workersReport workers ])
]

{ #category : #accessing }
GtRrClusterExamplesReport >> workersTasksCompletionDelay [
	^ self workersReport  tasksCompletionDelay
]

{ #category : #accessing }
GtRrClusterExamplesReport >> workersTasksStartMaximumDelay [
	^ self workersReport tasksStartInterval
]

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> workersVsCoresData [

	^ machineReports collect: [ :machine | 
		| machineType cc ccc diff |
		machineType := GtAwsAmazonWebServices default instanceTypes 
			at: machine machineType
			ifAbsent: [].
		ccc := machineType ifNotNil: #correctedCoreCount.
		cc := machineType ifNotNil: #coreCount.
		diff := (ccc notNil and: [ cc notNil ]) 
			ifTrue: [ (ccc - machine numberOfWorkers) abs + (ccc - cc) abs ]
			ifFalse: [ 0 ].
		Dictionary new
			at: #machineType put: (machineType ifNil: [ '-' ]);
			at: #workersCount put: machine numberOfWorkers;
			at: #correctedCoreCount put: (machineType ifNil: [ '-' ] ifNotNil: #correctedCoreCount);
			at: #coreCount put: (machineType ifNil: [ '-' ] ifNotNil: #coreCount);
			at: #diff put: diff;
			yourself ].
]
