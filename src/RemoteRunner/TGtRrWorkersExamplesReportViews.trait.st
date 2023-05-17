Trait {
	#name : #TGtRrWorkersExamplesReportViews,
	#category : #'RemoteRunner-Reports'
}

{ #category : #'gt - extensions' }
TGtRrWorkersExamplesReportViews >> gtViewCondensedExecutionTimelineFor: aView [
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
TGtRrWorkersExamplesReportViews >> gtViewCondensedTasksTimelineFor: aView [
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
TGtRrWorkersExamplesReportViews >> gtViewExecutionTimelineListFor: aView [
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
TGtRrWorkersExamplesReportViews >> gtViewMachineAvailableMemoryEvolutionFor: aView [
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
TGtRrWorkersExamplesReportViews >> gtViewMachineFreeMemoryEvolutionFor: aView [
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
TGtRrWorkersExamplesReportViews >> gtViewTasksExecutionTimelineListFor: aView [
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
