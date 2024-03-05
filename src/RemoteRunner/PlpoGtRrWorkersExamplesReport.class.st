Class {
	#name : #PlpoGtRrWorkersExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtRrWorkersExamplesReportViews',
	#classTraits : 'TGtRrWorkersExamplesReportViews classTrait',
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
		title: 'Condensed execution timeline';
		priority: 35;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				colorComputation: [ Color darkGray ];
				configureWithMinimalDetails;
				executions: self workersExecutionChartItems ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewCondensedTasksTimelineFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Condensed tasks timeline';
		priority: 45;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withColorBasedOnScheduling;
				configureWithMinimalDetails;
				enabledGroupsInRow;
				executions: self workersTasksExecutionChartItemsGroupWithScheduling ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self workersExecutionChartItems;
				selectionTransformation: [ :anItem |
					self workerWithId:  anItem identifier ] ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewMachineAvailableMemoryEvolutionFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Machine available memory';
		priority: 50;
		stencil: [ 
			| data |
				
			data := GtPlotterDataGroup new 
				values:(self workersTasksMachineAvailableMemoryChartItems
					sorted: [ :anItem | anItem timestamp ] ascending).
				
			GtPlotterLineChart new
				with: data;
				valueX: [ :e | e timestamp ];
				scaleX: GtPlotterTimeScale new;
				labelFormatX: [ :e | e asTime ];
				titleX: 'Time';
				ticksX: 5;
				valueY: [ :e | e data ];
				scaleY: GtPlotterLinearScale new;
				labelFormatY: [ :e | e humanReadableIsqByteSize ];
				titleY: 'Machine Available Memory';
				ticksY: 10. ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewMachineFreeMemoryEvolutionFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Machine free memory';
		priority: 50;
		stencil: [ 
			| data |
				
			data := GtPlotterDataGroup new 
				values:(self workersTasksMachineFreeMemoryChartItems
					sorted: [ :anItem | anItem timestamp ] ascending).
				
			GtPlotterLineChart new
				with: data;
				valueX: [ :e | e timestamp ];
				scaleX: GtPlotterTimeScale new;
				labelFormatX: [ :e | e asTime ];
				titleX: 'Time';
				ticksX: 5;
				valueY: [ :e | e data ];
				scaleY: GtPlotterLinearScale new;
				labelFormatY: [ :e | e humanReadableIsqByteSize ];
				titleY: 'Machine Free Memory';
				ticksY: 10. ]
]

{ #category : #'gt - extensions' }
PlpoGtRrWorkersExamplesReport >> gtViewTasksExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Tasks timeline';
		priority: 20;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withColorBasedOnScheduling;
				enabledGroupsInRow;
				executions: self workersTasksExecutionChartItemsGroupWithScheduling;
				selectionTransformation: [ :anItem |
					self workerWithId:  anItem identifier ] ]
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

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksMachineAvailableMemoryChartItems [
	^ self proxyPerformSerialized: #workersTasksMachineAvailableMemoryChartItems
]

{ #category : #'accessing - chart data' }
PlpoGtRrWorkersExamplesReport >> workersTasksMachineFreeMemoryChartItems [
	^ self proxyPerformSerialized: #workersTasksMachineFreeMemoryChartItems
]

{ #category : #accessing }
PlpoGtRrWorkersExamplesReport >> workerWithId: aWorkerId [
	^ self 
		proxyPerform:  #workerWithId: 
		withPrimitiveArguments: {aWorkerId} 
]
