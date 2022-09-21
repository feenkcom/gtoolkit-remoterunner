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
			aMachineReport cummulativeTasksDuration ]
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
			aMachineReport tasksStartInterval ]
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

{ #category : #printing }
GtRrClusterExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [ 
		aStream 
			print: self machineReports size;
			<< ' runner machines'].
]

{ #category : #accessing }
GtRrClusterExamplesReport >> workersReport [
	^ GtRrWorkersExamplesReport new 
		workers: (self machineReports flatCollect: [ :aMachineReport |
			aMachineReport workersReport workers ])
]
