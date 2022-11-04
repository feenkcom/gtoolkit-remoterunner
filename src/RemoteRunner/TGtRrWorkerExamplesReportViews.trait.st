Trait {
	#name : #TGtRrWorkerExamplesReportViews,
	#category : #'RemoteRunner-Reports'
}

{ #category : #'gt - extensions' }
TGtRrWorkerExamplesReportViews >> gtViewDurationExecutionChartListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Duration Chart';
		priority: 11;
		stencil: [
			GtRrTasksExecutionHorizontalChartStencil new 
				taskItems: self tasksExecutionChartItems ]
]

{ #category : #'gt - extensions' }
TGtRrWorkerExamplesReportViews >> gtViewDurationSortedChartListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Duration Chart (sorted)';
		priority: 10;
		stencil: [
			GtRrTasksExecutionHorizontalChartStencil new 
				taskItems: (self tasksExecutionChartItems
					sorted: [ :aTaskItem | aTaskItem duration ] descending) ]
]

{ #category : #'gt - extensions' }
TGtRrWorkerExamplesReportViews >> gtViewExecutionTimelineListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline';
		priority: 25;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				executions: self tasksExecutionChartItems;
				selectionTransformation: [ :anItem |
					self taskWithId:  anItem identifier ] ]
]

{ #category : #'gt - extensions' }
TGtRrWorkerExamplesReportViews >> gtViewExecutionTimelineWithSchedulingFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Execution Timeline (with scheduling)';
		priority: 45;
		stencil: [ 
			GtRrExecutionHorizontalChartStencil new 
				withColorBasedOnScheduling;
				executions: self tasksExecutionChartItemsGroupWithScheduling;
				selectionTransformation: [ :anItem |
					self taskWithId:  anItem identifier ] ]
]

{ #category : #'gt - extensions' }
TGtRrWorkerExamplesReportViews >> gtViewMachineAvailableMemoryEvolutionFor:  aView [
	<gtView>
	
	^ aView explicit
		title: 'Machine Available Memory';
		priority: 50;
		stencil: [ 
			| data |
				
			data := GtPlotterDataGroup new 
				values:(self tasksMachineAvailableMemoryChartItems
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
TGtRrWorkerExamplesReportViews >> gtViewMachineFreeMemoryEvolutionFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Machine Free Memory';
		priority: 50;
		stencil: [ 
			| data |
				
			data := GtPlotterDataGroup new 
				values:(self tasksMachineFreeMemoryChartItems
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
TGtRrWorkerExamplesReportViews >> gtViewVmMemoryEvolutionFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'VM Memory';
		priority: 45;
		stencil: [ 
			| values vmMemory freeMemory data |
				
			values := self tasksVmMemoryChartItems.
			vmMemory := GtPlotterDataGroup new 
				values: OrderedCollection new.
			freeMemory := GtPlotterDataGroup new 
				values: OrderedCollection new.
				
			values do: [ :aSignal |
				vmMemory values 
					add: (GtRrTimestampedChartDataItem new 
						timestamp: aSignal timestamp;
						data: aSignal data first).
				freeMemory  values 
					add: (GtRrTimestampedChartDataItem new 
						timestamp: aSignal timestamp;
						data: aSignal data second) ].
			data := GtPlotterDataLogicalGroups new 
				entities: {
					GtPlotterDataGroupWithColor new
						color: Color blue;
						entity: vmMemory.
					GtPlotterDataGroupWithColor new
						color: Color green muchDarker;
						entity: freeMemory }.
				
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
				titleY: 'VM Memory';
				ticksY: 10. ]
]
