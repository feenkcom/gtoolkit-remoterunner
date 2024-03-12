Trait {
	#name : #TGtRrClusterExamplesReportViews,
	#category : #'RemoteRunner-Reports'
}

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedExecutionTimelineFor:aView [
	<gtView>
	"Every line shows the execution of woker. There is no distinction between tasks."
	^ aView forward
		title: 'Condensed timeline';
		priority: 35;
		object: [ self workersReport];
		view: #gtViewCondensedExecutionTimelineFor:
]

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedTasksTimelineFor:  aView [
	<gtView>
	"Every line is composed from the tasks executed by a worker. The start/end times are from the runner's perspective: handover times/results received time. Normally there should not be any large gaps at all. "
	^ aView forward
		title: 'Condensed tasks timeline (runner times)';
		priority: 45;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineFor: 
]

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedTasksTimelineWithWorkerTimesAndSchedulingFor: aView [
	<gtView>
	"Every line is composed from the tasks executed by a worker. The start/end times are from the worker's perspective. Red tasks are tasks that have a wrong scheduling."
	^ aView forward
		title: 'Condensed tasks timeline (worker times - scheduling)';
		priority: 45.2;
		object: [ self workersReport];
		view: #gtViewCondensedTasksTimelineWithWorkerTimesAndSchedulingFor:
]

{ #category : #'gt - extensions' }
TGtRrClusterExamplesReportViews >> gtViewCondensedTasksTimelineWithWorkerTimesFor: aView [
	<gtView>
	"Every line is composed from the tasks executed by a worker. The start/end times are from the worker's perspective."
	^ aView forward
		title: 'Condensed tasks timeline (worker times)';
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
