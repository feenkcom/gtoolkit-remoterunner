Class {
	#name : #GtRrClusterExamplesReport,
	#superclass : #Object,
	#instVars : [
		'machineReports'
	],
	#category : #'RemoteRunner-Worker'
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
GtRrClusterExamplesReport >> gtViewMachinesFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Machines';
		items: [ self machineReports ];
		column: 'Ip Address' text: [ :aMachineReport |
			aMachineReport ipAddress ];
		column: 'Workers Count' text: [ :aMachineReport |
			aMachineReport numberOfWorkers ]
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

{ #category : #printing }
GtRrClusterExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [ 
		aStream 
			print: self machineReports size;
			<< ' runner machines'].
]
