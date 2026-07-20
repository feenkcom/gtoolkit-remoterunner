Trait {
	#name : #TGtRrRunnerMachineExamplesReportViews,
	#category : 'RemoteRunner-Reports'
}

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed execution timeline (runner times)';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed tasks timeline (runner times)';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Execution timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewExecutionTimelineListFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewMachineAvailableMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine available memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineAvailableMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewMachineFreeMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine free memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineFreeMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks timeline (runner times)';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewTasksExecutionTimelineListFor:
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewTasksExecutionTimelineWorkerTimesFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks timeline (worker times)';
		priority: 25.1;
		object: [ self workersReport];
		view: #gtViewTasksExecutionTimelineWorkerTimesFor:
]
