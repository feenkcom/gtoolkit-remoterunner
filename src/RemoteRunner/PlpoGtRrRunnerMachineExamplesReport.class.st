Class {
	#name : #PlpoGtRrRunnerMachineExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtRrRunnerMachineExamplesReportViews',
	#classTraits : 'TGtRrRunnerMachineExamplesReportViews classTrait',
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport class >> remoteClassName [
	^ #GtRrRunnerMachineExamplesReport
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed execution timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed tasks timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Execution timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewExecutionTimelineListFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewMachineAvailableMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine available memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineAvailableMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewMachineFreeMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine free memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineFreeMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewTasksExecutionTimelineListFor:
]

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport >> workersReport [
	^ self proxyPerform: #workersReport
]
