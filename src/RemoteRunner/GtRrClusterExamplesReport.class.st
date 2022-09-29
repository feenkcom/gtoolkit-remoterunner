Class {
	#name : #GtRrClusterExamplesReport,
	#superclass : #Object,
	#traits : 'TGtRrClusterExamplesReportViews',
	#classTraits : 'TGtRrClusterExamplesReportViews classTrait',
	#instVars : [
		'machineReports'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #'instance creation' }
GtRrClusterExamplesReport class >> forJob: aJob [
	| runnerMachineReports |
	runnerMachineReports := (aJob tasks groupedBy: [ :aTask |
		aTask workerIpAddress ]) associations collect: [ :assoc |
			GtRrRunnerMachineExamplesReport new
				ipAddress: assoc key ;
				workersReport: (GtRrWorkersExamplesReport 
					forTasks: assoc value);
				yourself ].
	^ self new 
		machineReports: runnerMachineReports
]

{ #category : #adding }
GtRrClusterExamplesReport >> addRunnerMachineReport: aReport [
	self machineReports add: aReport
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

{ #category : #'gt - extensions' }
GtRrClusterExamplesReport >> gtViewMachinesFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Machines Stats';
		priority: 10;
		items: [ self machineReports ];
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
		title: 'Machines Full Details';
		priority: 50;
		items: [ self machineReports ];
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
		title: 'Machines Timing';
		priority: 20;
		items: [ self machineReports ];
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

{ #category : #initialization }
GtRrClusterExamplesReport >> initialize [ 
	super initialize.
	
	machineReports := OrderedCollection new.
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

{ #category : #accessing }
GtRrClusterExamplesReport >> numberOfIdAddresses [
	^ self machineReports size
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
		'Cummulative Task Gaps' -> self taskGapsDuration.
		'Maximum Worker Tasks Start Delay' -> self workersTasksStartMaximumDelay.
		'Maximum Workers Tasks Start Delay per Machine' -> self maximumWorkersTasksStartIntervalPerMachine }
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
GtRrClusterExamplesReport >> taskGapsDuration [
	^ self machineReports 
		inject: 0 seconds 
		into: [ :total  :aMachineReport | 
			total + aMachineReport taskGapsDuration ]
]

{ #category : #accessing }
GtRrClusterExamplesReport >> workersReport [
	^ GtRrWorkersExamplesReport new 
		workers: (self machineReports flatCollect: [ :aMachineReport |
			aMachineReport workersReport workers ])
]

{ #category : #accessing }
GtRrClusterExamplesReport >> workersTasksStartMaximumDelay [
	^ self workersReport tasksStartInterval
]
