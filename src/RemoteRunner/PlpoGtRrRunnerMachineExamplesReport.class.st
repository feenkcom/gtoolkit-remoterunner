Class {
	#name : #PlpoGtRrRunnerMachineExamplesReport,
	#superclass : #PharoLinkProxyObject,
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
		title: 'Condensed Execution Timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed Tasks Timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Execution Timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewExecutionTimelineListFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewMachineAvailableMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine Available Memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineAvailableMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewMachineFreeMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Machine Free Memory';
		priority: 55;
		object: [ self workersReport];
		view: #gtViewMachineFreeMemoryEvolutionFor: 
]

{ #category : #'gt - extensions' }
PlpoGtRrRunnerMachineExamplesReport >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Tasks Timeline';
		priority: 25;
		object: [ self workersReport];
		view: #gtViewTasksExecutionTimelineListFor:
]

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport >> workersReport [
	^ self proxyPerform: #workersReport
]
