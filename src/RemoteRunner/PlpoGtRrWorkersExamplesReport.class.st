Class {
	#name : #PlpoGtRrWorkersExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport class >> remoteClassName [
	^ #GtRrWorkersExamplesReport
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewCondensedExecutionTimelineFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Condensed Execution Timeline';
		priority: 35;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withDescriptionAsLabel;
				colorComputation: [ Color darkGray ];
				configureWithMinimalDetails;
				executions: self workersExecutionChartItems ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewCondensedTasksTimelineFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Condensed Tasks Timeline';
		priority: 45;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withDescriptionAsLabel;
				withColorBasedOnScheduling;
				configureWithMinimalDetails;
				enabledGroupsInRow;
				executions: self workersTasksExecutionChartItemsGroupWithScheduling ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withDescriptionAsLabel;
				executions: self workersExecutionChartItems;
				selectionTransformation: [ :anItem |
					self workerWithId:  anItem identifier ] ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Tasks Timeline';
		priority: 20;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withDescriptionAsLabel;
				withColorBasedOnScheduling;
				enabledGroupsInRow;
				executions: self workersTasksExecutionChartItemsGroupWithScheduling;
				selectionTransformation: [ :anItem |
					self workerWithId:  anItem identifier ] ]
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workerWithId: aWorkerId [
	^ self 
		proxyPerform:  #workerWithId: 
		withPrimitiveArguments: {aWorkerId} 
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersExecutionChartItems [
	^ self proxyPerformSerialized: #workersExecutionChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksExecutionChartItemsGroupWithScheduling [
	^ self 
		proxyPerformSerialized: #workersTasksExecutionChartItemsGroupWithScheduling
]
