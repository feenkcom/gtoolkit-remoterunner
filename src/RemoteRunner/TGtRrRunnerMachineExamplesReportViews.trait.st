Trait {
	#name : #TGtRrRunnerMachineExamplesReportViews,
	#category : #'RemoteRunner-Reports'
}

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed Execution Timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed Tasks Timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Execution Timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewExecutionTimelineListFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewMachineAvailableMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine Available Memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineAvailableMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewMachineFreeMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine Free Memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineFreeMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
TGtRrRunnerMachineExamplesReportViews >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks Timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewTasksExecutionTimelineListFor:
]
