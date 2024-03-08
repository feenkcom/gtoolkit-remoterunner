Trait {
	#name : #TGtRrClusterExamplesReportViews,
	#category : #'RemoteRunner-Reports'
}

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed execution timeline (runner times)';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed tasks timeline';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedTasksTimelineWithWorkerTimesFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Condensed tasks timeline  (worker times)';
		priority: 45.1;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineWithWorkerTimesFor: 
]

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution timeline';
		priority: 30;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self machinesExecutionChartItems;
				selectionTransformation: [ :anItem |
					self machineWithIpAddress:  anItem identifier ] ]
]
